import Foundation
import PaystackSDK

/// The Transactions API allows you create and manage payments on your integration.
public extension Paystack {
    
    private var service: TransactionService {
        return TransactionServiceImplementation(config: config)
    }
    
    func verifyAccessCode(_ id: Int) -> Service<TransactionResponse> {
        return service.getVerifyAccessCode(id)
    }
    
}
