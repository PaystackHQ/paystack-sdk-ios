import SwiftUI

@available(iOS 14.0, *)
struct AccountDetailRow: View {

    enum Trailing {
        case none
        case copy
        case text(String, () -> Void)
    }

    let label: String
    let value: String
    let trailing: Trailing

    @State private var justCopied = false

    init(label: String, value: String, trailing: Trailing = .none) {
        self.label = label
        self.value = value
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .center, spacing: .doublePadding) {
            VStack(alignment: .leading, spacing: .quarterPadding) {
                Text(label)
                    .font(.body12M)
                    .foregroundColor(.navy03)
                    .padding(.bottom, .singlePadding)
                Text(value)
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
            }
            Spacer()
            trailingView
        }
        .padding(.doublePadding)
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .none:
            EmptyView()
        case .copy:
            #if os(iOS)
            Button(action: copy) {
                Image(systemName: justCopied ? "checkmark" : "doc.on.doc")
                    .foregroundColor(justCopied ? .stackGreen : .navy02)
            }
            #else
            EmptyView()
            #endif
        case .text(let title, let action):
            Button(title, action: action)
                .font(.body14M)
                .foregroundColor(.stackGreen)
        }
    }

    #if os(iOS)
    private func copy() {
        UIPasteboard.general.string = value
        withAnimation { justCopied = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                withAnimation { justCopied = false }
            }
        }
    }
    #endif
}
