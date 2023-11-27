// swiftlint:disable file_length type_body_length line_length
import Foundation

public extension Paystack {
    private var service: ChargeService {
        return ChargeServiceImplementation(config: config)
    }

    private var mobileMoneyService: MobileMoneyService {
        return MobileMoneyServiceImplementation(config: config)
    }

    /// Continues the Charge flow by authenticating a user with an OTP
    /// - Parameters:
    ///   - otp: The OTP sent to the user's device
    ///   - accessCode: The access code for the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withOtp otp: String, accessCode: String) -> Service<ChargeResponse> {
        let request = SubmitOtpRequest(otp: otp, accessCode: accessCode)
        return service.postSubmitOtp(request)
    }

    /// Continues the Charge flow by authenticating a user with a Pin
    /// - Parameters:
    ///   - pin: The user's card pin
    ///   - publicEncryptionKey: The public encryption key that will be used, this would be returned as part of ``VerifyAccessCodeResponse``
    ///   - accessCode: The access code for the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withPin pin: String,
                            publicEncryptionKey: String,
                            accessCode: String) throws -> Service<ChargeResponse> {
        let encryptedPin = try Cryptography().encrypt(text: pin,
                                                      publicKey: publicEncryptionKey)
        let request = SubmitPinRequest(pin: encryptedPin, accessCode: accessCode)
        return service.postSubmitPin(request)
    }

    /// Continues the Charge flow by authenticating a user with a phone number
    /// - Parameters:
    ///   - phone: The user's phone number associated with the card
    ///   - accessCode: The access code for the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withPhone phone: String,
                            accessCode: String) -> Service<ChargeResponse> {
        let request = SubmitPhoneRequest(phone: phone, accessCode: accessCode)
        return service.postSubmitPhone(request)
    }

    /// Continues the Charge flow by authenticating a user with their birthday
    /// - Parameters:
    ///   - birthday: The user's birthday as a ``Date`` object
    ///   - accessCode: The access code for the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withBirthday birthday: Date,
                            accessCode: String) -> Service<ChargeResponse> {
        let birthdayString = DateFormatter.toString(usingFormat: "yyyy-MM-dd", from: birthday)
        let request = SubmitBirthdayRequest(birthday: birthdayString, accessCode: accessCode)
        return service.postSubmitBirthday(request)
    }

    /// Continues the Charge flow by authenticating a user with their address
    /// - Parameters:
    ///   - address: An ``Address`` object describing the user's address
    ///   - accessCode: The access code for the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withAddress address: Address,
                            accessCode: String) -> Service<ChargeResponse> {
        let request = SubmitAddressRequest(address: address, accessCode: accessCode)
        return service.postSubmitAddress(request)
    }

    /// Listens for a response after presenting a 3DS URL in a webview for authentication
    /// - Parameter transactionId:The ID of the current transaction that is being authenticated
    /// - Returns: A ``Service`` with the results of the authentication
    func listenFor3DSResponse(for transactionId: Int) -> Service<Charge3DSResponse> {
        let channelName = "3DS_\(transactionId)"
        let subscription: any Subscription = PusherSubscription(channelName: channelName, eventName: "response")
        return Service(subscription)
    }

    /// Listens for a response after presenting a 3DS URL in a webview for authentication
    /// - Parameter transactionId:The ID of the current transaction that is being authenticated
    /// - Returns: A ``Service`` with the results of the authentication
    func listenForMobileMoneyResponse(for transactionId: Int) -> Service<Charge3DSResponse> {
        let channelName = "MOBILE_MONEY_\(transactionId)"
        let subscription: any Subscription = PusherSubscription(channelName: channelName, eventName: "response")
        return Service(subscription)
    }

    /// Initialize Mobile Money charge
    /// - Parameters:
    ///   - mobileMoneyData: The data that needs to be passed in order to do a mobile money charge
    /// - Returns: A ``Service`` with the ``MobileMoneyChargeResponse`` response
    func chargeMobileMoney(with mobileMoneyData: MobileMoneyData) -> Service<MobileMoneyChargeResponse> {
        let request = MobileMoneyChargeRequest(channelName: mobileMoneyData.channelName, amount: mobileMoneyData.amount, email: mobileMoneyData.email, phone: mobileMoneyData.phone, transaction: mobileMoneyData.transaction, provider: mobileMoneyData.provider)
        return mobileMoneyService.postChargeMobileMoney(request)
    }
}
// swiftlint:enable file_length type_body_length line_length
