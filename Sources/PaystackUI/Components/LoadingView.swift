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
        VStack(spacing: 32) {
            Text(message)
                .font(.title2)
                .bold()

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(2)
                .padding(.bottom, 24)
        }
        .padding(16)
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
