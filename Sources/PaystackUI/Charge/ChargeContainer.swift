import Foundation

protocol ChargeContainer {
    func processSuccessfulTransaction(details: VerifyAccessCode)
    func processFailedTransaction()
}
