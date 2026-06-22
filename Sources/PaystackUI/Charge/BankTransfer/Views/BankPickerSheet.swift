import SwiftUI

@available(iOS 14.0, *)
struct BankPickerSheet: View {

    let availableSlugs: [String]
    let currentSlug: String?
    let onSelect: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            header

            Divider()
                .background(Color.navy05)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(availableSlugs, id: \.self) { slug in
                        BankPickerRow(
                            displayName: BankTransferProviderCatalog.displayName(forSlug: slug),
                            isSelected: slug == currentSlug,
                            onTap: { onSelect(slug) })
                        Divider()
                            .background(Color.navy05)
                    }
                }
            }

            Spacer(minLength: 0)
        }
    }

    private var header: some View {
        HStack {
            Text("Change bank")
                .font(.heading3)
                .foregroundColor(.stackBlue)
            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .foregroundColor(.navy02)
            }
        }
        .padding(.doublePadding)
    }
}

@available(iOS 14.0, *)
private struct BankPickerRow: View {

    let displayName: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(displayName)
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.stackGreen)
                }
            }
            .padding(.doublePadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
