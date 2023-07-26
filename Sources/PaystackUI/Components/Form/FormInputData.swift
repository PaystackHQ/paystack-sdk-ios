import SwiftUI
import Combine

struct FormInputData<Content: View>: FormInputItemView {

    var validators: [FormValidator]
    var submissions: [PassthroughSubject<Void, Never>]
    var content: Content

    init(validators: [[FormValidator]],
         submissions: [[PassthroughSubject<Void, Never>]],
         content: Content) {
        self.validators = validators.flatMap { $0 }
        self.submissions = submissions.flatMap { $0 }
        self.content = content
    }

    var body: some View {
        content
    }

    var isValid: [FormValidator] {
        return validators
    }

    var submit: [PassthroughSubject<Void, Never>] {
        return submissions
    }

    func validate() -> Bool {
        submissions.forEach {
            $0.send()
        }

        // swiftlint:disable:next reduce_boolean
        return validators.reduce(true) {
            $1.validate() && $0
        }
    }
}
