import SwiftUI

// MARK: - Volume (original-style droplet HUD bar)
struct CyberDropletVolumeBar: View {
    @Binding var value: Double  // 0...1

    @State private var phase: Double = 0
    @State private var lastTick: Int = -1

    private var v: Double { max(0, min(value, 1)) }

    var body: some View {
        GeometryReader { geo in
            let W = max(geo.size.width, 1)
            let H = max(geo.size.height, 1)
            let pX = W * CGFloat(v)

            let rail = Capsule(style: .continuous)

            ZStack(alignment: .leading) {
                rail
                    .fill(Color.white.opacity(0.055))
                    .overlay(
                        rail.stroke(CyberTheme.neonStrokeH.opacity(0.55), lineWidth: 1.1)
                    )
                    .shadow(color: CyberTheme.neonYellow.opacity(0.14), radius: 12)
                    .shadow(color: CyberTheme.neonPurple.opacity(0.08), radius: 16)

                ZStack {
                    rail
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    CyberTheme.neonYellow.opacity(0.70),
                                    CyberTheme.neonPurple.opacity(0.48)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    VolumeSheen(phase: phase)
                        .opacity(0.55)
                        .blendMode(.screen)
                        .mask(rail)

                    BubbleDots(seed: phase)
                        .opacity(0.25)
                        .mask(rail)
                }
                .frame(width: max(pX, H * 0.55))
                .mask(rail)

                let knobSize = H * 0.98
                let knobX = max(0, min(W - knobSize, pX - knobSize * 0.50))

                ZStack {
                    DropletKnobShape()
                        .fill(Color.white.opacity(0.13))
                        .overlay(
                            DropletKnobShape()
                                .stroke(CyberTheme.neonStrokeV.opacity(0.78), lineWidth: 1.2)
                        )
                        .shadow(color: CyberTheme.neonYellow.opacity(0.30), radius: 14)
                        .shadow(color: CyberTheme.neonPurple.opacity(0.18), radius: 18)

                    Capsule()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: knobSize * 0.22, height: knobSize * 0.62)
                        .rotationEffect(.degrees(-18))
                        .offset(x: -knobSize * 0.10, y: -knobSize * 0.12)
                        .blur(radius: 6)
                        .mask(DropletKnobShape())

                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: knobSize * 0.34, weight: .semibold))
                        .foregroundColor(.white.opacity(0.92))
                        .shadow(color: CyberTheme.neonYellow.opacity(0.22), radius: 10)
                }
                .frame(width: knobSize, height: knobSize)
                .offset(x: knobX)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let x = max(0, min(W, g.location.x))
                        let nv = Double(x / W)
                        value = nv

                        let step = Int(nv * 20)
                        if step != lastTick {
                            lastTick = step
                            Haptics.tick()
                        }
                    }
            )
            .onAppear {
                phase = 0
                withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                    phase = 2 * Double.pi
                }
            }
        }
    }
}

private struct DropletKnobShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let cx = rect.midX
        let topY = rect.minY + h * 0.08
        let bottomY = rect.maxY - h * 0.04

        let r = min(w, h) * 0.42
        let left = cx - r
        let right = cx + r
        let midY = rect.midY + h * 0.02

        var p = Path()
        p.move(to: CGPoint(x: cx, y: topY))

        p.addCurve(
            to: CGPoint(x: right, y: midY),
            control1: CGPoint(x: cx + r * 0.95, y: topY + r * 0.20),
            control2: CGPoint(x: right + r * 0.10, y: midY - r * 0.25)
        )

        p.addCurve(
            to: CGPoint(x: cx, y: bottomY),
            control1: CGPoint(x: right - r * 0.05, y: rect.maxY - h * 0.18),
            control2: CGPoint(x: cx + r * 0.35, y: rect.maxY - h * 0.05)
        )

        p.addCurve(
            to: CGPoint(x: left, y: midY),
            control1: CGPoint(x: cx - r * 0.35, y: rect.maxY - h * 0.05),
            control2: CGPoint(x: left + r * 0.05, y: rect.maxY - h * 0.18)
        )

        p.addCurve(
            to: CGPoint(x: cx, y: topY),
            control1: CGPoint(x: left - r * 0.10, y: midY - r * 0.25),
            control2: CGPoint(x: cx - r * 0.95, y: topY + r * 0.20)
        )

        p.closeSubpath()
        return p
    }
}

