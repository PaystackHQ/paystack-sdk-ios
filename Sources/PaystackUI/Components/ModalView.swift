import SwiftUI

class ModalHostingController<Content: View>: UIHostingController<Content>, UIAdaptivePresentationControllerDelegate {
    var canDismissSheet = true
    var onDismissalAttempt: (() -> ())?

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
    let onDismissalAttempt: (() -> ())?

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

extension View {

    func preventSheetSwipeDismissal() -> some View {
        if #available(iOS 15, *) {
            return interactiveDismissDisabled()
        } else {
            return ModalView(
                view: self,
                canDismissSheet: false,
                onDismissalAttempt: nil
            ).edgesIgnoringSafeArea(.all)
        }
    }

}
