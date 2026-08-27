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
                .background(Color.borderPrimary)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(availableSlugs, id: \.self) { slug in
                        BankPickerRow(
                            displayName: BankTransferProviderCatalog.displayName(forSlug: slug),
                            isSelected: slug == currentSlug,
                            onTap: { onSelect(slug) })
                        Divider()
                            .background(Color.borderPrimary)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfacePrimary.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Text("Change bank")
                .font(.heading3)
                .foregroundColor(.contentPrimary)
            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .foregroundColor(.contentSecondary)
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
                    .foregroundColor(.contentPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentPrimary)
                }
            }
            .padding(.doublePadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
