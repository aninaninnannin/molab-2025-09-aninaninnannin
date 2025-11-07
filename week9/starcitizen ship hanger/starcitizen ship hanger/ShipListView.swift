import SwiftUI

struct ShipListView: View {
    @EnvironmentObject var store: HangarStore
    @State private var showCatalog = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if store.visibleShips.isEmpty {
                        if #available(iOS 17.0, *) {
                            ContentUnavailableView(
                                "No Ships",
                                systemImage: "shippingbox.circle",
                                description: Text("Tap + to add from the catalog.")
                            )
                        } else {
                            Text("No Ships. Tap + to add from the catalog.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(store.visibleShips) { ship in
                            NavigationLink {
                                ShipDetailView(ship: ship)
                            } label: {
                                HStack(spacing: 12) {
                                    AssetImage(name: ship.imageName)
                                        .frame(width: 64, height: 48)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    VStack(alignment: .leading) {
                                        Text(ship.name).font(.headline)
                                        Text("\(ship.manufacturer) • \(ship.role)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(ship.price.formatted(.number.grouping(.automatic)))
                                        .font(.subheadline)
                                        .monospacedDigit()
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for idx in indexSet {
                                let ship = store.visibleShips[idx]
                                store.delete(ship)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ship Hangar")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { roleFilter }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        sortMenu
                        Button {
                            showCatalog = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add Ship")
                    }
                }
            }
            .sheet(isPresented: $showCatalog) {
                CatalogPickerView()
                    .environmentObject(store)
            }
            .searchable(
                text: $store.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Search name or manufacturer")
            )
        }
    }

    private var roleFilter: some View {
        Menu {
            Picker("Role", selection: $store.selectedRole) {
                ForEach(store.roles, id: \.self) { role in
                    Text(role).tag(role)
                }
            }
        } label: {
            Label(
                store.selectedRole == "All" ? "Role" : store.selectedRole,
                systemImage: "line.3.horizontal.decrease.circle"
            )
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort", selection: $store.sort) {
                ForEach(HangarStore.Sort.allCases) { s in
                    Text(s.rawValue).tag(s)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
        }
    }
}
