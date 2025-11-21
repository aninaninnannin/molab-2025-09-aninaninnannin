import SwiftUI

struct AddSongView: View {
    @EnvironmentObject var store: SongStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Song Title", text: $title)
                    TextField("Artist", text: $artist)
                }
            }
            .navigationTitle("Add Song")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        addSong()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty ||
                              artist.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addSong() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanArtist = artist.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        store.addSong(title: cleanTitle, artist: cleanArtist,
                      note: cleanNote.isEmpty ? nil : cleanNote)
        dismiss()
    }
}

#Preview {
    AddSongView()
        .environmentObject(SongStore())
}
