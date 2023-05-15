import Foundation

public extension Paystack {
    private var service: ChargeService {
        return ChargeServiceImplementation(config: config)
    }

    /// Continues the Charge flow by authenticating a user
    /// - Parameter authenticationType: The type of authentication with the associated payload with reference provided.
    /// - Returns: A ``Service`` with the results of the authentication
    func authenticateCharge(_ authenticationType: AuthenticationType) -> Service<ChargeAuthenticationResponse> {
        switch authenticationType {
        case .otp(let otpPayload):
            return service.postSubmitOtp(otpPayload)
        case .pin(let pinPayload):
            return service.postSubmitPin(pinPayload)
        case .phone(let phonePayload):
            return service.postSubmitPhone(phonePayload)
        case .birthday(let birthdayPayload):
            return service.postSubmitBirthday(birthdayPayload)
        case .address(let addressPayload):
            return service.postSubmitAddress(addressPayload)
        }
    }

    /// Listens for a response after presenting a 3DS URL in a webview for authentication
    /// - Parameter transactionId:The ID of the current transaction that is being authenticated
    /// - Returns: A ``Service`` with the results of the authentication
    func listenFor3DSResponse(for transactionId: String) -> Service<ChargeAuthenticationResponse> {
        let channelName = "3DS_\(transactionId)"
        let subscriptionBuilder = subscriptionBuilder
            .provideSubscriptionDetails((channelName: channelName,
                                         eventName: "response"))
        return Service(subscriptionBuilder)
    }

}
