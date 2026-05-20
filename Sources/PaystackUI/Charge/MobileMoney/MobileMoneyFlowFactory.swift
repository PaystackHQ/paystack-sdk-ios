import SwiftUI

@available(iOS 14.0, *)
enum MobileMoneyFlowFactory {

    @ViewBuilder
    static func view(for provider: MobileMoneyChannel,
                     chargeContainer: ChargeContainer,
                     transactionDetails: VerifyAccessCode) -> some View {
        
        MobileMoneyChargeView(chargeCardContainer: chargeContainer,
                              transactionDetails: transactionDetails,
                              provider: provider)
    }
}
