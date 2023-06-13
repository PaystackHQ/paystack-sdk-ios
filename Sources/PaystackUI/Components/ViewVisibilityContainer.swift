import SwiftUI

class ViewVisibilityContainer<Result>: ObservableObject {

    @Published
    var showModal: Bool

    var onComplete: (Result) -> Void

    #if os(iOS)
    var parentViewController: UIViewController?

    init(showModal: Bool = false,
         onComplete: @escaping (Result) -> Void,
         parentViewController: UIViewController? = nil) {
        self.showModal = showModal
        self.onComplete = onComplete
        self.parentViewController = parentViewController
    }
    #else
    init(showModal: Bool = false,
         onComplete: @escaping (Result) -> Void) {
        self.showModal = showModal
        self.onComplete = onComplete
    }
    #endif

    func completeAndDismiss(with result: Result) {
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
}
