import SwiftUI

@main
struct SongListDemoApp: App {
    @StateObject private var store = SongStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
