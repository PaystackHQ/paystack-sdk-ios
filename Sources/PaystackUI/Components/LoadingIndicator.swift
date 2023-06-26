import SwiftUI

@available(iOS 14.0, *)
public struct LoadingIndicator: View {

    var tintColor: Color

    public init(tintColor: Color = .white) {
        self.tintColor = tintColor
    }

    public var body: some View {
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
