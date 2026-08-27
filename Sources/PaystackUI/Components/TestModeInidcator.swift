import SwiftUI

struct TestModeInidcator: View {

    var body: some View {
        Text("TEST")
            .foregroundColor(.testModeContent)
            .font(.smallTextM)
            .padding(.horizontal, .singlePadding + .halfPadding)
            .padding(.vertical, .halfPadding)
            .background(Color.testModeSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.testModeBorder, lineWidth: 1)
            )
    }

}

struct TestModeInidcator_Previews: PreviewProvider {
    static var previews: some View {
        TestModeInidcator()
    }
}
