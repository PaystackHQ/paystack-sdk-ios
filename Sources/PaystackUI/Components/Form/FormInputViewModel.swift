import Foundation

class FormInputViewModel: ObservableObject {

    @Published
    var showLoading = false

    var action: (@escaping () -> Void) -> Void

    init(action: @escaping (@escaping () -> Void) -> Void) {
        self.action = action
    }

    func submit() {
        showLoading = true
        action { [self] in
            showLoading = false
        }
    }

}
