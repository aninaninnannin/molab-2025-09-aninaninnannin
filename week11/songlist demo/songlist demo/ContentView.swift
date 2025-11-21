import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: SongStore
    @State private var isPresentingAddSheet = false
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.songs) { song in
                    SongRow(song: song)
                }
                .onDelete(perform: store.removeSongs)
                .onMove(perform: store.moveSongs)
            }
            .navigationTitle("My Song List")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddSongView()
            }
        }
    }
}

struct SongRow: View {
    let song: Song
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(song.title)
                .font(.headline)
            Text(song.artist)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let note = song.note, !note.isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environmentObject(SongStore())
}
