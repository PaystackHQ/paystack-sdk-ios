import Foundation

class CardPinViewModel: ObservableObject {

    @Published
    var pinText: String = ""

    @Published
    var showLoading = false

    func submitPin() {
        showLoading = true
        // TODO: Perform API call
    }

    func cancelTransaction() {
        // TODO: Add cancel transaction functionality in the next PR
    }
}
