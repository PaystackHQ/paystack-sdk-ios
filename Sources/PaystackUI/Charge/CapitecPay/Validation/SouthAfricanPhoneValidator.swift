import Foundation

enum SouthAfricanPhoneValidator {

    static func isValid(_ input: String) -> Bool {
        let pattern = "^0[6-8][0-9]{8}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex.firstMatch(in: input, range: range) != nil
    }
}
