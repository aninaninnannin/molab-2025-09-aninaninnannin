import Foundation
import Combine
import SwiftUI


class SongStore: ObservableObject {
    @Published var songs: [Song] = [
        Song(title: "Young and Beautiful", artist: "Lana Del Rey"),
        Song(title: "夜空中最亮的星", artist: "逃跑计划"),
        Song(title: "Love Story", artist: "Taylor Swift")
    ]
    
    func addSong(title: String, artist: String, note: String? = nil) {
        let new = Song(title: title, artist: artist, note: note)
        songs.append(new)
    }
    
    func removeSongs(at offsets: IndexSet) {
        songs.remove(atOffsets: offsets)
    }
    
    func moveSongs(from source: IndexSet, to destination: Int) {
        songs.move(fromOffsets: source, toOffset: destination)
    }
}
