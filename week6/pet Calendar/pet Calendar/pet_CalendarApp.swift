import SwiftUI
import Combine


enum PetType: String, CaseIterable, Identifiable, Codable {
    case cat = "Cat"
    case dog = "Dog"
    var id: String { rawValue }
    var emoji: String { self == .cat ? "🐱" : "🐶" }
}

enum RepeatCycle: String, CaseIterable, Identifiable, Codable {
    case none = "Does not repeat"
    case monthly = "Every month"
    case every3Months = "Every 3 months"
    case every6Months = "Every 6 months"
    case yearly = "Every year"

    var id: String { rawValue }
}

struct PetEvent: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var pet: PetType
    var title: String
    var date: Date
    var notes: String = ""
    var repeatCycle: RepeatCycle = .none
}

@MainActor
final class EventStore: ObservableObject {
    @Published var events: [PetEvent] = [] {
        didSet { save() }
    }

    private let storageKey = "pet.events.v1"

    init() {
        load()
        if events.isEmpty {
            let cal = Calendar.current
            let sample = [
                PetEvent(pet: .cat, title: "Deworming", date: cal.date(byAdding: .day, value: 21, to: .now)!, notes: "Use vet-prescribed product.", repeatCycle: .every3Months),
                PetEvent(pet: .dog, title: "Annual Checkup", date: cal.date(byAdding: .day, value: 90, to: .now)!, notes: "Bring vaccine booklet.", repeatCycle: .yearly)
            ]
            events = sample
        }
    }

    func add(_ event: PetEvent) { events.append(event) }

    func delete(at offsets: IndexSet, filteredBy pet: PetType?) {
        let filtered = filteredEvents(for: pet)
        let idsToDelete = offsets.map { filtered[$0].id }
        events.removeAll { idsToDelete.contains($0.id) }
    }

    func filteredEvents(for pet: PetType?) -> [PetEvent] {
        if let pet { return events.filter { $0.pet == pet } }
        return events
    }

    func advanceToNextCycle(_ event: PetEvent) {
        guard let idx = events.firstIndex(of: event) else { return }
        guard event.repeatCycle != .none else { return }
        var next = event
        next.date = Calendar.current.nextDate(after: event.date, matching: DateComponents(hour: 9), matchingPolicy: .nextTimePreservingSmallerComponents) ?? event.date
        let cal = Calendar.current
        switch event.repeatCycle {
        case .none:
            break
        case .monthly:
            next.date = cal.date(byAdding: .month, value: 1, to: event.date) ?? event.date
        case .every3Months:
            next.date = cal.date(byAdding: .month, value: 3, to: event.date) ?? event.date
        case .every6Months:
            next.date = cal.date(byAdding: .month, value: 6, to: event.date) ?? event.date
        case .yearly:
            next.date = cal.date(byAdding: .year, value: 1, to: event.date) ?? event.date
        }
        events[idx] = next
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save events: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            events = try JSONDecoder().decode([PetEvent].self, from: data)
        } catch {
            print("Failed to load events: \(error)")
        }
    }
}


extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}

func daysBetween(_ from: Date, _ to: Date) -> Int {
    Calendar.current.dateComponents([.day], from: from.startOfDay, to: to.startOfDay).day ?? 0
}



struct CountdownChip: View {
    let target: Date

    var body: some View {
        let d = daysBetween(.now, target)
        let text: String
        if d > 1 { text = "In \(d) days" }
        else if d == 1 { text = "Tomorrow" }
        else if d == 0 { text = "Today" }
        else if d == -1 { text = "Yesterday" }
        else { text = "Overdue by \(abs(d)) days" }

        return Text(text)
            .font(.caption).bold()
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(backgroundColor(for: d))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .accessibilityLabel("Countdown: \(text)")
    }

    private func backgroundColor(for days: Int) -> Color {
        if days < 0 { return .red }
        if days <= 7 { return .orange }
        if days <= 30 { return .yellow.opacity(0.8) }
        return .green
    }
}

struct EventRow: View {
    let event: PetEvent

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(width: 48, height: 48)
                Text(event.pet.emoji)
                    .font(.title2)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(event.date, style: .date)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                if event.repeatCycle != .none {
                    Label(event.repeatCycle.rawValue, systemImage: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            CountdownChip(target: event.date)
        }
        .padding(.vertical, 6)
    }
}


struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var repeatCycle: RepeatCycle = .none

    let defaultPet: PetType
    let onSave: (PetEvent) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Pet") {
                    Picker("Pet", selection: .constant(defaultPet)) {
                        ForEach(PetType.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(true)
                    Text("This event will be created for your \(defaultPet.rawValue.lowercased()).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Event Details") {
                    TextField("Event name (e.g., Deworming)", text: $title)
                    DatePicker("Due date", selection: $date, displayedComponents: .date)
                    Picker("Repeat", selection: $repeatCycle) {
                        ForEach(RepeatCycle.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("New Countdown")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let e = PetEvent(pet: defaultPet, title: title.trimmingCharacters(in: .whitespaces), date: date, notes: notes, repeatCycle: repeatCycle)
        onSave(e)
        dismiss()
    }
}


struct ContentView: View {
    @StateObject private var store = EventStore()
    @State private var selectedPet: PetType = .cat
    @State private var showingAdd = false
    @State private var searchText = ""

    private var filtered: [PetEvent] {
        store.filteredEvents(for: selectedPet)
            .filter { searchText.isEmpty ? true : $0.title.localizedCaseInsensitiveContains(searchText) || $0.notes.localizedCaseInsensitiveContains(searchText) }
            .sorted { lhs, rhs in
                // sort by nearest first
                lhs.date < rhs.date
            }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("Pet", selection: $selectedPet) {
                    ForEach(PetType.allCases) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                .pickerStyle(.segmented)

                if filtered.isEmpty {
                    ContentUnavailableView {
                        Label("No countdowns", systemImage: "pawprint")
                    } description: {
                        Text("Add your first event for your \(selectedPet.rawValue.lowercased()).")
                    } actions: {
                        Button {
                            showingAdd = true
                        } label: { Text("Add Countdown") }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section() {
                            ForEach(filtered) { event in
                                EventRow(event: event)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            if let idx = filtered.firstIndex(of: event) {
                                                store.delete(at: IndexSet(integer: idx), filteredBy: selectedPet)
                                            }
                                        } label: { Label("Delete", systemImage: "trash") }

                                        if event.repeatCycle != .none {
                                            Button {
                                                store.advanceToNextCycle(event)
                                            } label: { Label("Next", systemImage: "forward.end") }
                                            .tint(.blue)
                                        }
                                    }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .padding(.horizontal)
            .navigationTitle("Pet Care Countdown")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("Add Countdown", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEventView(defaultPet: selectedPet) { newEvent in
                    store.add(newEvent)
                }
                .presentationDetents([.medium, .large])
            }
        }
        .tint(.blue)
    }
}


@main
struct PetCareCountdownApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

