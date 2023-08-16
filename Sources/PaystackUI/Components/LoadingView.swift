import SwiftUI

@available(iOS 14.0, *)
struct LoadingView: View {

    let message: String

    init(message: String?) {
        self.message = message ?? "Just a moment..."
    }

    init() {
        self.message = "Just a moment..."
    }

    var body: some View {
        VStack(spacing: .quadPadding) {
            Text(message)
                .font(.body16M)
                .foregroundColor(.stackBlue)

            LoadingIndicator(tintColor: .navy04)
                .scaleEffect(2)
                .padding(.bottom, .triplePadding)
        }
        .padding(.doublePadding)
    }
}

@available(iOS 14.0, *)
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LoadingView()

            Spacer()
        }

    }
}
