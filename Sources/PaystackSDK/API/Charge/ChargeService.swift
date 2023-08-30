import Foundation

protocol ChargeService: PaystackService {
    func postSubmitPin(_ request: SubmitPinRequest) -> Service<ChargeResponse>
    func postSubmitOtp(_ request: SubmitOtpRequest) -> Service<ChargeResponse>
    func postSubmitPhone(_ request: SubmitPhoneRequest) -> Service<ChargeResponse>
    func postSubmitBirthday(_ request: SubmitBirthdayRequest) -> Service<ChargeResponse>
    func postSubmitAddress(_ request: SubmitAddressRequest) -> Service<ChargeResponse>
}

struct ChargeServiceImplementation: ChargeService {
    var config: PaystackConfig

    var parentPath: String {
        return "transaction/charge"
    }

    func postSubmitPin(_ request: SubmitPinRequest) -> Service<ChargeResponse> {
        return post("/submit_pin", request)
            .asService()
    }

    func postSubmitOtp(_ request: SubmitOtpRequest) -> Service<ChargeResponse> {
        return post("/submit_otp", request)
            .asService()
    }

    func postSubmitPhone(_ request: SubmitPhoneRequest) -> Service<ChargeResponse> {
        return post("/submit_phone", request)
            .asService()
    }

    func postSubmitBirthday(_ request: SubmitBirthdayRequest) -> Service<ChargeResponse> {
        return post("/submit_birthday", request)
            .asService()
    }

    func postSubmitAddress(_ request: SubmitAddressRequest) -> Service<ChargeResponse> {
        return post("/submit_address", request)
            .asService()
    }

}
