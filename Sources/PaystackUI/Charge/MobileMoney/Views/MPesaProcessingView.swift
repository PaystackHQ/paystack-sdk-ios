import SwiftUI

@available(iOS 14.0, *)
struct MPesaProcessingView: View {

    @StateObject
    var viewModel: MPesaProcessingViewModel

    init(chargeCardContainer: ChargeContainer,
         transactionDetails: VerifyAccessCode,
         mobileMoneyTransaction: MobileMoneyTransaction) {
        self._viewModel = StateObject(wrappedValue: MPesaProcessingViewModel(transactionDetails: transactionDetails,
                                                                             chargeCardContainer: chargeCardContainer,
                                                                             mobileMoneyTransaction: mobileMoneyTransaction))
    }

    var body: some View {

        VStack(spacing: .triplePadding) {

            Image.otpIcon
            Text(viewModel.mobileMoneyTransaction.phone)
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)

            Text("Please enter your pin on your phone to complete this payment")
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)

            CountdownView(counter: $viewModel.counter,
                          countTo: viewModel.mobileMoneyTransaction.timer,
                          action: viewModel.checkTransactionStatus)
        }
        .padding(.doublePadding)
        .task(viewModel.initializeMPesaAuthorization)
    }
}

#Preview {
    CountdownView(counter: Binding.constant(0))
}

let timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

struct Clock: View {
    var counter: Int
    var countTo: Int

    var body: some View {
        VStack {
            Image.messageBubbleLogo

        }
    }
}

struct ProgressTrack: View {
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 35, height: 35)
            .overlay(
                Circle().stroke(Color.gray01, lineWidth: 5)
            )
    }
}

struct ProgressBar: View {
    var counter: Int
    var countTo: Int

    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 35, height: 35)
            .overlay(
                Circle().trim(from: 0, to: progress())
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .foregroundColor(
                        (completed() ? Color.stackGreen : Color.stackGreen)
                    ).animation(
                        .easeInOut(duration: 0.2)
                    )
            )
    }

    func completed() -> Bool {
        return progress() == 1
    }

    func progress() -> CGFloat {
        return (CGFloat(counter) / CGFloat(countTo))
    }
}

struct CountdownView: View {
    @Binding var counter: Int
    var countTo: Int = 60
    var action: () -> Void = {}
    var body: some View {
        VStack {
            ZStack {
                ProgressTrack()
                ProgressBar(counter: counter, countTo: countTo)
                Clock(counter: counter, countTo: countTo)
            }
            Text("Payment is valid for \(counterToMinutes())")
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)
        }.onReceive(timer) { _ in
            if self.counter < self.countTo {
                self.counter += 1
            } else if self.counter == self.countTo {
                action()
            }
        }
    }

    func counterToMinutes() -> String {
        let currentTime = countTo - counter
        let seconds = currentTime % 60
        let minutes = Int(currentTime / 60)
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}
