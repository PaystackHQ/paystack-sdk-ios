import SwiftUI

class ViewVisibilityContainer<Result>: ObservableObject {

    @Published
    var showChargeCardFlow: Bool

    var onComplete: (Result) -> Void

    #if os(iOS)
    var parentViewController: UIViewController?

    init(showChargeCardFlow: Bool = false,
         onComplete: @escaping (Result) -> Void,
         parentViewController: UIViewController? = nil) {
        self.showChargeCardFlow = showChargeCardFlow
        self.onComplete = onComplete
        self.parentViewController = parentViewController
    }
    #else
    init(showChargeCardFlow: Bool = false,
         onComplete: @escaping (Result) -> Void) {
        self.showChargeCardFlow = showChargeCardFlow
        self.onComplete = onComplete
    }
    #endif


    func completeAndDismiss(with result: Result) {
        onComplete(result)
        #if os(iOS)
        if let parentViewController = parentViewController {
            parentViewController.dismiss(animated: true)
        } else {
            showChargeCardFlow = false
        }
        #else
        showChargeCardFlow = false
        #endif
    }
}
