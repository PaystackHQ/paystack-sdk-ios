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

    static var dropDownIndicator: some View {
        Image(systemName: "arrowtriangle.down.circle.fill")
            .foregroundColor(.gray)
    }

    static var errorIcon: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .resizable()
            .foregroundColor(.orange)
            .aspectRatio(contentMode: .fit)
            .frame(width: 32)
    }
}
