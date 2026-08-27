import SwiftUI

@available(iOS 14.0, *)
struct CapitecPayInfoBanner: View {

    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: .singlePadding) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.contentPrimary)
            Text(text)
                .font(.body14R)
                .foregroundColor(.contentPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.doublePadding)
        .background(Color.infoSurface)
        .cornerRadius(.cornerRadius)
    }
}
