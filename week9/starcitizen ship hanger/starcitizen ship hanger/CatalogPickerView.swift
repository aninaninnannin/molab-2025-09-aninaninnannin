import SwiftUI

struct CatalogPickerView: View {
    @EnvironmentObject var store: HangarStore
    @Environment(\.dismiss) private var dismiss
    @State private var q = ""
    @State private var role: String = "All"

    private var filtered: [CatalogShip] {
        var list = store.library
        if role != "All" {
            list = list.filter { $0.role == role }
        }
        if !q.isEmpty {
            let l = q.lowercased()
            list = list.filter {
                $0.name.lowercased().contains(l) || $0.manufacturer.lowercased().contains(l)
            }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                    ForEach(filtered, id: \.id) { c in
                        VStack(alignment: .leading, spacing: 8) {
                            AssetImage(name: c.imageName)
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            Text(c.name)
                                .font(.headline)
                                .lineLimit(2)
                            Text(c.manufacturer)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(c.role)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(c.price.formatted(.number.grouping(.automatic)))
                                .font(.subheadline)
                                .monospacedDigit()
                            Button {
                                store.addFromCatalog(c)
                                dismiss()
                            } label: {
                                Label("Add to Hangar", systemImage: "plus.circle.fill")
                                    .labelStyle(.titleAndIcon)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
            .navigationTitle("Catalog")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Role", selection: $role) {
                            ForEach(store.roles, id: \.self) { r in
                                Text(r).tag(r)
                            }
                        }
                    } label: {
                        Label(role == "All" ? "Role" : role, systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .searchable(text: $q, prompt: "Search catalog")
        }
    }
}
