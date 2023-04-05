import Foundation

protocol ChargeService: PaystackService {
    func postSubmitPin(_ request: SubmitPinRequest) -> Service<ChargeAuthenticationResponse>
    func postSubmitOtp(_ request: SubmitOtpRequest) -> Service<ChargeAuthenticationResponse>
    func postSubmitPhone(_ request: SubmitPhoneRequest) -> Service<ChargeAuthenticationResponse>
    func postSubmitBirthday(_ request: SubmitBirthdayRequest) -> Service<ChargeAuthenticationResponse>
    func postSubmitAddress(_ request: SubmitAddressRequest) -> Service<ChargeAuthenticationResponse>
}

struct ChargeServiceImplementation: ChargeService {
    var config: PaystackConfig

    var parentPath: String {
        return "charge"
    }

    func postSubmitPin(_ request: SubmitPinRequest) -> Service<ChargeAuthenticationResponse> {
        return post("/submit_pin", request)
            .asService()
    }

    func postSubmitOtp(_ request: SubmitOtpRequest) -> Service<ChargeAuthenticationResponse> {
        return post("/submit_otp", request)
            .asService()
    }

    func postSubmitPhone(_ request: SubmitPhoneRequest) -> Service<ChargeAuthenticationResponse> {
        return post("/submit_phone", request)
            .asService()
    }

    func postSubmitBirthday(_ request: SubmitBirthdayRequest) -> Service<ChargeAuthenticationResponse> {
        return post("/submit_birthday", request)
            .asService()
    }

    func postSubmitAddress(_ request: SubmitAddressRequest) -> Service<ChargeAuthenticationResponse> {
        return post("/submit_address", request)
            .asService()
    }

}
