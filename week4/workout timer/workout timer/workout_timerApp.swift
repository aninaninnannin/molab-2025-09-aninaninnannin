import SwiftUI
import AVFoundation
import Combine

// MARK: - App Entry
@main
struct WorkoutTimerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - Root
struct RootView: View {
    var body: some View {
        TabView {
            StopwatchView()
                .tabItem { Label("Stopwatch", systemImage: "stopwatch") }
            IntervalCoachView()
                .tabItem { Label("Intervals", systemImage: "timer") }
        }
    }
}

// MARK: - Stopwatch Page
final class StopwatchVM: ObservableObject {
    @Published var isRunning = false
    @Published var elapsed: TimeInterval = 0
    @Published var laps: [TimeInterval] = []

    private var timer: Timer?
    private var lastStartDate: Date?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        lastStartDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let last = self.lastStartDate else { return }
            self.elapsed += Date().timeIntervalSince(last)
            self.lastStartDate = Date()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        timer?.invalidate()
        timer = nil
        lastStartDate = nil
    }

    func reset() {
        pause()
        elapsed = 0
        laps.removeAll()
    }

    func lap() {
        laps.insert(elapsed, at: 0)
    }
}

struct StopwatchView: View {
    @StateObject private var vm = StopwatchVM()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(formatted(vm.elapsed))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .padding(.top, 32)

                HStack(spacing: 16) {
                    Button(vm.isRunning ? "Pause" : "Start") {
                        vm.isRunning ? vm.pause() : vm.start()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Lap") { vm.lap() }
                        .buttonStyle(.bordered)
                        .disabled(!vm.isRunning)

                    Button("Reset") { vm.reset() }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .disabled(vm.elapsed == 0)
                }

                if !vm.laps.isEmpty {
                    List {
                        ForEach(Array(vm.laps.enumerated()), id: \.offset) { index, value in
                            HStack {
                                Text("Lap \(vm.laps.count - index)")
                                Spacer()
                                Text(formatted(value))
                                    .monospacedDigit()
                            }
                        }
                    }
                } else {
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Stopwatch")
        }
    }

    private func formatted(_ t: TimeInterval) -> String {
        let centiseconds = Int((t * 100).rounded())
        let minutes = centiseconds / 6000
        let seconds = (centiseconds % 6000) / 100
        let cs = centiseconds % 100
        return String(format: "%02d:%02d.%02d", minutes, seconds, cs)
    }
}

// MARK: - Interval Coach Page (with audio cues)
final class IntervalCoachVM: ObservableObject {
    @Published var workSeconds: Int = 20
    @Published var restSeconds: Int = 10
    @Published var rounds: Int = 8

    @Published private(set) var currentRound: Int = 0
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var remaining: Int = 0

    enum Phase: String { case idle, prepare, work, rest, finished }

    private var timer: Timer?
    private let speaker = AVSpeechSynthesizer()

    func start() {
        guard phase == .idle || phase == .finished else { return }
        currentRound = 0
        speak("Get ready")
        transition(to: .prepare, seconds: 3)
    }

    func stop() {
        timer?.invalidate(); timer = nil
        transition(to: .idle, seconds: 0)
    }

    private func transition(to newPhase: Phase, seconds: Int) {
        phase = newPhase
        remaining = seconds
        timer?.invalidate()

        guard seconds > 0 else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { return }
            self.remaining -= 1
            if self.remaining <= 0 {
                t.invalidate()
                self.advance()
            } else if self.remaining <= 3 {
                self.speak("\(self.remaining)")
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func advance() {
        switch phase {
        case .prepare:
            currentRound = 1
            speak("Work round 1")
            transition(to: .work, seconds: workSeconds)
        case .work:
            if currentRound >= rounds {
                speak("Workout complete. Great job!")
                transition(to: .finished, seconds: 0)
            } else {
                speak("Rest")
                transition(to: .rest, seconds: restSeconds)
            }
        case .rest:
            currentRound += 1
            speak("Work round \(currentRound)")
            transition(to: .work, seconds: workSeconds)
        case .finished, .idle:
            break
        }
    }

    private func speak(_ text: String) {
        let utt = AVSpeechUtterance(string: text)
        utt.voice = AVSpeechSynthesisVoice(language: Locale.current.language.languageCode?.identifier ?? "en-US")
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        speaker.speak(utt)
    }
}

struct IntervalCoachView: View {
    @StateObject private var vm = IntervalCoachVM()

    var body: some View {
        NavigationStack {
            Form {
                Section("Configuration") {
                    Stepper(value: $vm.workSeconds, in: 5...600, step: 5) {
                        HStack { Text("Work"); Spacer(); Text("\(vm.workSeconds)s").monospacedDigit() }
                    }
                    Stepper(value: $vm.restSeconds, in: 0...600, step: 5) {
                        HStack { Text("Rest"); Spacer(); Text("\(vm.restSeconds)s").monospacedDigit() }
                    }
                    Stepper(value: $vm.rounds, in: 1...30) {
                        HStack { Text("Rounds"); Spacer(); Text("\(vm.rounds)") }
                    }
                }

                Section("Session") {
                    HStack {
                        Text("Phase"); Spacer(); Text(vm.phase.rawValue.capitalized)
                    }
                    HStack {
                        Text("Round"); Spacer(); Text("\(vm.currentRound)/\(vm.rounds)")
                    }
                    HStack {
                        Text("Remaining"); Spacer(); Text("\(vm.remaining)s").monospacedDigit()
                    }
                    HStack(spacing: 16) {
                        Button("Start") { vm.start() }
                            .buttonStyle(.borderedProminent)
                        Button("Stop") { vm.stop() }
                            .buttonStyle(.bordered)
                            .tint(.red)
                    }
                }

                Section(footer: Text("Tip: the app uses built‑in speech for audio cues; no audio files needed.")) { EmptyView() }
            }
            .navigationTitle("Intervals")
        }
    }
}
