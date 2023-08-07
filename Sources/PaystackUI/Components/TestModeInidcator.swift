import SwiftUI

// TODO: Replace constants and colors from design system
struct TestModeInidcator: View {

    var body: some View {
        Text("TEST")
            .foregroundColor(Color(red: 0.4, green: 0.22, blue: 0))
            .font(.caption)
            .bold()
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color(red: 1, green: 0.96, blue: 0.87))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(red: 1, green: 0.89, blue: 0.72), lineWidth: 1)
            )
    }

}

struct TestModeInidcator_Previews: PreviewProvider {
    static var previews: some View {
        TestModeInidcator()
    }
}
