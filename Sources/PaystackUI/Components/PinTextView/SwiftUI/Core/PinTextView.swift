// Based on AEOTPTextField - https://github.com/AbdelrhmanKamalEliwa/AEOTPTextField

#if os(iOS)
import SwiftUI
import Combine

@available(iOS 14.0, *)
struct PinTextView: View {
    // MARK: - PROPERTIES
    //
    /// A Boolean value that used to help the `PinTextView` supporting Clear OTP
    @State private var flag: Bool = false
    /// A Binding String value of the OTP
    @Binding private var text: String
    /// An Intger value to set the number of the slots of the `PinTextView`
    private let slotsCount: Int
    /// A CGFloat value to set a custom width to the `PinTextView`
    private let width: CGFloat
    /// A CGFloat value to set a custom height to the `PinTextView`
    private let height: CGFloat
    /// The default character placed in the text field slots
    private let otpDefaultCharacter: String
    /// The default background color of the text field slots before entering a character
    private let otpBackgroundColor: UIColor
    /// The default background color of the text field slots after entering a character
    private let otpFilledBackgroundColor: UIColor
    /// The default corner raduis of the text field slots
    private let otpCornerRaduis: CGFloat
    /// The default border color of the text field slots before entering a character
    private let otpDefaultBorderColor: UIColor
    /// The border color of the text field slots after entering a character
    private let otpFilledBorderColor: UIColor
    /// The default border width of the text field slots before entering a character
    private let otpDefaultBorderWidth: CGFloat
    /// The border width of the text field slots after entering a character
    private let otpFilledBorderWidth: CGFloat
    /// The default text color of the text
    private let otpTextColor: UIColor
    /// The default font size of the text
    private let otpFontSize: CGFloat
    /// The default font of the text
    private let otpFont: UIFont
    /// A Boolean value that indicates whether the text object disables text copying and, in some cases, hides the text that the user enters.
    private let isSecureTextEntry: Bool
    /// A Boolean value that used to allow the `PinTextView` clear the OTP and set the `PinTextView` to the default state when you set the OTP Text with Empty Value
    private let enableClearOTP: Bool
    /// A Closure that fires when the OTP returned
    private var onCommit: (() async -> Void)?

    // MARK: - INIT
    //
    /// The Initializer of the `PinTextView`
    /// - Parameters:
    ///   - text: The OTP text that entered into PinTextView
    ///   - slotsCount: The number of OTP slots in the PinTextView
    ///   - width: The default width of the PinTextView
    ///   - height: The default height of the PinTextView
    ///   - otpDefaultCharacter: The default character placed in the text field slots
    ///   - otpBackgroundColor: The default background color of the text field slots before entering a character
    ///   - otpFilledBackgroundColor: The default background color of the text field slots after entering a character
    ///   - otpCornerRaduis: The default corner raduis of the text field slots
    ///   - otpDefaultBorderColor: The default border color of the text field slots before entering a character
    ///   - otpFilledBorderColor: The border color of the text field slots after entering a character
    ///   - otpDefaultBorderWidth: The default border width of the text field slots before entering a character
    ///   - otpFilledBorderWidth: The border width of the text field slots after entering a character
    ///   - otpTextColor: The default text color of the text
    ///   - otpFontSize: The default font size of the text
    ///   - otpFont: The default font of the text
    ///   - isSecureTextEntry: A Boolean value that indicates whether the text object disables text copying and, in some cases, hides the text that the user enters.
    ///   - enableClearOTP: A Boolean value that used to allow the `PinTextView` clear the OTP and set the `PinTextView` to the default state when you set the OTP Text with Empty Value
    ///   - onCommit: A Closure that fires when the OTP returned
    init(
        text: Binding<String>,
        slotsCount: Int = 4,
        width: CGFloat = 50,
        height: CGFloat = 50,
        otpDefaultCharacter: String = "",
        otpBackgroundColor: UIColor = .clear,
        otpFilledBackgroundColor: UIColor = .clear,
        otpCornerRaduis: CGFloat = 3,
        otpDefaultBorderColor: UIColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1),
        otpFilledBorderColor: UIColor = UIColor(.stackGreen),
        otpDefaultBorderWidth: CGFloat = 1,
        otpFilledBorderWidth: CGFloat = 1,
        otpTextColor: UIColor = UIColor(.stackBlue),
        otpFontSize: CGFloat = 18,
        otpFont: UIFont = .heading2,
        isSecureTextEntry: Bool = false,
        enableClearOTP: Bool = false,
        onCommit: (() async -> Void)? = nil
    ) {
        self._text = text
        self.slotsCount = slotsCount
        self.width = width
        self.height = height
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
        self.enableClearOTP = enableClearOTP
        self.onCommit = onCommit
    }

    // MARK: - BODY
    //
    var body: some View {
        ZStack {
            if flag {
                otpView
            } else {
                otpView
            }
        } //: ZStack
        .frame(width: totalWidth, height: height)
        .onChange(of: text) { newValue in
            guard enableClearOTP else { return }
            if newValue.isEmpty {
                flag.toggle()
            } //: condition
        } //: onChange
    } //: body

    private var totalWidth: CGFloat {
        let numberOfSlots = CGFloat(slotsCount)
        return (width * numberOfSlots) + (8 * (numberOfSlots - 1))
    }

    // MARK: - VIEWS
    //
    var otpView: some View {
        PinTextViewRepresentable(
            text: $text,
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
            isSecureTextEntry: isSecureTextEntry,
            onCommit: onCommit
        )
    } //: otpView
}
#endif
