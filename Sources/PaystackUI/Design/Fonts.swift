import SwiftUI

extension Font {
    private enum BoingFont: String {
        case semibold = "Boing-SemiBold"
    }

    private enum GraphikFont: String {
        case regular = "Graphik-Regular"
        case medium = "Graphik-Medium"
    }

    static var heading3: Font {
        .custom(BoingFont.semibold.rawValue, size: 20)
    }

    static var body16R: Font {
        .custom(GraphikFont.regular.rawValue, size: 16)
    }

    static var body16M: Font {
        .custom(GraphikFont.medium.rawValue, size: 16)
    }
}

private var fontsRegistered = false

func registerFonts() {
    guard !fontsRegistered, let fonts = Bundle.resources.urls(
        forResourcesWithExtension: "ttf", subdirectory: nil) else {
        return
    }

    CTFontManagerRegisterFontURLs(fonts as CFArray, .process, true, nil)
    fontsRegistered = true
}