private struct VolumeSheen: View, Animatable {
    var phase: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    var body: some View {
        Canvas { ctx, size in
            let W = max(size.width, 1)
            let H = max(size.height, 1)
            let t = CGFloat(phase)

            let bandW = W * 0.75
            let x0 = (sin(t * 0.75) * 0.5 + 0.5) * (W + bandW) - bandW
            let rect = CGRect(x: x0, y: -H * 0.25, width: bandW, height: H * 1.5)

            ctx.addFilter(.blur(radius: 8))
            ctx.fill(
                Path(roundedRect: rect, cornerRadius: 18),
                with: .linearGradient(
                    Gradient(colors: [
                        .clear,
                        Color.white.opacity(0.10),
                        CyberTheme.neonYellow.opacity(0.06),
                        .clear
                    ]),
                    startPoint: CGPoint(x: rect.minX, y: rect.minY),
                    endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                )
            )
        }
    }
}

private struct BubbleDots: View {
    let seed: Double

    var body: some View {
        Canvas { ctx, size in
            let W = max(size.width, 1)
            let H = max(size.height, 1)
            let t = CGFloat(seed)

            func frac(_ x: CGFloat) -> CGFloat { x - floor(x) }
            func hash01(_ x: CGFloat) -> CGFloat {
                let s = sin(x * 12.9898 + 78.233) * 43758.5453
                return frac(s)
            }

            let count = 14
            for i in 0..<count {
                let fi = CGFloat(i)
                let x = hash01(fi * 4.1 + 0.2) * W
                let y = hash01(fi * 7.7 + 1.1) * H
                let drift = sin(t * 0.9 + fi) * 2
                let r = 0.9 + hash01(fi * 5.3 + 2.2) * 1.8

                let dot = Path(ellipseIn: CGRect(x: x - r, y: y + drift - r, width: r * 2, height: r * 2))
                ctx.fill(dot, with: .color(Color.white.opacity(0.22)))
            }
        }
    }
}

// MARK: - Volume (user droplet-style liquid bar)
struct CyberLiquidVolumeBar: View {
    @Binding var value: Double // 0...1
    @State private var phase: CGFloat = 0
    @State private var lastTick: Int = -1

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
                rail
                    .fill(.white.opacity(0.08))
                    .overlay(
                        rail
                            .stroke(CyberTheme.neonStrokeH, lineWidth: 1.2)
                            .shadow(color: CyberTheme.neonYellow.opacity(0.55), radius: 10)
                            .shadow(color: CyberTheme.neonPurple.opacity(0.30), radius: 14)
                    )

                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [CyberTheme.neonYellow.opacity(0.90), CyberTheme.neonPurple.opacity(0.60)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    WaveLine(phase: phase, amplitude: max(1.5, h * 0.18), baseline: 0.45, frequency: 2.2)
                        .stroke(.white.opacity(0.28), lineWidth: 1.2)
                        .blendMode(.screen)
                        .blur(radius: 0.4)

                    WaveLine(phase: phase * 1.35 + 1.2, amplitude: max(1.0, h * 0.14), baseline: 0.62, frequency: 3.4)
                        .stroke(CyberTheme.neonYellow.opacity(0.35), lineWidth: 1.0)
                        .blendMode(.screen)
                        .blur(radius: 0.6)

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
                    rail
                        .stroke(.white.opacity(0.10), lineWidth: 1)
                        .blendMode(.screen)
                )

                HStack {
                    Spacer()

                    Text("\(Int(clampedValue * 100))%")
                        .font(.system(.caption, design: .monospaced).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(.black.opacity(0.25))
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(.white.opacity(0.10), lineWidth: 1)
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
                        let nv = Double(x / w)
                        value = nv

                        let step = Int(nv * 20)
                        if step != lastTick {
                            lastTick = step
                            Haptics.tick()
                        }
                    }
            )
            .onAppear {
                if phase == 0 {
                    withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                        phase = .pi * 4
                    }
                }
            }
        }
    }
}

private struct WaveLine: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var baseline: CGFloat
    var frequency: CGFloat

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

