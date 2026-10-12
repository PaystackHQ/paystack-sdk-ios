import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 14.0, *)
struct ScanToPayAppPickerView: View {

    let qrCode: String
    let onBack: () -> Void

    @State private var openFailedMessage: String?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: .doublePadding), count: 3)

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {

                Text("Choose your Scan to Pay app")
                    .font(.body16M)
                    .foregroundColor(.contentPrimary)
                    .multilineTextAlignment(.center)

                if let message = openFailedMessage {
                    Text(message)
                        .font(.body14M)
                        .foregroundColor(.contentWarning)
                        .multilineTextAlignment(.center)
                        .padding(.singlePadding)
                        .frame(maxWidth: .infinity)
                        .background(Color.warningSurface)
                        .cornerRadius(.cornerRadius)
                }

                LazyVGrid(columns: columns, spacing: .triplePadding) {
                    ForEach(ScanToPayAppDirectory.apps) { app in
                        Button(action: { open(app) }) {
                            ScanToPayAppCell(app: app)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                Button("Back", action: onBack)
                    .foregroundColor(.contentSecondary)
                    .font(.body14M)
                    .padding(.top, .singlePadding)
            }
            .padding(.doublePadding)
        }
    }

    private func open(_ app: ScanToPayApp) {
        openFailedMessage = nil
        let failedMessage = ScanToPayAppDirectory.openFailedMessage(appName: app.name)
        guard let url = app.deeplink(for: qrCode) else {
            openFailedMessage = failedMessage
            return
        }
        #if canImport(UIKit)
        UIApplication.shared.open(url, options: [:]) { success in
            guard !success else { return }
            DispatchQueue.main.async {
                openFailedMessage = failedMessage
            }
        }
        #endif
    }
}

@available(iOS 14.0, *)
private struct ScanToPayAppCell: View {

    let app: ScanToPayApp

    private let iconSize: CGFloat = 64

    var body: some View {
        VStack(spacing: .singlePadding) {
            icon
                .frame(width: iconSize, height: iconSize)
                .cornerRadius(.cornerRadius)

            Text(app.name)
                .font(.body14R)
                .foregroundColor(.contentPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var icon: some View {
        if let image = bundledIcon {
            image
                .resizable()
                .scaledToFit()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .fill(Color.surfaceTertiary)
                Text(app.initials)
                    .font(.body16M)
                    .foregroundColor(.contentSecondary)
            }
        }
    }

    private var bundledIcon: Image? {
        #if canImport(UIKit)
        guard let image = UIImage(named: app.iconAsset, in: .current, compatibleWith: nil) else {
            return nil
        }
        return Image(uiImage: image)
        #else
        return nil
        #endif
    }
}

@available(iOS 14.0, *)
struct ScanToPayAppPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ScanToPayAppPickerView(qrCode: "1490884538", onBack: {})
            .previewDisplayName("Scan to Pay app picker — placeholder icons")
    }
}
