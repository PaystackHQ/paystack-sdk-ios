import SwiftUI

@available(iOS 14.0, *)
struct PickerFormInputView<Item: Hashable & CustomStringConvertible>: FormInputItemView {

    let items: [Item]
    let title: String
    let placeholder: String

    @Binding
    var selectedItem: Item?

    init(title: String, items: [Item],
         placeholder: String, selectedItem: Binding<Item?>) {
        self.items = items
        self.title = title
        self.placeholder = placeholder
        self._selectedItem = selectedItem
    }

    var body: some View {
        /*
         We need to manually embed a picker inside a Menu as the
         picker label does not currently work:
         https://developer.apple.com/forums/thread/688518.
         Once this is fixed, we should modify it to remove the menu
         */
        Menu {
            Picker(selection: _selectedItem, label: EmptyView()) {
                ForEach(items, id: \.description) {
                    Text($0.description).tag($0 as Item?)
                }
            }
        } label: {
            label
        }
        .padding(.doublePadding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: .cornerRadius, style: .continuous)
                .stroke(Color.navy04, lineWidth: 1)
        )
        .form(title)
    }

    var label: some View {
        HStack {
            if let selectedItem = selectedItem {
                Text(selectedItem.description)
                    .foregroundColor(.stackBlue)
            } else {
                Text(placeholder)
                    .foregroundColor(.navy04)
            }

            Spacer()

            Image.dropDownIndicator
        }
    }

}

@available(iOS 14.0, *)
struct PickerFormInputView_Previews: PreviewProvider {
    static var previews: some View {
        PickerFormInputView(
            title: "Letter", items: ["A", "B", "C", "D", "E"],
            placeholder: "Select Letter", selectedItem: .constant("C"))
    }
}
