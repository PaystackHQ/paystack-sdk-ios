import Foundation

public enum TransactionError {
    /// The transaction has expired and cannot be continued. A new transaction need to be initiated
    case transactionTimedOut
}
