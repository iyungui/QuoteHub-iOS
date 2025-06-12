import SwiftUI

struct LockAnimationView: View {
    @State private var isLocked = false
    
    var body: some View {
        VStack(spacing: 40) {
            // 메인 잠금 설정 UI
            HStack(spacing: 16) {
                // 자물쇠 아이콘 - 기본적이지만 안정적인 애니메이션
                Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                    .font(.title2)
                    .foregroundColor(.brown)
                    .symbolRenderingMode(.hierarchical)
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(.bounce, value: isLocked)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            isLocked.toggle()
                        }
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("공개 설정")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(isLocked ? "나만 볼 수 있습니다" : "다른 사용자들도 볼 수 있습니다")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .animation(.easeInOut(duration: 0.5), value: isLocked)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .stroke(isLocked ? Color.brown.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.5), value: isLocked)
            
            // 다양한 잠금 애니메이션 효과들
            VStack(spacing: 25) {
                Text("잠금 애니메이션 효과들")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Bounce 효과
                LockEffectRow(
                    title: "Bounce Effect",
                    subtitle: "탭하면 통통 튀는 효과",
                    animationType: .bounce
                )
                
                // Pulse 효과
                LockEffectRow(
                    title: "Pulse Effect",
                    subtitle: "맥박처럼 커졌다 작아짐",
                    animationType: .pulse
                )
                
                // Scale 효과
                LockEffectRow(
                    title: "Scale Effect",
                    subtitle: "크기가 변하며 강조",
                    animationType: .scale
                )
                
                // Wiggle 효과 (iOS 17+)
                if #available(iOS 17.0, *) {
                    LockEffectRow(
                        title: "Wiggle Effect",
                        subtitle: "좌우로 흔들리는 효과",
                        animationType: .wiggle
                    )
                }
                
                // Rotate 효과 (iOS 17+)
                if #available(iOS 17.0, *) {
                    LockEffectRow(
                        title: "Rotate Effect",
                        subtitle: "회전하면서 변화",
                        animationType: .rotate
                    )
                }
                
                // Variable Color 효과 (iOS 17+)
                if #available(iOS 17.0, *) {
                    LockEffectRow(
                        title: "Variable Color",
                        subtitle: "색상이 점진적으로 변화",
                        animationType: .variableColor
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

enum AnimationType {
    case bounce
    case pulse
    case scale
    case wiggle
    case rotate
    case variableColor
}

struct LockEffectRow: View {
    let title: String
    let subtitle: String
    let animationType: AnimationType
    
    @State private var isLocked = false
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // 자물쇠 아이콘
            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                .font(.title2)
                .foregroundColor(lockColor)
                .symbolRenderingMode(.hierarchical)
                .modifier(AnimationModifier(animationType: animationType, isLocked: isLocked, isAnimating: isAnimating))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isLocked.toggle()
                    }
                    triggerAnimation()
                }
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 상태 표시
            Text(isLocked ? "잠김" : "열림")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isLocked ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                )
                .animation(.easeInOut(duration: 0.3), value: isLocked)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.05))
                .stroke(isLocked ? Color.red.opacity(0.2) : Color.green.opacity(0.2), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.5), value: isLocked)
    }
    
    private var lockColor: Color {
        switch animationType {
        case .bounce: return .brown
        case .pulse: return .blue
        case .scale: return .orange
        case .wiggle: return .purple
        case .rotate: return .green
        case .variableColor: return .pink
        }
    }
    
    private func triggerAnimation() {
        switch animationType {
        case .variableColor:
            isAnimating.toggle()
        default:
            break
        }
    }
}

struct AnimationModifier: ViewModifier {
    let animationType: AnimationType
    let isLocked: Bool
    let isAnimating: Bool
    
    func body(content: Content) -> some View {
        switch animationType {
        case .bounce:
            content
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, value: isLocked)
            
        case .pulse:
            content
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.pulse, value: isLocked)
            
        case .scale:
            content
                .contentTransition(.symbolEffect(.replace))
                .scaleEffect(isLocked ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isLocked)
            
        case .wiggle:
            if #available(iOS 17.0, *) {
                if #available(iOS 18.0, *) {
                    content
                        .contentTransition(.symbolEffect(.replace))
                        .symbolEffect(.wiggle, value: isLocked)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                content
                    .contentTransition(.symbolEffect(.replace))
                    .rotationEffect(.degrees(isLocked ? 5 : 0))
                    .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true), value: isLocked)
            }
            
        case .rotate:
            if #available(iOS 17.0, *) {
                if #available(iOS 18.0, *) {
                    content
                        .contentTransition(.symbolEffect(.replace))
                        .symbolEffect(.rotate, value: isLocked)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                content
                    .contentTransition(.symbolEffect(.replace))
                    .rotationEffect(.degrees(isLocked ? 360 : 0))
                    .animation(.easeInOut(duration: 0.6), value: isLocked)
            }
            
        case .variableColor:
            if #available(iOS 17.0, *) {
                content
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(.variableColor, value: isAnimating)
            } else {
                content
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundColor(isLocked ? .red : .green)
                    .animation(.easeInOut(duration: 0.5), value: isLocked)
            }
        }
    }
}

// 커스텀 잠금 애니메이션 뷰
struct CustomLockAnimation: View {
    @State private var isLocked = false
    @State private var rotationAngle: Double = 0
    @State private var showLockEffect = false
    
    var body: some View {
        VStack(spacing: 40) {
            Text("커스텀 잠금 애니메이션")
                .font(.title)
                .fontWeight(.bold)
            
            // 커스텀 애니메이션으로 만든 자물쇠
            ZStack {
                // 자물쇠 몸체
                RoundedRectangle(cornerRadius: 8)
                    .fill(isLocked ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                    .frame(width: 60, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 2)
                    )
                
                // 자물쇠 고리 (회전하는 부분)
                Path { path in
                    path.addArc(
                        center: CGPoint(x: 30, y: 0),
                        radius: 15,
                        startAngle: .degrees(180),
                        endAngle: .degrees(0),
                        clockwise: false
                    )
                }
                .stroke(isLocked ? Color.red.opacity(0.8) : Color.green.opacity(0.8), lineWidth: 4)
                .frame(width: 60, height: 40)
                .rotationEffect(.degrees(rotationAngle))
                .animation(.easeInOut(duration: 0.8), value: rotationAngle)
                
                // 키홀
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .offset(y: 5)
            }
            .scaleEffect(showLockEffect ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: showLockEffect)
            .onTapGesture {
                performLockAnimation()
            }
            
            Text(isLocked ? "잠김 상태" : "열림 상태")
                .font(.headline)
                .foregroundColor(isLocked ? .red : .green)
                .animation(.easeInOut, value: isLocked)
            
            Button("잠금 토글") {
                performLockAnimation()
            }
            .buttonStyle(.borderedProminent)
            .tint(isLocked ? .red : .green)
        }
        .padding()
    }
    
    private func performLockAnimation() {
        withAnimation(.easeInOut(duration: 0.8)) {
            if isLocked {
                // 잠금 해제: 고리를 올림
                rotationAngle = -30
                isLocked = false
            } else {
                // 잠금: 고리를 내림
                rotationAngle = 0
                isLocked = true
            }
        }
        
        // 시각적 피드백
        showLockEffect = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showLockEffect = false
        }
    }
}

#Preview {
    TabView {
        LockAnimationView()
            .tabItem {
                Label("기본 효과", systemImage: "lock")
            }
        
        CustomLockAnimation()
            .tabItem {
                Label("커스텀", systemImage: "lock.rotation")
            }
    }
}
