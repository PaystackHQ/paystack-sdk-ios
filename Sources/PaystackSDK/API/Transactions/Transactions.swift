import Foundation

/// The Transactions API allows you create and manage payments on your integration.
public extension Paystack {
    
    private var service: TransactionService {
        return TransactionServiceImplementation(config: config)
    }
    
    func verifyAccessCode(_ code: String) -> Service<VerifyAccessCodeResponse> {
        return service.getVerifyAccessCode(code)
    }
    
}
