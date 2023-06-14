import Foundation

// TODO: This will be built upon to include more information/more statuses if relevant
public enum TransactionResult {
    case success
    case failure
    case pending
    case cancelled
}
