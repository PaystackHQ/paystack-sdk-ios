import Foundation

public struct CardCharge: Codable, Equatable {
    var number: String
    var cvv: String
    var expiryMonth: String
    var expiryYear: String
    var pin: String?

    public init(number: String, cvv: String, expiryMonth: String,
                expiryYear: String, pin: String? = nil) {
        self.number = number
        self.cvv = cvv
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.pin = pin
    }
}
