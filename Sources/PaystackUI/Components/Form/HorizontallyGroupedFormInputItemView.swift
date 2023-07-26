import SwiftUI
import Combine

struct HorizontallyGroupedFormInputItemView<Content: View>: FormInputItemView {

    @FormInputDataBuilder
    var builder: FormInputData<Content>

    init(@FormInputDataBuilder builder: () -> FormInputData<Content>) {
        self.builder = builder()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            builder
        }
    }

    var isValid: [FormValidator] {
        return builder.validators
    }

    var submit: [PassthroughSubject<Void, Never>] {
        return builder.submissions
    }

}
