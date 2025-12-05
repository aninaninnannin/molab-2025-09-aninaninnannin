import SwiftUI

struct OceanSweepLayer: View, Animatable {
    var phase: Double
    let strength: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    var body: some View {
        Canvas { ctx, size in
            let W = max(size.width, 1)
            let H = max(size.height, 1)

            func frac(_ x: CGFloat) -> CGFloat { x - floor(x) }

            let prog = frac(CGFloat((phase.truncatingRemainder(dividingBy: 2 * Double.pi)) / (2 * Double.pi)))
            let isSecondHalf = prog >= 0.5
            let p = isSecondHalf ? (prog - 0.5) * 2 : prog * 2  // 0...1

            let bandDepth: CGFloat = H * 0.30
            let front = (p * (H + bandDepth * 2)) - bandDepth

            let baseTop = isSecondHalf ? CyberTheme.neonPurple.opacity(0.28 * strength) : CyberTheme.neonYellow.opacity(0.22 * strength)
            let baseMid = isSecondHalf ? CyberTheme.neonYellow.opacity(0.10 * strength) : CyberTheme.neonPurple.opacity(0.10 * strength)
            let baseBot = Color.clear

            let wipeTop = isSecondHalf ? CyberTheme.neonYellow.opacity(0.42 * strength) : CyberTheme.neonPurple.opacity(0.42 * strength)
            let wipeMid = isSecondHalf ? CyberTheme.neonPurple.opacity(0.16 * strength) : CyberTheme.neonYellow.opacity(0.14 * strength)
            let wipeBot = isSecondHalf ? CyberTheme.neonYellow.opacity(0.10 * strength) : CyberTheme.neonPurple.opacity(0.10 * strength)

            ctx.fill(
                Path(CGRect(x: 0, y: 0, width: W, height: H)),
                with: .linearGradient(
                    Gradient(colors: [baseTop, baseMid, baseBot]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: H)
                )
            )

            let yFront = max(0, min(H, front))
            let wipe = Path(CGRect(x: 0, y: 0, width: W, height: yFront))

            var crest = Path()
            crest.move(to: CGPoint(x: 0, y: yFront))
            crest.addLine(to: CGPoint(x: W, y: yFront))

            ctx.drawLayer { layer in
                layer.fill(
                    wipe,
                    with: .linearGradient(
                        Gradient(colors: [wipeTop, wipeMid, wipeBot]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: min(H, yFront + bandDepth))
                    )
                )

                layer.addFilter(.shadow(color: CyberTheme.neonYellow.opacity(0.18 * strength), radius: 20))
                layer.addFilter(.shadow(color: CyberTheme.neonPurple.opacity(0.12 * strength), radius: 24))
                layer.stroke(
                    crest,
                    with: .color(Color.white.opacity(0.30 * strength)),
                    style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
                )

                let glowH = bandDepth * 0.85
                let glowRect = CGRect(x: 0, y: max(0, yFront - glowH * 0.15), width: W, height: glowH)
                layer.fill(
                    Path(glowRect),
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.10 * strength),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: CGPoint(x: 0, y: glowRect.minY),
                        endPoint: CGPoint(x: 0, y: glowRect.maxY)
                    )
                )

                var lines = Path()
                let lineStep = max(10, Int(H * 0.06))
                for yy in stride(from: 0, through: Int(min(H, yFront + bandDepth)), by: lineStep) {
                    lines.addRect(CGRect(x: 0, y: CGFloat(yy), width: W, height: 1))
                }
                layer.fill(lines, with: .color(Color.white.opacity(0.035 * strength)))
            }
        }
    }
}
