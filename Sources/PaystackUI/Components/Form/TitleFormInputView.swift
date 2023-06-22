import SwiftUI

// TODO: Replace constants and colors from design system
struct TitleFormInputView<Content: View>: FormInputItemViewModifier {

    var title: String

    @ViewBuilder
    var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(.gray)
                .font(.body)

            content
        }
        .padding(16)
    }

}

extension View {

    func form(_ title: String,
              subtitle: String) -> some FormInputItemView {
        return form(title)
    }

    func form(_ title: String) -> some FormInputItemView {
        return TitleFormInputView(title: title) {
            self
        }
    }

}

struct TitleFormInputView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Preview Value")
            .form("Title")
    }
}
