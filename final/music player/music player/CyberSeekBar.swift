import SwiftUI

struct CyberSeekBar: View {
    var currentTime: Binding<TimeInterval>
    let duration: TimeInterval
    let beatPulse: Double
    let isPlaying: Bool

    @State private var dragFlash: Double = 0
    @State private var releaseFlash: Double = 0
    @State private var isDragging: Bool = false

    private var progress: CGFloat {
        guard duration > 0 else { return 0 }
        return CGFloat(max(0, min(currentTime.wrappedValue / duration, 1)))
    }

    var body: some View {
        GeometryReader { geo in
            let w = max(geo.size.width, 1)
            let h = max(geo.size.height, 1)

            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate

                Canvas { ctx, size in
                    let W = size.width
                    let H = size.height
                    let midY = H * 0.5
                    let pX = max(0, min(W, progress * W))
                    let beat = CGFloat(min(1, max(0, beatPulse)))

                    let drag = CGFloat(min(1, max(0, dragFlash)))
                    let baseAmp = max(3, H * (0.26 + 0.06 * drag))
                    let speed = (isPlaying ? 1.65 : 0.35) + 0.65 * drag
                    let phase = CGFloat(t * speed)

                    let neonGrad = Gradient(colors: [
                        CyberTheme.neonYellow.opacity(0.85 + 0.15 * Double(beat)),
                        CyberTheme.neonPurple.opacity(0.68 + 0.20 * Double(beat))
                    ])

                    func hash01(_ x: Double) -> Double {
                        let s = sin(x * 12.9898 + 78.233) * 43758.5453
                        return s - floor(s)
                    }

                    func yAt(_ x: CGFloat) -> CGFloat {
                        let u = x / max(W, 1)
                        let a1 = sin(u * .pi * 2 * 2.3 + phase)
                        let a2 = sin(u * .pi * 2 * 6.4 + phase * 0.85)
                        let jitter = CGFloat(hash01(Double(u) * 10 + Double(t) * 0.7) - 0.5) * (H * 0.035)
                        return midY + (a1 * 0.65 + a2 * 0.35) * baseAmp + jitter
                    }

                    func makeWavePath(xMax: CGFloat) -> Path {
                        var path = Path()
                        let step: CGFloat = 1
                        let x0: CGFloat = 0
                        let x1: CGFloat = max(0, min(xMax, W))
                        path.move(to: CGPoint(x: x0, y: yAt(x0)))
                        if x1 > 0 {
                            for x in stride(from: x0, through: x1, by: step) {
                                path.addLine(to: CGPoint(x: x, y: yAt(x)))
                            }
                        }
                        return path
                    }

                    // rail
                    let rail = makeWavePath(xMax: W)
                    ctx.drawLayer { layer in
                        layer.addFilter(.shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 8))
                        layer.stroke(
                            rail,
                            with: .color(Color.white.opacity(0.14)),
                            style: StrokeStyle(lineWidth: 6 + 3 * drag, lineCap: .round, lineJoin: .round)
                        )
                    }

                    // scanlines
                    var scan = Path()
                    let scanStep = max(4, Int(H * 0.18))
                    for yy in stride(from: 2, through: Int(H) - 2, by: scanStep) {
                        scan.addRect(CGRect(x: 0, y: CGFloat(yy), width: W, height: 1))
                    }
                    ctx.fill(scan, with: .color(Color.white.opacity(0.06)))

                    // played neon (clipped)
                    ctx.drawLayer { layer in
                        layer.clip(to: Path(CGRect(x: 0, y: 0, width: pX, height: H)))
                        let played = makeWavePath(xMax: W)

                        layer.addFilter(.shadow(color: CyberTheme.neonYellow.opacity(0.48 + 0.20 * Double(beat)), radius: 14 + 10 * beat))
                        layer.stroke(
                            played,
                            with: .linearGradient(neonGrad,
                                                  startPoint: CGPoint(x: 0, y: midY),
                                                  endPoint: CGPoint(x: W, y: midY)),
                            style: StrokeStyle(lineWidth: 8 + 4 * drag, lineCap: .round, lineJoin: .round)
                        )

                        layer.addFilter(.shadow(color: CyberTheme.neonPurple.opacity(0.35), radius: 10))
                        layer.stroke(
                            played,
                            with: .linearGradient(neonGrad,
                                                  startPoint: CGPoint(x: 0, y: midY),
                                                  endPoint: CGPoint(x: W, y: midY)),
                            style: StrokeStyle(lineWidth: 4.8 + 2.2 * drag, lineCap: .round, lineJoin: .round)
                        )

                        // particles
                        let particleCount = Int(22 + 40 * drag + 18 * beat)
                        for i in 0..<particleCount {
                            let fi = Double(i)
                            let r = hash01(fi * 13.7 + t * 0.9)
                            let px = CGFloat(r) * max(pX, 1)
                            let py = yAt(px) + CGFloat(hash01(fi * 9.3 + t * 1.2) - 0.5) * (H * 0.18)

                            let radius = CGFloat(1.2 + hash01(fi * 3.1 + t * 0.4) * 2.2)
                            let alpha = 0.18 + hash01(fi * 5.5 + t * 1.0) * 0.35

                            let dot = Path(ellipseIn: CGRect(x: px - radius, y: py - radius,
                                                             width: radius * 2, height: radius * 2))

                            layer.drawLayer { ll in
                                ll.addFilter(.shadow(color: CyberTheme.neonYellow.opacity(alpha), radius: 10))
                                ll.fill(dot, with: .color(Color.white.opacity(alpha)))
                            }
                        }
                    }

                    // scan head beam
                    let headX = pX
                    let headY = yAt(headX)

                    var beam = Path()
                    beam.addRect(CGRect(x: headX - (1 + drag), y: 0, width: 2 + 2 * drag, height: H))

                    ctx.drawLayer { layer in
                        let flash = CGFloat(min(1, dragFlash))
                        layer.addFilter(.shadow(color: CyberTheme.neonYellow.opacity(0.50 + 0.35 * flash + 0.20 * Double(beat)), radius: 18 + 12 * beat))
                        layer.fill(
                            beam,
                            with: .linearGradient(neonGrad,
                                                  startPoint: CGPoint(x: headX, y: 0),
                                                  endPoint: CGPoint(x: headX, y: H))
                        )
                    }

                    // knob
                    let knobR: CGFloat = 6.5 + 1.2 * drag
                    let knobRect = CGRect(x: headX - knobR, y: headY - knobR,
                                          width: knobR * 2, height: knobR * 2)
                    let knob = Path(ellipseIn: knobRect)

                    ctx.drawLayer { layer in
                        let flash = CGFloat(min(1, dragFlash))
                        layer.addFilter(.shadow(color: CyberTheme.neonYellow.opacity(0.70 + 0.20 * flash), radius: 14))
                        layer.addFilter(.shadow(color: CyberTheme.neonPurple.opacity(0.35 + 0.25 * flash), radius: 16))
                        layer.fill(knob, with: .color(Color.white))
                    }

                    // release burst
                    let burst = CGFloat(min(1, max(0, releaseFlash)))
                    if burst > 0.001 {
                        let exp = CGFloat(1 - burst)
                        let sparkCount = 16

                        ctx.drawLayer { layer in
                            layer.addFilter(.shadow(color: CyberTheme.neonYellow.opacity(Double(0.80 * burst)), radius: 18))
                            layer.addFilter(.shadow(color: CyberTheme.neonPurple.opacity(Double(0.45 * burst)), radius: 22))

                            for i in 0..<sparkCount {
                                let a = (CGFloat(i) / CGFloat(sparkCount)) * .pi * 2 + CGFloat(t) * 0.35
                                let r0 = knobR + 2
                                let r1 = r0 + (10 + 36 * exp)

                                var ray = Path()
                                ray.move(to: CGPoint(x: headX + cos(a) * r0, y: headY + sin(a) * r0))
                                ray.addLine(to: CGPoint(x: headX + cos(a) * r1, y: headY + sin(a) * r1))

                                layer.stroke(
                                    ray,
                                    with: .color(Color.white.opacity(Double(0.55 * burst))),
                                    style: StrokeStyle(lineWidth: 1.6 - 0.8 * exp, lineCap: .round)
                                )

                                let dotR = CGFloat(1.2 + 2.0 * exp)
                                let dot = Path(ellipseIn: CGRect(
                                    x: headX + cos(a) * r1 - dotR,
                                    y: headY + sin(a) * r1 - dotR,
                                    width: dotR * 2,
                                    height: dotR * 2
                                ))
                                layer.fill(dot, with: .color(Color.white.opacity(Double(0.32 * burst))))
                            }
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        if !isDragging {
                            isDragging = true
                            Haptics.tick()
                        }
                        let px = max(0, min(w, g.location.x))
                        let p = px / w
                        currentTime.wrappedValue = TimeInterval(p) * max(duration, 0)
                        dragFlash = 1
                    }
                    .onEnded { _ in
                        isDragging = false
                        Haptics.tick()
                        releaseFlash = 1
                        withAnimation(.easeOut(duration: 0.45)) { releaseFlash = 0 }
                        withAnimation(.easeOut(duration: 0.25)) { dragFlash = 0 }
                    }
            )
        }
    }
}
