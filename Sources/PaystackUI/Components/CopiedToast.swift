import SwiftUI

@available(iOS 14.0, *)
struct CopiedToast: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.body14M)
            .foregroundColor(.contentOnAccent)
            .padding(.horizontal, .doublePadding)
            .padding(.vertical, .singlePadding)
            .background(Color.toastSurface)
            .cornerRadius(.cornerRadius)
    }
}

@available(iOS 14.0, *)
struct CopiedToastModifier: ViewModifier {

    @Binding var isPresented: Bool
    let text: String
    let dwellSeconds: Double

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if isPresented {
                CopiedToast(text: text)
                    .padding(.bottom, .doublePadding)
                    .transition(.opacity)
                    .onAppear {
                        Task {
                            try? await Task.sleep(
                                nanoseconds: UInt64(dwellSeconds * 1_000_000_000))
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isPresented = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

@available(iOS 14.0, *)
extension View {
    func copiedToast(isPresented: Binding<Bool>,
                     text: String = "Copied",
                     dwellSeconds: Double = 1.5) -> some View {
        modifier(CopiedToastModifier(isPresented: isPresented,
                                     text: text,
                                     dwellSeconds: dwellSeconds))
    }
}
