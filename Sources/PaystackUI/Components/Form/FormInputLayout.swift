import SwiftUI


struct FormInputLayout {

    let spacing: CGFloat
    let buttonHorizontalInset: CGFloat
    let buttonTopSpacing: CGFloat
    let secondaryButtonTopSpacing: CGFloat

    static let standard = FormInputLayout(
        spacing: .doublePadding,
        buttonHorizontalInset: .doublePadding,
        buttonTopSpacing: .singlePadding,
        secondaryButtonTopSpacing: .singlePadding)

    static let fullWidth = FormInputLayout(
        spacing: .doublePadding,
        buttonHorizontalInset: 0,
        buttonTopSpacing: 0,
        secondaryButtonTopSpacing: 0)
}
