import SwiftUI

@available(iOS 14.0, *)
extension View {

    func paymentSheet<Content: View>(isPresented: Binding<Bool>,
                                     onCloseTapped: @escaping () -> Void,
                                     @ViewBuilder content: @escaping () -> Content) -> some View {
        sheet(isPresented: isPresented) {
            NavigationView {
                content()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            closeButton(with: onCloseTapped)
                        }
                    }
            }
            .preventSheetSwipeDismissal()
            .setSheetHeight()
        }
    }

    private func closeButton(with action: @escaping () -> Void) -> some View {
        Button(action: action) {
            // TODO: Use from Design System
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.gray)
        }
    }

    func setSheetHeight() -> some View {
        if #available(iOS 16, macOS 13.0, *) {
            return presentationDetents([.fraction(0.85)])
        } else {
            // We are maintaining the full modal height on older versions
            return self
        }
    }
}
