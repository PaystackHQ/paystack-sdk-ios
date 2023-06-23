import SwiftUI
import Combine

protocol FormInputItemViewModifier: FormInputItemView {
    associatedtype Content: View

    var content: Content { get }
}

extension FormInputItemViewModifier where Content: FormInputItemView {

    var isValid: [FormValidator] {
        return content.isValid
    }

    var submit: [PassthroughSubject<Void, Never>] {
        return content.submit
    }

}
