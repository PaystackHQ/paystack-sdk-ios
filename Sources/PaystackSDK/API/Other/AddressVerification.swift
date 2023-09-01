import Foundation

public extension Paystack {

    private var service: AddressVerificationService {
        return AddressVerificationServiceImplementation(config: config)
    }

    /// Returns a list of states for a provided country, to be used when Address authentication is required
    /// - Parameter countryCode: The country code to provide a list of states for
    /// - Returns: A ``Service`` with the ``AddressStatesResponse`` response
    func addressStates(for countryCode: String) -> Service<AddressStatesResponse> {
        service.getAddressStates(forCountryCode: countryCode)
    }
}
