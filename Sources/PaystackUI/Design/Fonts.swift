import SwiftUI

extension Font {
    private enum BoingFont: String {
        case semibold = "Boing-SemiBold"
    }

    private enum GraphikFont: String {
        case regular = "Graphik-Regular"
        case medium = "Graphik-Medium"
    }

    static var heading2: Font {
        .custom(BoingFont.semibold.rawValue, size: 24)
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

    static var body14R: Font {
        .custom(GraphikFont.regular.rawValue, size: 14)
    }

    static var body14M: Font {
        .custom(GraphikFont.medium.rawValue, size: 14)
    }

    static var body12R: Font {
        .custom(GraphikFont.regular.rawValue, size: 12)
    }

    static var body12M: Font {
        .custom(GraphikFont.medium.rawValue, size: 12)
    }

    static var smallTextM: Font {
        .custom(GraphikFont.medium.rawValue, size: 10)
    }
}

// MARK: - UIKit compatibility
#if os(iOS)
extension UIFont {

    private enum BoingFont: String {
        case semibold = "Boing-SemiBold"
    }

    static var heading2: UIFont {
        UIFont(name: BoingFont.semibold.rawValue, size: 24) ?? .systemFont(ofSize: 24)
    }
}
#endif

private var fontsRegistered = false

func registerFonts() {
    guard !fontsRegistered, let fonts = Bundle.resources.urls(
        forResourcesWithExtension: "ttf", subdirectory: nil) else {
        return
    }

    CTFontManagerRegisterFontURLs(fonts as CFArray, .process, true, nil)
    fontsRegistered = true
}