// MARK: - Droplet-shaped volume control
private struct VolumeDropletShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        let top = CGPoint(x: rect.midX, y: rect.minY + h * 0.06)
        let left = CGPoint(x: rect.minX + w * 0.18, y: rect.minY + h * 0.42)
        let right = CGPoint(x: rect.maxX - w * 0.18, y: rect.minY + h * 0.42)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY - h * 0.06)

        p.move(to: top)
        p.addCurve(
            to: left,
            control1: CGPoint(x: rect.minX + w * 0.30, y: rect.minY + h * 0.06),
            control2: CGPoint(x: rect.minX + w * 0.05, y: rect.minY + h * 0.28)
        )
        p.addCurve(
            to: bottom,
            control1: CGPoint(x: rect.minX + w * 0.02, y: rect.minY + h * 0.72),
            control2: CGPoint(x: rect.minX + w * 0.36, y: rect.maxY - h * 0.02)
        )
        p.addCurve(
            to: right,
            control1: CGPoint(x: rect.maxX - w * 0.36, y: rect.maxY - h * 0.02),
            control2: CGPoint(x: rect.maxX - w * 0.02, y: rect.minY + h * 0.72)
        )
        p.addCurve(
            to: top,
            control1: CGPoint(x: rect.maxX - w * 0.05, y: rect.minY + h * 0.28),
            control2: CGPoint(x: rect.maxX - w * 0.30, y: rect.minY + h * 0.06)
        )
        p.closeSubpath()
        return p
    }
}

private struct VolumeWaveShape: Shape {
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

struct CyberDropletVolumeDroplet: View {
    @Binding var value: Double // 0...1

    @State private var phase: CGFloat = 0
    @State private var lastTick: Int = -1

    private var clampedValue: Double { max(0, min(value, 1)) }

    var body: some View {
        GeometryReader { geo in
            let w = max(geo.size.width, 1)
            let h = max(geo.size.height, 1)
            let droplet = VolumeDropletShape()

            let inset = max(8, min(w, h) * 0.10)
            let innerRect = CGRect(x: inset, y: inset, width: w - inset * 2, height: h - inset * 2)

            ZStack {
                ZStack {
                    VolumeWaveShape(level: CGFloat(clampedValue), phase: phase, amplitude: max(1.6, innerRect.height * 0.06))
                        .fill(
                            LinearGradient(
                                colors: [
                                    CyberTheme.neonYellow.opacity(0.88),
                                    CyberTheme.neonPurple.opacity(0.58)
                                ],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )

                    VolumeSheen(phase: Double(phase))
                        .opacity(0.65)
                        .blendMode(.screen)

                    BubbleDots(seed: Double(phase))
                        .opacity(0.16)
                }
                .frame(width: innerRect.width, height: innerRect.height)
                .mask(droplet)
                .overlay(
                    VolumeWaveShape(level: CGFloat(clampedValue), phase: phase, amplitude: max(1.2, innerRect.height * 0.05))
                        .stroke(Color.white.opacity(0.22), lineWidth: 1.1)
                        .blendMode(.screen)
                        .frame(width: innerRect.width, height: innerRect.height)
                        .mask(droplet)
                )

                droplet
                    .fill(Color.white.opacity(0.085))
                    .overlay(
                        droplet
                            .stroke(CyberTheme.neonStrokeV.opacity(0.78), lineWidth: 1.4)
                    )
                    .shadow(color: CyberTheme.neonYellow.opacity(0.22), radius: 16)
                    .shadow(color: CyberTheme.neonPurple.opacity(0.14), radius: 20)

                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: w * 0.22, height: h * 0.55)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -w * 0.16, y: -h * 0.18)
                    .blur(radius: 10)
                    .mask(droplet)

                VStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.92))
                        .shadow(color: CyberTheme.neonYellow.opacity(0.22), radius: 10)

                    Text("\(Int(clampedValue * 100))%")
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundColor(.white.opacity(0.75))
                }
                .padding(.top, 4)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let y = max(0, min(h, g.location.y))
                        let nv = 1 - Double(y / h)
                        value = max(0, min(nv, 1))

                        let step = Int(value * 20)
                        if step != lastTick {
                            lastTick = step
                            Haptics.tick()
                        }
                    }
            )
            .onAppear {
                if phase == 0 {
                    withAnimation(.linear(duration: 1.15).repeatForever(autoreverses: false)) {
                        phase = .pi * 4
                    }
                }
            }
        }
    }
}
