import SwiftUI

@available(iOS 14.0, *)
extension View {

    func paymentSheet<Content: View>(isPresented: Binding<Bool>,
                                     @ViewBuilder content: @escaping () -> Content) -> some View {
        sheet(isPresented: isPresented) {
            content()
                .preventSheetSwipeDismissal()
                .setSheetHeight()
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
