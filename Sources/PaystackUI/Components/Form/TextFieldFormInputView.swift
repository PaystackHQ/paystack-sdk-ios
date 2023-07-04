import SwiftUI
import Combine

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
struct TextFieldFormInputView<Accessory: View>: FormInputItemView {

    var title: String
    var placeholder: String
    var keyboardType: KeyboardType
    var maxLength: Int?
    var accessoryView: Accessory?

    @Binding
    var text: String

    @Binding
    var inErrorState: Bool

    init(title: String,
         placeholder: String,
         text: Binding<String>,
         keyboardType: KeyboardType = .asciiCapable,
         maxLength: Int? = nil,
         inErrorState: Binding<Bool> = .constant(false),
         accessoryView: Accessory?) {
        self.title = title
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.maxLength = maxLength
        self.accessoryView = accessoryView
        self._inErrorState = inErrorState
        self._text = text
    }

    init(title: String,
         placeholder: String,
         text: Binding<String>,
         keyboardType: KeyboardType = .asciiCapable,
         maxLength: Int? = nil,
         inErrorState: Binding<Bool> = .constant(false)) where Accessory == EmptyView {
        self.title = title
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.maxLength = maxLength
        self.accessoryView = nil
        self._inErrorState = inErrorState
        self._text = text
    }

    var body: some View {
        HStack {
            TextField(placeholder, text: _text)

            if let accessory = accessoryView {
                accessory
                    .padding(16)
            }
        }
        .textFieldStyle(.form)
        .focusedBorderColor(defaultColor: inErrorState ? .red : .gray)
        .keyboardType(keyboardType)
        .onReceive(Just(text)) { value in
            if let maxLength = maxLength, value.count > maxLength {
                text.removeLast()
            }
        }
        .form(title)
    }
}

@available(iOS 14.0, *)
struct TextFieldFormInputView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldFormInputView(title: "Title",
                               placeholder: "Placeholder",
                               text: .constant("Text"),
                               accessoryView: Image(systemName: "x.circle"))
    }
}
