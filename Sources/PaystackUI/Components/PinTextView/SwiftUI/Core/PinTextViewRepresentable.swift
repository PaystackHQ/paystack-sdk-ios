// Based on AEOTPTextField - https://github.com/AbdelrhmanKamalEliwa/AEOTPTextField

import SwiftUI

#if os(iOS)
struct PinTextViewRepresentable: UIViewRepresentable {
    @Binding private var text: String
    private let slotsCount: Int
    private let otpDefaultCharacter: String
    private let otpBackgroundColor: UIColor
    private let otpFilledBackgroundColor: UIColor
    private let otpCornerRaduis: CGFloat
    private let otpDefaultBorderColor: UIColor
    private let otpFilledBorderColor: UIColor
    private let otpDefaultBorderWidth: CGFloat
    private let otpFilledBorderWidth: CGFloat
    private let otpTextColor: UIColor
    private let otpFontSize: CGFloat
    private let otpFont: UIFont
    private let isSecureTextEntry: Bool
    private let onCommit: (() async -> Void)?
    private let textField: PinTextFieldSwiftUI

    init(
        text: Binding<String>,
        slotsCount: Int = 4,
        otpDefaultCharacter: String = "",
        otpBackgroundColor: UIColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1),
        otpFilledBackgroundColor: UIColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1),
        otpCornerRaduis: CGFloat = 3,
        otpDefaultBorderColor: UIColor = .gray,
        otpFilledBorderColor: UIColor = .green,
        otpDefaultBorderWidth: CGFloat = 1,
        otpFilledBorderWidth: CGFloat = 1,
        otpTextColor: UIColor = .black,
        otpFontSize: CGFloat = 18,
        otpFont: UIFont = UIFont.systemFont(ofSize: 18),
        isSecureTextEntry: Bool = false,
        onCommit: (() async -> Void)? = nil
    ) {
        self._text = text
        self.slotsCount = slotsCount
        self.otpDefaultCharacter = otpDefaultCharacter
        self.otpBackgroundColor = otpBackgroundColor
        self.otpFilledBackgroundColor = otpFilledBackgroundColor
        self.otpCornerRaduis = otpCornerRaduis
        self.otpDefaultBorderColor = otpDefaultBorderColor
        self.otpFilledBorderColor = otpFilledBorderColor
        self.otpDefaultBorderWidth = otpDefaultBorderWidth
        self.otpFilledBorderWidth = otpFilledBorderWidth
        self.otpTextColor = otpTextColor
        self.otpFontSize = otpFontSize
        self.otpFont = otpFont
        self.isSecureTextEntry = isSecureTextEntry
        self.onCommit = onCommit

        self.textField = PinTextFieldSwiftUI(
            slotsCount: slotsCount,
            otpDefaultCharacter: otpDefaultCharacter,
            otpBackgroundColor: otpBackgroundColor,
            otpFilledBackgroundColor: otpFilledBackgroundColor,
            otpCornerRaduis: otpCornerRaduis,
            otpDefaultBorderColor: otpDefaultBorderColor,
            otpFilledBorderColor: otpFilledBorderColor,
            otpDefaultBorderWidth: otpDefaultBorderWidth,
            otpFilledBorderWidth: otpFilledBorderWidth,
            otpTextColor: otpTextColor,
            otpFontSize: otpFontSize,
            otpFont: otpFont,
            isSecureTextEntry: isSecureTextEntry
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, slotsCount: slotsCount, onCommit: onCommit)
    }

    func makeUIView(context: Context) -> PinTextFieldSwiftUI {
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: PinTextFieldSwiftUI, context: Context) { }

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding private var text: String

        private let slotsCount: Int
        private let onCommit: (() async -> Void)?

        init(
            text: Binding<String>,
            slotsCount: Int,
            onCommit: (() async -> Void)?
        ) {
            self._text = text
            self.slotsCount = slotsCount
            self.onCommit = onCommit

            super.init()
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""

            if textField.text?.count == slotsCount {
                Task {
                    await onCommit?()
                }
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
            guard let characterCount = textField.text?.count else { return false }
            return characterCount < slotsCount || string.isEmpty
        }
    }
}
#endif
