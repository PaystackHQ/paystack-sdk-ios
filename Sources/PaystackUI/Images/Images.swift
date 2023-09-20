import SwiftUI

extension Image {

    static var visaLogo: some View {
        Image("visaLogo", bundle: .current)
            .frame(height: 16)
    }

    static var verveLogo: some View {
        Image("verveLogo", bundle: .current)
            .frame(height: 16)
    }

    static var mastercardLogo: some View {
        Image("mastercardLogo", bundle: .current)
            .frame(height: 16)
    }

    static var amexLogo: some View {
        Image("amexLogo", bundle: .current)
            .frame(height: 16)
    }

    static var jcbLogo: some View {
        Image("jcbLogo", bundle: .current)
            .frame(height: 16)
    }

    static var dinersLogo: some View {
        Image("dinersLogo", bundle: .current)
            .frame(height: 16)
    }

    static var discoverLogo: some View {
        Image("discoverLogo", bundle: .current)
            .frame(height: 16)
    }

    static var paystackSecured: some View {
        Image("paystackSecured", bundle: .current)
            .resizable()
    }

    static var successIcon: some View {
        Image("successIcon", bundle: .current)
    }

    static var otpIcon: some View {
        Image("otpIcon", bundle: .current)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48)
    }

    static var birthdayIcon: some View {
        Image("birthdayIcon", bundle: .current)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48)
    }

    static var redirectIcon: some View {
        Image("redirectIcon", bundle: .current)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 36)
    }

    static var dropDownIndicator: some View {
        Image(systemName: "arrowtriangle.down.circle.fill")
            .foregroundColor(.gray01)
    }

    static var errorIcon: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .resizable()
            .foregroundColor(.warning02)
            .aspectRatio(contentMode: .fit)
            .frame(width: .quadPadding)
    }

    static var radioButtonUnselected: some View {
        Image(systemName: "circle")
            .resizable()
            .foregroundColor(.black)
            .aspectRatio(contentMode: .fit)
            .frame(width: .doublePadding)
    }

    static var radioButtonSelected: some View {
        Image(systemName: "checkmark.circle.fill")
            .resizable()
            .foregroundColor(.stackGreen)
            .aspectRatio(contentMode: .fit)
            .frame(width: .doublePadding)
    }
}
