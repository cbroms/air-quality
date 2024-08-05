import Foundation

struct DataPoint: Codable, Identifiable {
    var date: Date
    var observation: Int
    var id: String
}
