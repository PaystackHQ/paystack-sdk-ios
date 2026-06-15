import SwiftUI

@available(iOS 14.0, *)
struct ChangePaymentMethodFooter: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: .singlePadding) {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Change payment method")
            }
            .font(.body14M)
            .foregroundColor(.navy02)
            .padding(.horizontal, .doublePadding)
            .padding(.vertical, .singlePadding)
            .overlay(
                Capsule().stroke(Color.navy05, lineWidth: 1)
            )
        }
        .padding(.bottom, .doublePadding)
    }
}
