// Based on AEOTPTextField - https://github.com/AbdelrhmanKamalEliwa/AEOTPTextField

#if os(iOS)
import UIKit

class PinTextField: UITextField {
    // MARK: - PROPERTIES
    //
    /// The default character placed in the text field slots
    var otpDefaultCharacter = ""
    /// The default background color of the text field slots before entering a character
    var otpBackgroundColor: UIColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
    /// The default background color of the text field slots after entering a character
    var otpFilledBackgroundColor: UIColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
    /// The default corner raduis of the text field slots
    var otpCornerRaduis: CGFloat = 3
    /// The default border color of the text field slots before entering a character
    var otpDefaultBorderColor: UIColor = .gray
    /// The border color of the text field slots after entering a character
    var otpFilledBorderColor: UIColor = .green
    /// The default border width of the text field slots before entering a character
    var otpDefaultBorderWidth: CGFloat = 1
    /// The border width of the text field slots after entering a character
    var otpFilledBorderWidth: CGFloat = 1
    /// The default text color of the text
    var otpTextColor: UIColor = .black
    /// The default font size of the text
    var otpFontSize: CGFloat = 18
    /// The default font of the text
    var otpFont: UIFont = UIFont.systemFont(ofSize: 18)
    /// The delegate of the PinTextFieldDelegate protocol
    weak var otpDelegate: PinTextFieldDelegate?

    private var implementation = PinTextFieldImplementation()
    private var isConfigured = false
    private var digitLabels = [UILabel]()
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()

    // MARK: - METHODS
    //
    /// This func is used to configure the `PinTextTextField`, Usually you need to call this method into `viewDidLoad()`
    /// - Parameter slotCount: the number of OTP slots in the TextField
    func configure(with slotCount: Int = 4) {
        guard isConfigured == false else { return }
        isConfigured.toggle()
        configureTextField()
        becomeFirstResponder()

        let labelsStackView = createLabelsStackView(with: slotCount)
        addSubview(labelsStackView)
        addGestureRecognizer(tapRecognizer)
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// Use this func if you need to clear the `OTP` text and reset the `PinTextTextField` to the default state
    func clearOTP() {
        text = nil
        digitLabels.forEach { currentLabel in
            currentLabel.text = otpDefaultCharacter
            currentLabel.layer.borderWidth = otpDefaultBorderWidth
            currentLabel.layer.borderColor = otpDefaultBorderColor.cgColor
            currentLabel.backgroundColor = otpBackgroundColor
        }
    }
    /// Use this func to set the text in the code
    func setText(_ text: String) {
        let characters = Array(text)
        for index in 0 ..< characters.count {
            if digitLabels.indices.contains(index) {
                digitLabels[index].text = String(characters[index])
            }
        }
    }
}

// MARK: - PRIVATE METHODS
//
private extension PinTextField {
    func configureTextField() {
        tintColor = .clear
        textColor = .clear
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        borderStyle = .none
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        addTarget(self, action: #selector(textFieldDidFocus), for: .editingDidBegin)
        delegate = implementation
        implementation.implementationDelegate = self
    }

    func createLabelsStackView(with count: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        for _ in 1 ... count {
            let label = createLabel()
            stackView.addArrangedSubview(label)
            digitLabels.append(label)
        }
        return stackView
    }

    func createLabel() -> UILabel {
        let label = UILabel()
        label.backgroundColor = otpBackgroundColor
        label.layer.borderWidth = otpDefaultBorderWidth
        label.layer.borderColor = otpDefaultBorderColor.cgColor
        label.layer.cornerRadius = otpCornerRaduis
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = otpTextColor
        label.font = label.font.withSize(otpFontSize)
        label.font = otpFont
        label.isUserInteractionEnabled = true
        label.layer.masksToBounds = true
        label.text = otpDefaultCharacter
        return label
    }

    @objc
    func textDidChange() {
        styleFields()
        guard let text = self.text, text.count <= digitLabels.count else { return }
        if text.count == digitLabels.count {
            otpDelegate?.didUserFinishEnter(the: text)
        }
    }

    @objc
    func textFieldDidFocus() {
        styleFields()
    }

    func styleFields() {
        guard let text = self.text, text.count <= digitLabels.count else { return }
        for labelIndex in 0 ..< digitLabels.count {
            let currentLabel = digitLabels[labelIndex]

            if labelIndex > text.count {
                currentLabel.text = otpDefaultCharacter
                currentLabel.layer.borderWidth = otpDefaultBorderWidth
                currentLabel.layer.borderColor = otpDefaultBorderColor.cgColor
                currentLabel.backgroundColor = otpBackgroundColor
            } else if labelIndex == text.count {
                currentLabel.text = otpDefaultCharacter
                currentLabel.layer.borderWidth = otpFilledBorderWidth
                currentLabel.layer.borderColor = otpFilledBorderColor.cgColor
                currentLabel.backgroundColor = otpFilledBackgroundColor
            } else {
                let index = text.index(text.startIndex, offsetBy: labelIndex)
                currentLabel.text = isSecureTextEntry ? "•" : String(text[index])
                currentLabel.layer.borderWidth = otpDefaultBorderWidth
                currentLabel.layer.borderColor = otpDefaultBorderColor.cgColor
                currentLabel.backgroundColor = otpBackgroundColor
            }
        }
    }
}

// MARK: - PinTextTextFieldImplementationProtocol Delegate
//
extension PinTextField: PinTextFieldImplementationProtocol {
    var digitalLabelsCount: Int {
        digitLabels.count
    }
}
#endif
