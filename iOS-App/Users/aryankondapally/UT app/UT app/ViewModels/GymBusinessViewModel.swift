import Foundation
import Combine

@MainActor
class GymBusinessViewModel: ObservableObject {
  @Published var data: [DataPoint] = []

  private var timer: Task<Void, Never>?

  init() {
    Task { await loadData() }
    timer = Task { await autoRefresh() }
  }

  func loadData() async {
    do {
        var points = try await Networking.shared.fetchData()

        if let last = points.last {
          let fifteen: TimeInterval = 15 * 60
          if Date().timeIntervalSince(last.timestamp) > fifteen {
            let fallbackDate  = last.timestamp.addingTimeInterval(fifteen)
            let fallbackCount = max(0, last.count - 10)
            let syntheticID   = "synthetic-\(fallbackDate.timeIntervalSince1970)"
            let synthetic     = DataPoint(_id: syntheticID,
                                          timestamp: fallbackDate,
                                          count: fallbackCount)
            points.append(synthetic)
          }
        }

        self.data = points
    } catch {
      print("Fetch error:", error)
    }
  }

  func autoRefresh() async {
    for await _ in Timer.publish(every: 15 * 60, on: .main, in: .common).autoconnect().values {
      await loadData()
    }
  }

  func pushUpdate(count: Int) async {
    do {
      try await Networking.shared.postData(count: count)
      await loadData()
    } catch {
      print("Post error:", error)
    }
  }
}
