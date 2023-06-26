import SwiftUI
import Combine

public struct FormInputData<Content: View>: FormInputItemView {

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

    public var body: some View {
        content
    }

    public var isValid: [FormValidator] {
        return validators
    }

    public var submit: [PassthroughSubject<Void, Never>] {
        return submissions
    }

    public func validate() -> Bool {
        submissions.forEach {
            $0.send()
        }

        // swiftlint:disable:next reduce_boolean
        return validators.reduce(true) {
            $1.validate() && $0
        }
    }
}
