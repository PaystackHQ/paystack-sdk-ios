import SwiftUI

@available(iOS 14.0, *)
struct TimelineNode: View {

    enum NodeState: Equatable {
        case complete
        case pending
    }

    let label: String
    let state: NodeState

    private let diameter: CGFloat = 28

    @State private var nodeScale: CGFloat = 1.0
    @State private var checkmarkScale: CGFloat = 1.0
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0

    var body: some View {
        VStack(spacing: .singlePadding) {
            ZStack {
                Circle()
                    .stroke(Color.stackGreen, lineWidth: 2)
                    .frame(width: diameter, height: diameter)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)

                switch state {
                case .complete:
                    Circle()
                        .fill(Color.stackGreen)
                        .frame(width: diameter, height: diameter)
                        .scaleEffect(nodeScale)
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                        .scaleEffect(checkmarkScale)
                case .pending:
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                        .foregroundColor(.gray01)
                        .frame(width: diameter, height: diameter)
                }
            }
            Text(label)
                .font(.body12M)
                .foregroundColor(state == .complete ? .stackGreen : .navy03)
                .animation(.easeInOut(duration: 0.2), value: state)
        }
        .onChange(of: state) { newState in
            guard newState == .complete else { return }
            playCompletionAnimation()
        }
    }

    private func playCompletionAnimation() {
        nodeScale = 0.4
        checkmarkScale = 0.0
        rippleScale = 1.0
        rippleOpacity = 0.7

        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            nodeScale = 1.0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.55).delay(0.12)) {
            checkmarkScale = 1.0
        }
        withAnimation(.easeOut(duration: 0.8)) {
            rippleScale = 2.4
            rippleOpacity = 0.0
        }
    }
}
