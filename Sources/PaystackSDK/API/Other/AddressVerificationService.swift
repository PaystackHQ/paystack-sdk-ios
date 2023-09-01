import Foundation

protocol AddressVerificationService: PaystackService {
    func getAddressStates(forCountryCode code: String) -> Service<AddressStatesResponse>
}

struct AddressVerificationServiceImplementation: AddressVerificationService {

    var config: PaystackConfig

    var parentPath: String {
        return "address_verification"
    }

    func getAddressStates(forCountryCode code: String) -> Service<AddressStatesResponse> {
        return get("/states")
            .addQueryItem("country", code)
            .asService()
    }

}
