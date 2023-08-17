import SwiftUI

struct TestModeInidcator: View {

    var body: some View {
        Text("TEST")
            .foregroundColor(.warning01)
            .font(.smallTextM)
            .padding(.horizontal, .singlePadding + .halfPadding)
            .padding(.vertical, .halfPadding)
            .background(Color.warning05)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.warning04, lineWidth: 1)
            )
    }

}

struct TestModeInidcator_Previews: PreviewProvider {
    static var previews: some View {
        TestModeInidcator()
    }
}
