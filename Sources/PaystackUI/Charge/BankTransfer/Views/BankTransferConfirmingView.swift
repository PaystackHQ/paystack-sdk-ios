import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 14.0, *)
struct BankTransferConfirmingView: View {

    let details: BankTransferDetails

    let phase: ConfirmingPhase

    let confirmationWindowSeconds: Int
    let elapsedSeconds: Int
    let onBackToAccountNumber: () -> Void
    let onChangePaymentMethod: () -> Void

    private var receivedByBackend: Bool {
        phase == .transferOnTheWay
    }

    private var bodyCopy: String {
        switch phase {
        case .waitingForCredit:
            return "We're waiting to confirm your transfer. This can take a few minutes"
        case .transferOnTheWay:
            return "Your transfer is on the way…"
        }
    }

    private var remainingSeconds: Int {
        max(0, confirmationWindowSeconds - elapsedSeconds)
    }

    private var formattedRemaining: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: .triplePadding) {

            Text(bodyCopy)
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.25), value: phase)

            timeline

            Button("Please wait \(formattedRemaining) minutes", action: {})
                .buttonStyle(PrimaryButtonStyle(showLoading: false))
                .disabled(true)

            Button("Back to account number", action: onBackToAccountNumber)
                .foregroundColor(.navy02)
                .font(.body14M)

            Button("Change payment method", action: onChangePaymentMethod)
                .foregroundColor(.navy02)
                .font(.body14M)
        }
        .padding(.doublePadding)
        .onChange(of: phase) { newPhase in
            guard newPhase == .transferOnTheWay else { return }
            triggerReceivedHaptic()
        }
    }

    private func triggerReceivedHaptic() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    // MARK: - Subviews

    private var timeline: some View {
        HStack(spacing: 0) {
            TimelineNode(label: "Sent", state: .complete)
            connectingLine
                .padding(.horizontal, .singlePadding)
            TimelineNode(label: "Received",
                         state: receivedByBackend ? .complete : .pending)
        }
        .padding(.horizontal, .triplePadding)
    }

    private var connectingLine: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray01)
                    .frame(height: 1)
                Rectangle()
                    .fill(Color.stackGreen)
                    .frame(width: receivedByBackend ? geo.size.width : 0,
                           height: 1)
                    .animation(.easeInOut(duration: 0.45), value: receivedByBackend)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 1)
    }
}
