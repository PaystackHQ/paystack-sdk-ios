import SwiftUI

@available(iOS 14.0, *)
struct CapitecPayInfoBanner: View {

    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: .singlePadding) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.stackBlue)
            Text(text)
                .font(.body14R)
                .foregroundColor(.stackBlue)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.doublePadding)
        .background(Color.stackBlue.opacity(0.08))
        .cornerRadius(.cornerRadius)
    }
}
