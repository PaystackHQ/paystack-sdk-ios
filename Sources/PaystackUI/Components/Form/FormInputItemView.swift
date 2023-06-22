import SwiftUI
import Combine

public protocol FormInputItemView: View {
    var isValid: [FormValidator] { get }
    var submit: [PassthroughSubject<Void, Never>] { get }
}

extension FormInputItemView {

    public var isValid: [FormValidator] {
        return []
    }

    public var submit: [PassthroughSubject<Void, Never>] {
        return []
    }

}
