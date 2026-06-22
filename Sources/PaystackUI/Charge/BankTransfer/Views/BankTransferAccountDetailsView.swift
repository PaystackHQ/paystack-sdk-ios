import SwiftUI

@available(iOS 14.0, *)
struct BankTransferAccountDetailsView: View {

    let details: BankTransferDetails
    let amount: AmountCurrency
    let onChangeBank: (() -> Void)?
    let onIveSentTheMoney: () async -> Void

    @State private var provisionedAt: Date = Date()
    @State private var now: Date = Date()

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(details: BankTransferDetails,
         amount: AmountCurrency,
         onChangeBank: (() -> Void)? = nil,
         onIveSentTheMoney: @escaping () async -> Void) {
        self.details = details
        self.amount = amount
        self.onChangeBank = onChangeBank
        self.onIveSentTheMoney = onIveSentTheMoney
    }

    var body: some View {
        VStack(spacing: .triplePadding) {

            Text("Transfer exactly \(amount.description) to")
                .font(.heading3)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)

            accountCard

            expiryFooter

            Button("I've sent the money", action: { Task { await onIveSentTheMoney() } })
                .buttonStyle(PrimaryButtonStyle(showLoading: false))

        }
        .padding(.doublePadding)
        .onReceive(tick) { newNow in
            self.now = newNow
        }
    }

    private var accountCard: some View {
        VStack(spacing: 0) {
            AccountDetailRow(label: "BANK NAME",
                             value: details.bankName,
                             trailing: bankNameTrailing)
            divider
            AccountDetailRow(label: "ACCOUNT NUMBER",
                             value: details.accountNumber,
                             trailing: .copy)
            divider
            AccountDetailRow(label: "AMOUNT",
                             value: amount.description,
                             trailing: .copy)
        }
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadius)
                .stroke(Color.navy05, lineWidth: 1)
        )
    }

    private var bankNameTrailing: AccountDetailRow.Trailing {
        if let handler = onChangeBank {
            return .text("Change bank", handler)
        }
        return .none
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.navy05)
            .frame(height: 1)
    }

    private var expiryFooter: some View {
        VStack(spacing: .singlePadding) {
                Text("This account is for one-time use only and expires in")
                    .font(.body14R)
                    .foregroundColor(.navy03)
                    .multilineTextAlignment(.center)
                Text(formattedRemaining)
                    .font(.body14M)
                    .foregroundColor(.stackGreen)

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .accentColor(.stackGreen)
        }
    }

    private var remainingSeconds: Int {
        max(0, Int(details.accountExpiresAt.timeIntervalSince(now)))
    }

    private var formattedRemaining: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var progress: Double {
        let total = details.accountExpiresAt.timeIntervalSince(provisionedAt)
        guard total > 0 else { return 0 }
        let elapsed = max(0, now.timeIntervalSince(provisionedAt))
        return min(1.0, elapsed / total)
    }
}
