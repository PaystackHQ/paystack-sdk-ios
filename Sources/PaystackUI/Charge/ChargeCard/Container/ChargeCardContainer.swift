import Foundation

protocol ChargeCardContainer {
    var inTestMode: Bool { get }
    func restartCardPayment()
    func switchToTestModeCardSelection()
}
