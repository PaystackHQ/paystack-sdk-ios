import SwiftUI

@available(iOS 14.0, *)
struct BankTransferAccountDetailsView: View {

    let details: BankTransferDetails
    let amount: AmountCurrency
    let provider: BankTransferProvider
    let onIveSentTheMoney: () async -> Void
    let onChangePaymentMethod: () -> Void

    @Environment(\.displayAudience)
    private var displayAudience

    @State private var provisionedAt: Date = Date()
    @State private var now: Date = Date()

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(details: BankTransferDetails,
         amount: AmountCurrency,
         provider: BankTransferProvider,
         onIveSentTheMoney: @escaping () async -> Void,
         onChangePaymentMethod: @escaping () -> Void) {
        self.details = details
        self.amount = amount
        self.provider = provider
        self.onIveSentTheMoney = onIveSentTheMoney
        self.onChangePaymentMethod = onChangePaymentMethod
    }

    var body: some View {
        VStack(spacing: .triplePadding) {

            Text("Transfer exactly \(amount.description) to")
                .font(.heading3)
                .foregroundColor(.contentPrimary)
                .multilineTextAlignment(.center)

            accountCard

            expiryFooter

            Button("I've sent the money", action: { Task { await onIveSentTheMoney() } })
                .buttonStyle(PrimaryButtonStyle(showLoading: false))

            Button("Change payment method", action: onChangePaymentMethod)
                .foregroundColor(.contentSecondary)
                .font(.body14M)
                .padding(.top, .singlePadding)
        }
        .padding(.doublePadding)
        .onReceive(tick) { newNow in
            self.now = newNow
        }
    }

    private var copyTrailing: AccountDetailRow.Trailing {
        displayAudience.shows(.bankTransferCopyButtons) ? .copy : .none
    }

    private var accountCard: some View {
        VStack(spacing: 0) {
            AccountDetailRow(label: "BANK NAME",
                             value: details.bankName)
            divider
            AccountDetailRow(label: "ACCOUNT NUMBER",
                             value: details.accountNumber,
                             trailing: copyTrailing)
            divider
            AccountDetailRow(label: "AMOUNT",
                             value: amount.description,
                             trailing: copyTrailing)

            if provider == .pesalink {
                divider
                AccountDetailRow(label: "NARRATION / REASON",
                                 value: details.transactionReference,
                                 trailing: copyTrailing)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadius)
                .stroke(Color.borderPrimary, lineWidth: 1)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.surfaceSecondary)
            .frame(height: 1)
    }

    private var expiryFooter: some View {
        VStack(spacing: .singlePadding) {
                Text("This account is for one-time use only and expires in")
                    .font(.body14R)
                    .foregroundColor(.contentTertiary)
                    .multilineTextAlignment(.center)
                Text(formattedRemaining)
                    .font(.body14M)
                    .foregroundColor(.accentPrimary)

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .accentColor(.accentPrimary)
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

@available(iOS 14.0, *)
struct BankTransferAccountDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BankTransferAccountDetailsView(
                details: .example,
                amount: AmountCurrency(amount: 1000000, currency: "NGN"),
                provider: .standard,
                onIveSentTheMoney: {},
                onChangePaymentMethod: {})
                .environment(\.displayAudience, .customerFacing)
                .previewDisplayName("Customer-facing — copy buttons")

            BankTransferAccountDetailsView(
                details: .example,
                amount: AmountCurrency(amount: 1000000, currency: "NGN"),
                provider: .standard,
                onIveSentTheMoney: {},
                onChangePaymentMethod: {})
                .environment(\.displayAudience, .merchantFacing)
                .previewDisplayName("Merchant-facing — no copy buttons")
        }
    }
}
