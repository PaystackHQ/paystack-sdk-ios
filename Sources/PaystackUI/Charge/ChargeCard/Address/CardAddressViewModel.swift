import Foundation
import PaystackCore

class CardAddressViewModel: ObservableObject {

    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository
    var stateList: [String]

    @Published
    var street: String = ""

    @Published
    var zipCode: String = ""

    @Published
    var state: String?

    @Published
    var city: String = ""

    init(states: [String],
         chargeCardContainer: ChargeCardContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.chargeCardContainer = chargeCardContainer
        self.stateList = states
        self.repository = repository
    }

    var isValid: Bool {
        !street.isEmpty &&
        !zipCode.isEmpty &&
        !city.isEmpty &&
        state != nil
    }

    func submitAddress() async {
        do {
            let address = Address(address: street, city: city, state: state ?? "", zipCode: zipCode)
            let authenticationResult = try await repository.submitAddress(
                address, accessCode: chargeCardContainer.accessCode)
            await chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            let error = ChargeError(error: error)
            chargeCardContainer.displayTransactionError(error)
        }
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }

}
