import SwiftUI
import Combine

struct OptionalFormInputItemView<Content: FormInputItemView>: FormInputItemView {

    var content: Content?

    var body: some View {
        if let content = content {
            content
        }
    }

    var submit: [PassthroughSubject<Void, Never>] {
        return content?.submit ?? []
    }

    var isValid: [FormValidator] {
        return content?.isValid ?? []
    }

}
