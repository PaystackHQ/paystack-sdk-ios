import SwiftUI

// MARK: - Primary
extension Color {

    static var stackBlue: Color {
        .named("StackBlue")
    }

    static var navy02: Color {
        .named("Navy02")
    }

    static var navy03: Color {
        .named("Navy03")
    }

    static var navy04: Color {
        .named("Navy04")
    }

    static var navy05: Color {
        .named("Navy05")
    }

}

// MARK: - Secondary
extension Color {

    static var stackGreen: Color {
        .named("StackGreen")
    }

    static var green02: Color {
        .named("Green02")
    }

}

// MARK: - Error
extension Color {

    static var error01: Color {
        .named("Error01")
    }

    static var error02: Color {
        .named("Error02")
    }

}

// MARK: - Warning
extension Color {

    static var warning01: Color {
        .named("Warning01")
    }

    static var warning02: Color {
        .named("Warning02")
    }

    static var warning04: Color {
        .named("Warning04")
    }

    static var warning05: Color {
        .named("Warning05")
    }

}

// MARK: - Neutral
extension Color {

    static var gray01: Color {
        .named("Gray01")
    }

}

private extension Color {
    static func named(_ name: String) -> Color {
        return Color(name, bundle: .current)
    }
}
