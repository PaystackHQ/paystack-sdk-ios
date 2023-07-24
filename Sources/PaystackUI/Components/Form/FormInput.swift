import SwiftUI

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
public struct FormInput<Content: View>: View {

    @StateObject
    var viewModel: FormInputViewModel

    var formData: FormInputData<Content>
    var buttonTitle: String
    var buttonEnabled: Bool
    var cancelAction: (() -> Void)?

    public init(title: String = "Submit",
                enabled: Bool = true,
                action: @escaping (@escaping () -> Void) -> Void,
                cancelAction: (() -> Void)? = nil,
                @FormInputDataBuilder content: () -> FormInputData<Content>) {
        let content = content()
        self.formData = content
        self.buttonTitle = title
        self.buttonEnabled = enabled
        self.cancelAction = cancelAction
        self._viewModel = StateObject(wrappedValue: FormInputViewModel(action: action))
    }

    public var body: some View {
        VStack(spacing: 16) {
            formData.content

            Button(buttonTitle, action: submit)
                .buttonStyle(PrimaryButtonStyle(showLoading: viewModel.showLoading))
                .disabled(!buttonEnabled)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            if let cancelAction = cancelAction,
               !viewModel.showLoading {
                Button("Cancel", action: cancelAction)
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
