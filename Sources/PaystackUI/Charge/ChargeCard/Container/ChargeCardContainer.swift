import Foundation

protocol ChargeCardContainer {
    var inTestMode: Bool { get }
    var accessCode: String { get }
    func processTransactionResponse(_ response: ChargeCardTransaction)
    func restartCardPayment()
    func switchToTestModeCardSelection()
}
