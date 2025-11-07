import SwiftUI

struct ShipDetailView: View {
    @EnvironmentObject var store: HangarStore
    let ship: Ship
    @State private var notes: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AssetImage(name: ship.imageName)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                infoSection

                Text("Notes")
                    .font(.headline)

                TextEditor(text: $notes)
                    .frame(minHeight: 120)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.separator, lineWidth: 1)
                    )
            }
            .padding()
        }
        .navigationTitle(ship.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent("Manufacturer", value: ship.manufacturer)
            LabeledContent("Role", value: ship.role)
            LabeledContent("Price", value: ship.price.formatted(.number.grouping(.automatic)))
            LabeledContent("Added", value: ship.createdAt.formatted(date: .abbreviated, time: .shortened))
        }
        .font(.subheadline)
    }
}
