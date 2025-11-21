import Foundation

struct Song: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var artist: String
    var note: String?
}
