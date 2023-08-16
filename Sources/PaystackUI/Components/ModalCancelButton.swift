import SwiftUI

@available(iOS 14.0, *)
struct ModalCancelButton: ViewModifier {

    @State
    var confirmationDialogDisplayed = false

    var displayConfirmationDialog: Bool
    var onCancellation: () -> Void

    init(displayConfirmationDialog: Bool,
         onCancellation: @escaping () -> Void) {
        self.displayConfirmationDialog = displayConfirmationDialog
        self.onCancellation = onCancellation
    }

    func body(content: Content) -> some View {
        NavigationView {
            content
                .confirmationDialog(title: "Do you want to abort this transaction?",
                                    isPresented: $confirmationDialogDisplayed,
                                    confirmationText: "Abort Transaction",
                                    onConfirmation: onCancellation)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        closeButton
                    }
                }
        }

    }

    private var closeButton: some View {
        Button(action: closeButtonTapped) {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.gray01)
        }
    }

    private func closeButtonTapped() {
        if displayConfirmationDialog {
            confirmationDialogDisplayed = true
        } else {
            onCancellation()
        }
    }
}

@available(iOS 14.0, *)
extension View {

    @ViewBuilder
    func modalCancelButton(shouldDisplay: Bool = true,
                           showConfirmation: Bool = true,
                           onCancelled: @escaping () -> Void) -> some View {
        if shouldDisplay {
            self.modifier(ModalCancelButton(displayConfirmationDialog: showConfirmation,
                                            onCancellation: onCancelled))
        } else {
            self
        }
    }

}
