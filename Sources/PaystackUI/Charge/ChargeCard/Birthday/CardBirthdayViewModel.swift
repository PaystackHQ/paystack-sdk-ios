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
            let birthday = try constructBirthday()
            let authenticationResult = try await repository.submitBirthday(
                birthday, accessCode: chargeCardContainer.accessCode)
            await chargeCardContainer.processTransactionResponse(authenticationResult)
        } catch {
            let error = ChargeError(error: error)
            chargeCardContainer.displayTransactionError(error)
        }
    }

    private func constructBirthday() throws -> Date {
        guard let monthString = month?.formattedRepresentation,
              let date = DateFormatter.toDate(usingFormat: "yyyy-MM-dd",
                                              from: "\(year)-\(monthString)-\(day)") else {
            throw ChargeError(message: "Invalid Birthday entered")
        }
        return date
    }

    func cancelTransaction() {
        chargeCardContainer.restartCardPayment()
    }

}
