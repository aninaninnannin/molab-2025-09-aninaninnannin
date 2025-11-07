import Foundation
import Combine

@MainActor
final class HangarStore: ObservableObject {
    @Published var ships: [Ship] = []
    @Published var query: String = ""
    @Published var selectedRole: String = "All"
    @Published var sort: Sort = .nameAsc

    let library: [CatalogShip]

    init(library: [CatalogShip] = AssetLibrary.catalog) {
        self.library = library
        Task { await load() }
    }

    enum Sort: String, CaseIterable, Identifiable {
        case nameAsc = "Name ↑"
        case nameDesc = "Name ↓"
        case priceLow = "Price ↑"
        case priceHigh = "Price ↓"
        case newest = "Newest"
        var id: String { rawValue }
    }

    var roles: [String] {
        let set = Set(library.map { $0.role })
        return ["All"] + set.sorted()
    }

    var visibleShips: [Ship] {
        var result = ships
        if selectedRole != "All" {
            result = result.filter { $0.role == selectedRole }
        }
        if !query.isEmpty {
            let q = query.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(q) || $0.manufacturer.lowercased().contains(q)
            }
        }
        switch sort {
        case .nameAsc: result.sort { $0.name < $1.name }
        case .nameDesc: result.sort { $0.name > $1.name }
        case .priceLow: result.sort { $0.price < $1.price }
        case .priceHigh: result.sort { $0.price > $1.price }
        case .newest: result.sort { $0.createdAt > $1.createdAt }
        }
        return result
    }

    func addFromCatalog(_ c: CatalogShip) {
        let ship = Ship(
            catalogID: c.id,
            name: c.name,
            manufacturer: c.manufacturer,
            role: c.role,
            price: c.price,
            imageName: c.imageName
        )
        ships.append(ship)
        persist()
    }

    func delete(_ ship: Ship) {
        ships.removeAll { $0.id == ship.id }
        persist()
    }

    func updateNotes(for ship: Ship, notes: String) {
        guard let idx = ships.firstIndex(of: ship) else { return }
        ships[idx].notes = notes
        persist()
    }

    private var saveURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("hangar.json")
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(ships)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            print("Save failed:", error)
        }
    }

    func load() async {
        do {
            let data = try Data(contentsOf: saveURL)
            let loaded = try JSONDecoder().decode([Ship].self, from: data)
            ships = loaded
        } catch {
            ships = []
        }
    }
}
