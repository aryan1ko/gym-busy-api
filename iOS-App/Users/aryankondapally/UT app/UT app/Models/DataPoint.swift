import Foundation

struct DataPoint: Identifiable, Codable {
  var id: String { _id }
  let _id: String
  let timestamp: Date
  let count: Int
}
