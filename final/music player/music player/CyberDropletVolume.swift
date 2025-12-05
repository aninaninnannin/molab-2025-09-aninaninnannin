import SwiftUI

struct DropletShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        let top = CGPoint(x: rect.midX, y: rect.minY + h * 0.06)
        let left = CGPoint(x: rect.minX + w * 0.18, y: rect.minY + h * 0.42)
        let right = CGPoint(x: rect.maxX - w * 0.18, y: rect.minY + h * 0.42)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY - h * 0.06)

        p.move(to: top)
        p.addCurve(to: left,
                   control1: CGPoint(x: rect.minX + w * 0.30, y: rect.minY + h * 0.06),
                   control2: CGPoint(x: rect.minX + w * 0.05, y: rect.minY + h * 0.28))
        p.addCurve(to: bottom,
                   control1: CGPoint(x: rect.minX + w * 0.02, y: rect.minY + h * 0.72),
                   control2: CGPoint(x: rect.minX + w * 0.36, y: rect.maxY - h * 0.02))
        p.addCurve(to: right,
                   control1: CGPoint(x: rect.maxX - w * 0.36, y: rect.maxY - h * 0.02),
                   control2: CGPoint(x: rect.maxX - w * 0.02, y: rect.minY + h * 0.72))
        p.addCurve(to: top,
                   control1: CGPoint(x: rect.maxX - w * 0.05, y: rect.minY + h * 0.28),
                   control2: CGPoint(x: rect.maxX - w * 0.30, y: rect.minY + h * 0.06))
        p.closeSubpath()
        return p
    }
}

struct WaveShape: Shape {
    var level: CGFloat
    var phase: CGFloat
    var amplitude: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let clamped = max(0, min(level, 1))
        let yLevel = (1 - clamped) * h

        var p = Path()
        p.move(to: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: 0, y: yLevel))

        let freq = CGFloat.pi * 2 / max(w, 1)
        for x in stride(from: CGFloat(0), through: w, by: 1) {
            let y = yLevel + sin(x * freq + phase) * amplitude
            p.addLine(to: CGPoint(x: x, y: y))
        }

        p.addLine(to: CGPoint(x: w, y: h))
        p.closeSubpath()
        return p
    }
}

struct CyberDropletVolume: View {
    @Binding var value: Double // 0...1
    @State private var phase: CGFloat = 0

    private var clampedValue: Double { max(0, min(value, 1)) }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let w = max(size.width, 1)
            let h = max(size.height, 1)
            let progressW = w * CGFloat(clampedValue)

            let corner = h / 2
            let rail = RoundedRectangle(cornerRadius: corner, style: .continuous)

            ZStack {
                // Base glass rail
                rail
                    .fill(.white.opacity(0.08))
                    .overlay(
                        rail
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.95), .pink.opacity(0.75)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.2
                            )
                            .shadow(color: .cyan.opacity(0.55), radius: 10)
                            .shadow(color: .pink.opacity(0.30), radius: 14)
                    )

                // Filled (liquid) portion
                ZStack {
                    // Liquid gradient fill
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.90), .pink.opacity(0.60)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Moving "flow" waves (subtle, but visible)
                    WaveLine(phase: phase, amplitude: max(1.5, h * 0.18), baseline: 0.45, frequency: 2.2)
                        .stroke(.white.opacity(0.28), lineWidth: 1.2)
                        .blendMode(.screen)
                        .blur(radius: 0.4)

                    WaveLine(phase: phase * 1.35 + 1.2, amplitude: max(1.0, h * 0.14), baseline: 0.62, frequency: 3.4)
                        .stroke(.cyan.opacity(0.35), lineWidth: 1.0)
                        .blendMode(.screen)
                        .blur(radius: 0.6)

                    // Scanlines
                    VStack(spacing: max(3, h * 0.22)) {
                        ForEach(0..<8, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 1)
                        }
                    }
                    .opacity(0.25)
                }
                .frame(width: progressW)
                .mask(rail)
                .overlay(
                    // Hot core highlight along the fill
                    rail
                        .stroke(.white.opacity(0.10), lineWidth: 1)
                        .blendMode(.screen)
                )

                // Knob + readout
                HStack {
                    Spacer()

                    Text("\(Int(clampedValue * 100))%")
                        .font(.system(.caption, design: .monospaced).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.black.opacity(0.25))
                                .overlay(
                                    Capsule().stroke(.white.opacity(0.10), lineWidth: 1)
                                )
                        )
                }
                .padding(.trailing, 6)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let x = max(0, min(w, g.location.x))
                        value = Double(x / w)
                    }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                    phase = .pi * 4
                }
            }
        }
        // Long bar size (tweak these to taste)
        .frame(width: 260, height: 28)
    }
}

// MARK: - Horizontal wave line (for liquid flow texture)
private struct WaveLine: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var baseline: CGFloat    // 0...1
    var frequency: CGFloat   // waves across width

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let baseY = max(0, min(1, baseline)) * h

        var p = Path()
        p.move(to: CGPoint(x: 0, y: baseY))

        let twoPi = CGFloat.pi * 2
        let step: CGFloat = 1
        for x in stride(from: CGFloat(0), through: w, by: step) {
            let u = (x / max(w, 1))
            let y = baseY + sin(u * twoPi * frequency + phase) * amplitude
            p.addLine(to: CGPoint(x: x, y: y))
        }
        return p
    }
}
