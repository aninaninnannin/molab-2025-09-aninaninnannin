import SwiftUI

struct Page7: View {
    @State private var seconds = 0
    @State private var isRunning = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 24) {
            Text("Swimming").font(.largeTitle).bold()

            Text(format(seconds))
                .font(.system(size: 72, weight: .semibold, design: .rounded))
                .monospacedDigit()

            HStack(spacing: 16) {
                Button(isRunning ? "Pause" : "Start") { isRunning ? pause() : start() }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { reset() }
                    .buttonStyle(.bordered).tint(.gray)
                    .disabled(seconds == 0 && !isRunning)
            }

            Spacer()
        }
        .padding()
        .onDisappear { stop() }
    }

    private func start() {
        guard timer == nil else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            seconds += 1
        }
    }
    private func pause() { isRunning = false; stop() }
    private func reset() { pause(); seconds = 0 }
    private func stop() { timer?.invalidate(); timer = nil }
    private func format(_ s: Int) -> String {
        let h = s/3600, m = (s%3600)/60, sec = s%60
        return h > 0 ? String(format:"%02d:%02d:%02d", h,m,sec)
                     : String(format:"%02d:%02d", m,sec)
    }
}
