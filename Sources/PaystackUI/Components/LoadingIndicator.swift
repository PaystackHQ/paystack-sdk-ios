import SwiftUI

@available(iOS 14.0, *)
struct LoadingIndicator: View {

    var tintColor: Color

    init(tintColor: Color = .white) {
        self.tintColor = tintColor
    }

    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
    }

}

@available(iOS 14.0, *)
struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator(tintColor: .primary)
    }
}
