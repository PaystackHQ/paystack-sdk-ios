import Foundation

public extension Paystack {
    private var service: ChargeService {
        return ChargeServiceImplementation(config: config)
    }

    /// Continues the Charge flow by authenticating a user with an OTP
    /// - Parameters:
    ///   - otp: The OTP sent to the user's device
    ///   - reference: The reference of the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withOtp otp: String, reference: String) -> Service<ChargeAuthenticationResponse> {
        let request = SubmitOtpRequest(otp: otp, reference: reference)
        return service.postSubmitOtp(request)
    }

    /// Continues the Charge flow by authenticating a user with a Pin
    /// - Parameters:
    ///   - pin: The user's card pin
    ///   - reference: The reference of the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withPin pin: String, reference: String) -> Service<ChargeAuthenticationResponse> {
        let request = SubmitPinRequest(pin: pin, reference: reference)
        return service.postSubmitPin(request)
    }

    /// Continues the Charge flow by authenticating a user with a phone number
    /// - Parameters:
    ///   - phone: The user's phone number associated with the card
    ///   - reference: The reference of the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withPhone phone: String,
                            reference: String) -> Service<ChargeAuthenticationResponse> {
        let request = SubmitPhoneRequest(phone: phone, reference: reference)
        return service.postSubmitPhone(request)
    }

    /// Continues the Charge flow by authenticating a user with their birthday
    /// - Parameters:
    ///   - birthday: The user's birthday in ISO 8601 format
    ///   - reference: The reference of the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withBirthday birthday: String,
                            reference: String) -> Service<ChargeAuthenticationResponse> {
        let request = SubmitBirthdayRequest(birthday: birthday, reference: reference)
        return service.postSubmitBirthday(request)
    }

    /// Continues the Charge flow by authenticating a user with their address
    /// - Parameters:
    ///   - address: An ``Address`` object describing the user's address
    ///   - reference: The reference of the current transaction
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(withAddress address: Address,
                            reference: String) -> Service<ChargeAuthenticationResponse> {
        let request = SubmitAddressRequest(address: address, reference: reference)
        return service.postSubmitAddress(request)
    }

    /// Listens for a response after presenting a 3DS URL in a webview for authentication
    /// - Parameter transactionId:The ID of the current transaction that is being authenticated
    /// - Returns: A ``Service`` with the results of the authentication
    func listenFor3DSResponse(for transactionId: String) -> Service<ChargeAuthenticationResponse> {
        let channelName = "3DS_\(transactionId)"
        let subscription: any Subscription = PusherSubscription(channelName: channelName, eventName: "response")
        return Service(subscription)
    }

}
