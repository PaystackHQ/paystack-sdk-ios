import SwiftUI

@available(iOS 14.0, *)
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
    var layout: FormInputLayout

    init(title: String = "Submit",
         enabled: Bool = true,
         action: @escaping () async -> Void,
         secondaryButtonText: String = "Cancel",
         secondaryAction: (() -> Void)? = nil,
         layout: FormInputLayout = .standard,
         supplementaryContent: SupplementaryContent,
         @FormInputDataBuilder content: () -> FormInputData<Content>) {
        let content = content()
        self.formData = content
        self.buttonTitle = title
        self.buttonEnabled = enabled
        self.secondaryButtonText = secondaryButtonText
        self.secondaryAction = secondaryAction
        self.layout = layout
        self.supplementaryContent = supplementaryContent
        self._viewModel = StateObject(wrappedValue: FormInputViewModel(action: action))
    }

    init(title: String = "Submit",
         enabled: Bool = true,
         action: @escaping () async -> Void,
         secondaryButtonText: String = "Cancel",
         secondaryAction: (() -> Void)? = nil,
         layout: FormInputLayout = .standard,
         @FormInputDataBuilder content: () -> FormInputData<Content>)
    where SupplementaryContent == EmptyView {
        let content = content()
        self.formData = content
        self.buttonTitle = title
        self.buttonEnabled = enabled
        self.secondaryButtonText = secondaryButtonText
        self.secondaryAction = secondaryAction
        self.layout = layout
        self.supplementaryContent = nil
        self._viewModel = StateObject(wrappedValue: FormInputViewModel(action: action))
    }

    var body: some View {
        VStack(spacing: layout.spacing) {
            formData.content

            Button(buttonTitle, action: submit)
                .buttonStyle(PrimaryButtonStyle(showLoading: viewModel.showLoading))
                .disabled(!buttonEnabled)
                .padding(.horizontal, layout.buttonHorizontalInset)
                .padding(.top, layout.buttonTopSpacing)

            if let supplementaryContent = supplementaryContent,
               !viewModel.showLoading {
                supplementaryContent
            }

            if let secondaryAction = secondaryAction,
               !viewModel.showLoading {
                Button(secondaryButtonText, action: secondaryAction)
                    .foregroundColor(.contentSecondary)
                    .font(.body14M)
                    .padding(.top, layout.secondaryButtonTopSpacing)
            }
        }
        .disabled(viewModel.showLoading)
    }

    func submit() {
        guard formData.validate() else { return }
        Task {
            await viewModel.submit()
        }
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

        func complete() async {
            status = "Complete"
        }

        var body: some View {
            VStack {
                FormInput(action: complete) {
                    TextField("Name", text: $name)
                        .form("Name")

                    TextFieldFormInputView(title: "Surname",
                                           placeholder: "Surname",
                                           text: $surname)
                }

                Text(status)
            }
            .padding(.doublePadding)
        }

    }

    static var previews: some View {
        TestView()
    }
}
