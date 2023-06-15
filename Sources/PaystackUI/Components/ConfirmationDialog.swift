import SwiftUI

@available(iOS 14.0, *)
extension View {

    func confirmationDialog(title: String, isPresented: Binding<Bool>,
                            confirmationText: String,
                            onConfirmation: @escaping () -> Void) -> some View {
        if #available(iOS 15, macOS 12.0, *) {
            return confirmationDialog(title, isPresented: isPresented, titleVisibility: .visible) {
                Button(confirmationText, role: .destructive, action: onConfirmation)
                Button("Cancel", role: .cancel) {}
            }
        } else {
            #if os(iOS)
            return legacyiOSDialog(title: title, isPresented: isPresented,
                                   confirmationText: confirmationText,
                                   onConfirmation: onConfirmation)
            #else
            return legacyMacOSDialog(title: title, isPresented: isPresented,
                                     confirmationText: confirmationText,
                                     onConfirmation: onConfirmation)
            #endif
        }
    }

    #if os(iOS)
    private func legacyiOSDialog(title: String, isPresented: Binding<Bool>,
                                 confirmationText: String,
                                 onConfirmation: @escaping () -> Void) -> some View {
        return actionSheet(isPresented: isPresented) {
            ActionSheet(
                title: Text(title),
                buttons: [
                    .destructive(
                        Text(confirmationText),
                        action: onConfirmation),
                    .cancel()
                ]
            )
        }
    }
    #endif

    private func legacyMacOSDialog(title: String, isPresented: Binding<Bool>,
                                   confirmationText: String,
                                   onConfirmation: @escaping () -> Void) -> some View {
        alert(isPresented: isPresented) {
            Alert(
                title: Text(title),
                primaryButton: .cancel(),
                secondaryButton: .destructive(
                    Text(confirmationText),
                    action: onConfirmation
                )
            )
        }
    }
}
