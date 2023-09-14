import SwiftUI

@available(iOS 14.0, *)
struct CardRedirectView: View {

    let urlString: String

    @StateObject
    var viewModel: CardRedirectViewModel

    init(urlString: String,
         transactionId: Int,
         chargeCardContainer: ChargeCardContainer) {
        self.urlString = urlString
        self._viewModel = StateObject(wrappedValue: CardRedirectViewModel(
            transactionId: transactionId, chargeCardContainer: chargeCardContainer))
    }

    var body: some View {
        WebView(url: URL(string: urlString))
            .task(viewModel.awaitAuthenticationResponse)
    }
}
