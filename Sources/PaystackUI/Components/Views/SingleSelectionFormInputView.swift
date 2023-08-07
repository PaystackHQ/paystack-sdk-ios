import SwiftUI

@available(iOS 14.0, *)
// TODO: Replace constants and colors from design system
struct SingleSelectionFormInputView<Item: Hashable,
                            Content: View>: FormInputItemView {

    @Binding
    var selectedItem: Item?

    var items: [Item]
    var content: (Item) -> Content

    init(items: [Item],
         selectedItem: Binding<Item?>,
         content: @escaping (Item) -> Content) {
        self._selectedItem = selectedItem
        self.items = items
        self.content = content
    }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(items, id: \.hashValue) { item in
                Button {
                    selectedItem = item
                } label: {
                    itemLabel(for: item)
                }
            }
        }
    }

    func itemLabel(for item: Item) -> some View {
        HStack {
            radioButton(for: item)
            content(item)
            // todo: remove?
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.gray, lineWidth: 1)
        )
    }

    @ViewBuilder
    func radioButton(for item: Item) -> some View {
        if item == selectedItem {
            Image.radioButtonSelected
        } else {
            Image.radioButtonUnselected
        }
    }
}

@available(iOS 14.0, *)
struct SingleSelectionView_Previews: PreviewProvider {
    static var items = ["Option A", "Option B", "Option C"]

    static var previews: some View {
        SingleSelectionFormInputView(items: items, selectedItem: .constant("Option B")) {
                Text($0)
            }
    }
}
