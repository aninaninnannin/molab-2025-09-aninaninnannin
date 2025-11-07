import Foundation

struct CatalogShip: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let manufacturer: String
    let role: String
    let price: Int
    let imageName: String
}

struct Ship: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var catalogID: String
    var name: String
    var manufacturer: String
    var role: String
    var price: Int
    var imageName: String
    var notes: String = ""
    var createdAt = Date()
}
