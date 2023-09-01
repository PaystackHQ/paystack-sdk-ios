import Foundation

class CardBirthdayViewModel: ObservableObject {
    var chargeCardContainer: ChargeCardContainer
    var repository: ChargeCardRepository

    @Published
    var day: String = ""

    @Published
    var month: Month?

    @Published
    var year: String = ""

    init(chargeCardContainer: ChargeCardContainer,
         repository: ChargeCardRepository = ChargeCardRepositoryImplementation()) {
        self.chargeCardContainer = chargeCardContainer
        self.repository = repository
    }

    var isValid: Bool {
        !day.isEmpty &&
        !year.isEmpty &&
        month != nil
    }

    func submitBirthday() async {
        do {
            let formattedBirthday = "\(year)-\(month?.formattedRepresentation ?? "00")-\(day)"
            let authenticationResult = try await repository.submitBirthday(
                formattedBirthday, accessCode: chargeCardContainer.accessCode)
            await chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            // TODO: Determine error handling once we have further information
        }
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }

}
