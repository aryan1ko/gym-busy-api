import Foundation

enum APIError: Error { case url, unauthorized, decoding }

class Networking {
  static let shared = Networking()
  private init() {}

  private let session = URLSession.shared
  private var token: String? {
    UserDefaults.standard.string(forKey: "jwt-token")
  }

  func login(username: String, password: String) async throws {
    guard let url = URL(string: "\(API.base)/login") else { throw APIError.url }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try JSONEncoder().encode(["username": username, "password": password])

    let (data, resp) = try await session.data(for: req)
    if let http = resp as? HTTPURLResponse, http.statusCode == 401 {
      throw APIError.unauthorized
    }
    let obj = try JSONDecoder().decode([String: String].self, from: data)
    UserDefaults.standard.set(obj["token"], forKey: "jwt-token")
  }

    func fetchData() async throws -> [DataPoint] {
      guard let url = URL(string: "\(API.base)/data") else { throw APIError.url }
      var req = URLRequest(url: url)
      if let t = token {
        req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
      }
      let (raw, _) = try await session.data(for: req)
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601    // important for timestamp
      return try decoder.decode([DataPoint].self, from: raw)
    }


  func postData(count: Int) async throws {
    guard let url = URL(string: "\(API.base)/data") else { throw APIError.url }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
    req.httpBody = try JSONEncoder().encode(["count": count])
    _ = try await session.data(for: req)
  }
}
