import SwiftUI

private struct HUDChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.monospacedDigit().weight(.semibold))
            .foregroundColor(.white.opacity(0.86))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(CyberTheme.neonStrokeH, lineWidth: 1)
                            .opacity(0.55)
                    )
                    .shadow(color: CyberTheme.neonYellow.opacity(0.18), radius: 10)
                    .shadow(color: CyberTheme.neonPurple.opacity(0.10), radius: 14)
            )
    }
}

struct ContentView: View {
    @StateObject private var vm = AudioPlayerVM()
    @State private var oceanPhase: Double = 0

    private var beatPulse: Double {
        guard vm.isPlaying else { return 0 }
        let s = (sin(oceanPhase * 2.0) + 1) * 0.5 // 0...1
        return pow(s, 1.4)
    }

    var body: some View {
        ZStack {
            CyberTheme.background
                .ignoresSafeArea()

            OceanSweepLayer(phase: oceanPhase, strength: vm.isPlaying ? 1.0 : 0.70)
                .ignoresSafeArea()
                .opacity(vm.isPlaying ? 0.85 : 0.55)
                .allowsHitTesting(false)

            VStack(spacing: 18) {
                Text(vm.tracks[vm.index].title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .tracking(0.6)
                    .foregroundColor(.white.opacity(0.92))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(CyberTheme.neonStrokeH, lineWidth: 1.2)
                                    .opacity(0.65)
                            )
                            .shadow(color: CyberTheme.neonYellow.opacity(0.18 + 0.06 * beatPulse), radius: 14 + 5 * beatPulse)
                            .shadow(color: CyberTheme.neonPurple.opacity(0.10 + 0.05 * beatPulse), radius: 18 + 6 * beatPulse)
                    )

                HStack(spacing: 18) {
                    DropletIconButton(systemName: "backward.fill", size: 18, isPrimary: false, isBreathing: false) {
                        vm.prev()
                    }

                    DropletIconButton(
                        systemName: vm.isPlaying ? "pause.fill" : "play.fill",
                        size: 22,
                        isPrimary: true,
                        isBreathing: vm.isPlaying
                    ) {
                        vm.playPause()
                    }

                    DropletIconButton(systemName: "forward.fill", size: 18, isPrimary: false, isBreathing: false) {
                        vm.next()
                    }
                }

                CyberSeekBar(
                    currentTime: Binding(
                        get: { vm.currentTime },
                        set: { vm.seek(to: $0) }
                    ),
                    duration: vm.duration,
                    beatPulse: beatPulse,
                    isPlaying: vm.isPlaying
                )
                .frame(height: 34)

                HStack {
                    HUDChip(text: formatTime(vm.currentTime))
                    Spacer()
                    HUDChip(text: formatTime(vm.duration))
                }
                .padding(.horizontal, 2)

                HStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("REVERB")
                            .font(.caption2.monospaced().weight(.semibold))
                            .foregroundStyle(.white.opacity(0.55))

                        CyberDropletVolumeDroplet(value: $vm.reverbMix)
                            .frame(width: 86, height: 110)
                    }

                    VStack(spacing: 8) {
                        Text("VOLUME")
                            .font(.caption2.monospaced().weight(.semibold))
                            .foregroundStyle(.white.opacity(0.55))

                        CyberDropletVolumeDroplet(value: Binding(
                            get: { Double(vm.volume) },
                            set: { vm.volume = Float($0) }
                        ))
                        .frame(width: 98, height: 122)
                    }

                    VStack(spacing: 8) {
                        Text("DISTORT")
                            .font(.caption2.monospaced().weight(.semibold))
                            .foregroundStyle(.white.opacity(0.55))

                        CyberDropletVolumeDroplet(value: $vm.distortionMix)
                            .frame(width: 86, height: 110)
                    }
                }
            }
            .padding()
            .onAppear {
                oceanPhase = 0
                withAnimation(.linear(duration: 6.5).repeatForever(autoreverses: false)) {
                    oceanPhase = 2 * Double.pi
                }
            }
        }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        guard t.isFinite && !t.isNaN else { return "0:00" }
        let total = Int(t)
        let m = total / 60
        let s = total % 60
        return "\(m):" + String(format: "%02d", s)
    }
}

#Preview {
    ContentView()
}
