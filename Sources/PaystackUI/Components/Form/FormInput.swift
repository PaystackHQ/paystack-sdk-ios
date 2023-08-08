import SwiftUI

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
struct FormInput<Content: View,
                        SupplementaryContent: View>: View {

    @StateObject
    var viewModel: FormInputViewModel

    var formData: FormInputData<Content>
    var supplementaryContent: SupplementaryContent?
    var buttonTitle: String
    var buttonEnabled: Bool
    var secondaryButtonText: String
    var secondaryAction: (() -> Void)?

    init(title: String = "Submit",
         enabled: Bool = true,
         action: @escaping (@escaping () -> Void) -> Void,
         secondaryButtonText: String = "Cancel",
         secondaryAction: (() -> Void)? = nil,
         supplementaryContent: SupplementaryContent,
         @FormInputDataBuilder content: () -> FormInputData<Content>) {
        let content = content()
        self.formData = content
        self.buttonTitle = title
        self.buttonEnabled = enabled
        self.secondaryButtonText = secondaryButtonText
        self.secondaryAction = secondaryAction
        self.supplementaryContent = supplementaryContent
        self._viewModel = StateObject(wrappedValue: FormInputViewModel(action: action))
    }

    init(title: String = "Submit",
         enabled: Bool = true,
         action: @escaping (@escaping () -> Void) -> Void,
         secondaryButtonText: String = "Cancel",
         secondaryAction: (() -> Void)? = nil,
         @FormInputDataBuilder content: () -> FormInputData<Content>)
    where SupplementaryContent == EmptyView {
        let content = content()
        self.formData = content
        self.buttonTitle = title
        self.buttonEnabled = enabled
        self.secondaryButtonText = secondaryButtonText
        self.secondaryAction = secondaryAction
        self.supplementaryContent = nil
        self._viewModel = StateObject(wrappedValue: FormInputViewModel(action: action))
    }

    var body: some View {
        VStack(spacing: 16) {
            formData.content

            Button(buttonTitle, action: submit)
                .buttonStyle(PrimaryButtonStyle(showLoading: viewModel.showLoading))
                .disabled(!buttonEnabled)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            if let supplementaryContent = supplementaryContent,
               !viewModel.showLoading {
                supplementaryContent
            }

            if let secondaryAction = secondaryAction,
               !viewModel.showLoading {
                Button(secondaryButtonText, action: secondaryAction)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
        .disabled(viewModel.showLoading)
    }

    func submit() {
        guard formData.validate() else { return }
        viewModel.submit()
    }

}

@available(iOS 14.0, *)
struct FormInput_Previews: PreviewProvider {

    @available(iOS 14.0, *)
    struct TestView: View {

        @State
        var name: String = ""

        @State
        var surname: String = ""

        @State
        var status: String = ""

        var body: some View {
            VStack {
                FormInput { onComplete in
                    status = "Complete"
                    onComplete()
                } content: {
                    TextField("Name", text: $name)
                        .form("Name")

                    TextFieldFormInputView(title: "Surname",
                                           placeholder: "Surname",
                                           text: $surname)
                }

                Text(status)
            }
            .padding(16)
        }

    }

    static var previews: some View {
        TestView()
    }
}
