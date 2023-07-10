import SwiftUI

class ViewVisibilityContainer: ObservableObject {

    @Published
    var showModal: Bool

    var onComplete: (TransactionResult) -> Void

    #if os(iOS)
    var parentViewController: UIViewController?

    init(showModal: Bool = false,
         onComplete: @escaping (TransactionResult) -> Void,
         parentViewController: UIViewController? = nil) {
        self.showModal = showModal
        self.onComplete = onComplete
        self.parentViewController = parentViewController
    }
    #else
    init(showModal: Bool = false,
         onComplete: @escaping (TransactionResult) -> Void) {
        self.showModal = showModal
        self.onComplete = onComplete
    }
    #endif

    func completeAndDismiss(with result: TransactionResult) {
        onComplete(result)
        #if os(iOS)
        if let parentViewController = parentViewController {
            parentViewController.dismiss(animated: true)
        } else {
            showModal = false
        }
        #else
        showModal = false
        #endif
    }

    func cancelAndDismiss() {
        onComplete(.cancelled)
        #if os(iOS)
        if let parentViewController = parentViewController {
            parentViewController.dismiss(animated: true)
        } else {
            showModal = false
        }
        #else
        showModal = false
        #endif
    }
}
