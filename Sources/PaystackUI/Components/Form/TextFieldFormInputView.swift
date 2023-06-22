import SwiftUI
import Combine

@available(iOS 14.0, *)
public struct TextFieldFormInputView<Accessory: View>: FormInputItemView {

    var title: String
    var placeholder: String
    var keyboardType: UIKeyboardType
    var maxLength: Int?
    var accessoryView: Accessory?

    @Binding
    var text: String

    public init(title: String,
                placeholder: String,
                text: Binding<String>,
                keyboardType: UIKeyboardType = .asciiCapable,
                maxLength: Int? = nil,
                accessoryView: Accessory?) {
        self.title = title
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.maxLength = maxLength
        self.accessoryView = accessoryView
        self._text = text
    }

    public init(title: String,
                placeholder: String,
                text: Binding<String>,
                keyboardType: UIKeyboardType = .asciiCapable,
                maxLength: Int? = nil) where Accessory == EmptyView {
        self.title = title
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.maxLength = maxLength
        self.accessoryView = nil
        self._text = text
    }

    public var body: some View {
        HStack {
            TextField(placeholder, text: _text)

            if let accessory = accessoryView {
                accessory
                    .padding(16)
            }
        }
        .textFieldStyle(.form)
        .focusedBorderColor()
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
