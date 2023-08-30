import Foundation

class FormInputViewModel: ObservableObject {

    @Published
    var showLoading = false

    var action: () async -> Void

    init(action: @escaping () async -> Void) {
        self.action = action
    }

    @MainActor
    func submit() async {
        showLoading = true
        await action()
        showLoading = false
    }

}
