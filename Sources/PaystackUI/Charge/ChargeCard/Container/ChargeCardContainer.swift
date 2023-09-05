import Foundation

protocol ChargeCardContainer {
    var inTestMode: Bool { get }
    var accessCode: String { get }
    func processTransactionResponse(_ response: ChargeCardTransaction) async
    func displayTransactionError(_ error: ChargeError)
    func restartCardPayment()
    func switchToTestModeCardSelection()
}
