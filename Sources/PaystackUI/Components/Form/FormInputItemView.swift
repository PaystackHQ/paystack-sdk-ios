import SwiftUI
import Combine

protocol FormInputItemView: View {
    var isValid: [FormValidator] { get }
    var submit: [PassthroughSubject<Void, Never>] { get }
}

extension FormInputItemView {

    var isValid: [FormValidator] {
        return []
    }

    var submit: [PassthroughSubject<Void, Never>] {
        return []
    }

}
