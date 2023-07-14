import SwiftUI

@available(iOS 14.0, *)
struct ChargeCardView: View {

    @StateObject
    var viewModel: ChargeCardViewModel

    init(amountDetails: AmountCurrency) {
        self._viewModel = StateObject(wrappedValue: ChargeCardViewModel(amountDetails: amountDetails))
    }

    var body: some View {
        switch viewModel.chargeCardState {
        case .cardDetails(let amount):
            CardDetailsView(amountDetails: amount)
        }
    }

}
