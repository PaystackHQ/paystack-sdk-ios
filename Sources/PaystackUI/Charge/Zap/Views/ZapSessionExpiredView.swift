import SwiftUI

@available(iOS 14.0, *)
struct ZapSessionExpiredView: View {

    let message: String
    let onTryAgain: () async -> Void

    var body: some View {
        VStack(spacing: .triplePadding) {

            Image.errorIcon

            Text("Session expired")
                .font(.heading2)
                .foregroundColor(.stackBlue)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body14R)
                .foregroundColor(.navy02)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .singlePadding)

            Button("Try again") {
                Task { await onTryAgain() }
            }
            .buttonStyle(PrimaryButtonStyle(showLoading: false))
        }
        .padding(.doublePadding)
    }
}

@available(iOS 14.0, *)
struct ZapSessionExpiredView_Previews: PreviewProvider {
    static var previews: some View {
        ZapSessionExpiredView(
            message: ZapViewModel.sessionExpiredCopy,
            onTryAgain: {})
    }
}
