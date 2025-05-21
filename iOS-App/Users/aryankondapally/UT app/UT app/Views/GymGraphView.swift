import SwiftUI
import Charts

struct GymGraphView: View {
  let title: String
  @StateObject private var vm = GymBusinessViewModel()

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        Text(title)
          .font(.title2)
          .bold()
          .padding(.top)

        // DEBUG COUNTER (leave this to confirm data arrival)
        Text("Points: \(vm.data.count)")
          .foregroundColor(.secondary)
          .font(.caption)

        Chart(vm.data) { point in
          LineMark(
            x: .value("Time", point.timestamp),
            y: .value("Count", point.count)
          )
          .interpolationMethod(.catmullRom)

          PointMark(
            x: .value("Time", point.timestamp),
            y: .value("Count", point.count)
          )
        }
        .chartYAxis {
          AxisMarks { _ in
            AxisGridLine().foregroundStyle(.gray.opacity(0.5))
            AxisTick().foregroundStyle(.primary)
            AxisValueLabel().foregroundStyle(.primary)
          }
        }
        .chartXAxis {
          AxisMarks(values: .automatic(desiredCount: 5)) { _ in
            AxisGridLine().foregroundStyle(.gray.opacity(0.5))
            AxisTick().foregroundStyle(.primary)
            AxisValueLabel(format: .dateTime.hour().minute())
              .foregroundStyle(.primary)
              .font(.caption)
          }
        }
        .chartYAxisLabel("Visitors")
        .chartXAxisLabel("Time")
        .frame(height: 300)
        .padding(.horizontal)

        Spacer(minLength: 20)
      }
      .padding(.bottom)
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarTitleDisplayMode(.inline)
    .refreshable {
      await vm.loadData()
    }
    .task {
      await vm.loadData()
    }
  }
}
