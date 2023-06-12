import SwiftUI

#if os(iOS)
class ModalHostingController<Content: View>: UIHostingController<Content>, UIAdaptivePresentationControllerDelegate {
    var canDismissSheet = true
    var onDismissalAttempt: (() -> Void)?

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        parent?.presentationController?.delegate = self
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        canDismissSheet
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        onDismissalAttempt?()
    }
}

struct ModalView<T: View>: UIViewControllerRepresentable {
    let view: T
    let canDismissSheet: Bool
    let onDismissalAttempt: (() -> Void)?

    func makeUIViewController(context: Context) -> ModalHostingController<T> {
        let controller = ModalHostingController(rootView: view)

        controller.canDismissSheet = canDismissSheet
        controller.onDismissalAttempt = onDismissalAttempt

        return controller
    }

    func updateUIViewController(_ uiViewController: ModalHostingController<T>, context: Context) {
        uiViewController.rootView = view

        uiViewController.canDismissSheet = canDismissSheet
        uiViewController.onDismissalAttempt = onDismissalAttempt
    }
}
#endif

extension View {

    func preventSheetSwipeDismissal() -> some View {
        #if os(iOS)
        if #available(iOS 15, *) {
            return interactiveDismissDisabled()
        } else {
            return ModalView(
                view: self,
                canDismissSheet: false,
                onDismissalAttempt: nil
            ).edgesIgnoringSafeArea(.all)
        }
        #else
        return self
        #endif
    }

}
