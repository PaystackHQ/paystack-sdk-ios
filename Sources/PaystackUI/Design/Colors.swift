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

// MARK: - Semantic tokens (dark-mode migration)
//
// Adopted from Figma variables in file X9AP1iujNZ2J4emDYuiKfc — Paystack
// Merchant App Revamp (MPOS). Light values keep the shipped SDK's current
// hexes ; dark values come from the reference frames or the derived table
// signed off in DARK_MODE_IMPLEMENTATION_PLAN.md.

// MARK: Semantic — Surfaces
extension Color {

    static var surfacePrimary: Color {
        .named("SurfacePrimary")
    }

    static var surfaceSecondary: Color {
        .named("SurfaceSecondary")
    }

    static var surfaceTertiary: Color {
        .named("SurfaceTertiary")
    }

    static var surfaceInsetTranslucent: Color {
        .named("SurfaceInsetTranslucent")
    }

}

// MARK: Semantic — Borders
extension Color {

    static var borderPrimary: Color {
        .named("BorderPrimary")
    }

    static var borderSubtle: Color {
        .named("BorderSubtle")
    }

    static var borderStrong: Color {
        .named("BorderStrong")
    }

    static var borderError: Color {
        .named("BorderError")
    }

}

// MARK: Semantic — Content
extension Color {

    static var contentPrimary: Color {
        .named("ContentPrimary")
    }

    static var contentSecondary: Color {
        .named("ContentSecondary")
    }

    static var contentTertiary: Color {
        .named("ContentTertiary")
    }

    static var contentPlaceholder: Color {
        .named("ContentPlaceholder")
    }

    static var contentWarning: Color {
        .named("ContentWarning")
    }

    static var contentError: Color {
        .named("ContentError")
    }

    static var contentOnAccent: Color {
        .named("ContentOnAccent")
    }

    static var contentOnAccentPressed: Color {
        .named("ContentOnAccentPressed")
    }

}

// MARK: Semantic — Accents
extension Color {

    static var accentPrimary: Color {
        .named("AccentPrimary")
    }

    static var accentPrimaryDisabled: Color {
        .named("AccentPrimaryDisabled")
    }

    static var accentPrimaryPressed: Color {
        .named("AccentPrimaryPressed")
    }

    static var accentSecondary: Color {
        .named("AccentSecondary")
    }

}

// MARK: Semantic — Auxiliaries
extension Color {

    static var iconMuted: Color {
        .named("IconMuted")
    }

    static var spinnerTint: Color {
        .named("SpinnerTint")
    }

    static var trackInactive: Color {
        .named("TrackInactive")
    }

    static var overlayScrim: Color {
        .named("OverlayScrim")
    }

}

// MARK: Semantic — Warning / info / test-mode / toast
extension Color {

    static var warningSurface: Color {
        .named("WarningSurface")
    }

    static var infoSurface: Color {
        .named("InfoSurface")
    }

    static var toastSurface: Color {
        .named("ToastSurface")
    }

    static var testModeContent: Color {
        .named("TestModeContent")
    }

    static var testModeSurface: Color {
        .named("TestModeSurface")
    }

    static var testModeBorder: Color {
        .named("TestModeBorder")
    }

}

// MARK: Semantic — Fixed / shimmer / PIN
extension Color {

    static var qrPlate: Color {
        .named("QRPlate")
    }

    static var shimmerBase: Color {
        .named("ShimmerBase")
    }

    static var shimmerHighlight: Color {
        .named("ShimmerHighlight")
    }

    static var pinSlotSurface: Color {
        .named("PinSlotSurface")
    }

    static var pinSlotBorder: Color {
        .named("PinSlotBorder")
    }

}

private extension Color {
    static func named(_ name: String) -> Color {
        return Color(name, bundle: .current)
    }
}

#if canImport(UIKit)
import UIKit

// MARK: - UIKit dynamic-colour bridge
//
// PIN entry uses UIKit primitives. Direct `UIColor(_: Color)` snapshots the
// SwiftUI colour against the current trait collection at init and does not
// track a later `.light` → `.dark` change. Using `UIColor(named:in:compatibleWith:)`
// with `compatibleWith: nil` resolves against the view's live trait
// collection, so appearance flips mid-session are honoured.
extension UIColor {

    static var pinSlotSurface: UIColor {
        .paystackNamed("PinSlotSurface")
    }

    static var pinSlotBorder: UIColor {
        .paystackNamed("PinSlotBorder")
    }

    static var accentPrimary: UIColor {
        .paystackNamed("AccentPrimary")
    }

    static var contentPrimary: UIColor {
        .paystackNamed("ContentPrimary")
    }

    fileprivate static func paystackNamed(_ name: String) -> UIColor {
        return UIColor(named: name, in: .current, compatibleWith: nil)
            ?? .clear
    }
}
#endif
