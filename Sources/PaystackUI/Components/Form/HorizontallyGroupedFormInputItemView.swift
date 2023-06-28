import SwiftUI
import Combine

public struct HorizontallyGroupedFormInputItemView<Content: View>: FormInputItemView {

    @FormInputDataBuilder
    var builder: FormInputData<Content>

    public init(@FormInputDataBuilder builder: () -> FormInputData<Content>) {
        self.builder = builder()
    }

    public var body: some View {
        HStack(spacing: 16) {
            builder
        }
    }

    public var isValid: [FormValidator] {
        return builder.validators
    }

    public var submit: [PassthroughSubject<Void, Never>] {
        return builder.submissions
    }

}
