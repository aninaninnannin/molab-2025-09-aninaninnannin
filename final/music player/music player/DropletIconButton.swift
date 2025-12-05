import SwiftUI

struct DropletIconButton: View {
    let systemName: String
    let size: CGFloat
    let isPrimary: Bool
    let isBreathing: Bool
    let action: () -> Void

    @State private var pressed = false
    @State private var rippleProgress: CGFloat = 1
    @State private var showRipple: Bool = false

    private var neonStroke: LinearGradient { CyberTheme.neonStrokeV }

    private func triggerRipple() {
        rippleProgress = 0
        showRipple = true
        withAnimation(.easeOut(duration: 0.55)) {
            rippleProgress = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) {
            showRipple = false
        }
    }

    var body: some View {
        Button {
            Haptics.tap()
            triggerRipple()
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity((isPrimary ? CyberTheme.glassFillPrimary : CyberTheme.glassFillSecondary) - (pressed ? 0.05 : 0.0)))
                    .blur(radius: pressed ? 0.35 : 0)
                    .overlay(
                        Circle()
                            .stroke(neonStroke, lineWidth: isPrimary ? 1.6 : 1.2)
                            .shadow(color: CyberTheme.neonYellow.opacity(isPrimary ? 0.55 : 0.38), radius: isPrimary ? 14 : 10)
                            .shadow(color: CyberTheme.neonPurple.opacity(isPrimary ? 0.35 : 0.22), radius: isPrimary ? 18 : 12)
                    )
                    .overlay(
                        Capsule()
                            .fill(Color.white.opacity(0.14))
                            .frame(width: isPrimary ? 22 : 18, height: isPrimary ? 48 : 40)
                            .rotationEffect(.degrees(-18))
                            .offset(x: -10, y: -16)
                            .blur(radius: 8)
                            .mask(Circle())
                    )
                    .overlay(
                        DropletCaustics(intensity: isPrimary ? 1.0 : 0.85)
                            .opacity(0.85)
                            .mask(Circle())
                    )
                    .overlay(
                        Circle()
                            .stroke(neonStroke, lineWidth: 2)
                            .opacity(showRipple ? Double(1 - rippleProgress) : 0)
                            .scaleEffect(0.20 + rippleProgress * 1.35)
                            .blur(radius: 0.4)
                            .mask(Circle())
                    )
                    .overlay(
                        TimelineView(.animation) { timeline in
                            let t = timeline.date.timeIntervalSinceReferenceDate
                            let pulse = isBreathing ? (0.5 + 0.5 * sin(t * 2 * Double.pi / 0.9)) : 0
                            let strength = isBreathing ? (0.35 + 0.65 * pulse) : 0

                            ZStack {
                                Circle()
                                    .stroke(neonStroke, lineWidth: isPrimary ? 5.0 : 3.5)
                                    .opacity(strength * 0.85)
                                    .blur(radius: 2.5 + 6.5 * pulse)
                                    .blendMode(.screen)

                                Circle()
                                    .stroke(neonStroke, lineWidth: isPrimary ? 3.0 : 1.8)
                                    .opacity(isBreathing ? (0.55 + 0.45 * pulse) : 0)
                                    .shadow(color: CyberTheme.neonYellow.opacity(0.55 + 0.45 * pulse), radius: 18 + 18 * pulse)
                                    .shadow(color: CyberTheme.neonPurple.opacity(0.35 + 0.35 * pulse), radius: 22 + 22 * pulse)
                                    .blendMode(.screen)

                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                CyberTheme.neonYellow.opacity(0.22 + 0.32 * pulse),
                                                CyberTheme.neonPurple.opacity(0.14 + 0.22 * pulse),
                                                Color.clear
                                            ]),
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: isPrimary ? 90 : 70
                                        )
                                    )
                                    .opacity(isBreathing ? 1 : 0)
                                    .blendMode(.screen)
                            }
                            .compositingGroup()
                        }
                    )

                Image(systemName: systemName)
                    .font(.system(size: size, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: CyberTheme.neonYellow.opacity(0.35), radius: 10)
            }
            .frame(width: isPrimary ? 78 : 62, height: isPrimary ? 78 : 62)
            .scaleEffect(x: pressed ? 0.96 : 1.0, y: pressed ? 0.90 : 1.0)
            .offset(y: pressed ? 1 : 0)
            .opacity(pressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.65), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}

private struct DropletCaustics: View {
    var intensity: Double

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                AngularGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.0),
                        CyberTheme.neonYellow.opacity(0.22 * intensity),
                        .white.opacity(0.0),
                        CyberTheme.neonPurple.opacity(0.16 * intensity),
                        .white.opacity(0.0)
                    ]),
                    center: .center
                )
                .rotationEffect(.radians(t * 0.55))
                .blur(radius: 10)
                .blendMode(.screen)

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.18 * intensity),
                        Color.white.opacity(0.0)
                    ]),
                    center: .topLeading,
                    startRadius: 8,
                    endRadius: 120
                )
                .offset(
                    x: -10 + CGFloat(sin(t * 1.05)) * 7,
                    y: -14 + CGFloat(cos(t * 0.95)) * 7
                )
                .blur(radius: 8)
                .blendMode(.screen)

                LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.0),
                        CyberTheme.neonYellow.opacity(0.12 * intensity),
                        .white.opacity(0.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.radians(t * 0.18))
                .blur(radius: 10)
                .blendMode(.screen)
            }
            .compositingGroup()
        }
    }
}
