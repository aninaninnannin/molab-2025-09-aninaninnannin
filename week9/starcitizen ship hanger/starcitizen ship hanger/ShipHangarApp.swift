import SwiftUI

@main
struct ShipHangarApp: App {
    @StateObject private var store = HangarStore()
    var body: some Scene {
        WindowGroup {
            ShipListView()
                .environmentObject(store)
        }
    }
}
