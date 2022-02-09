import Foundation
import Paystack

protocol TransactionService: PaystackService {
    func getVerifyAccessCode(_ id: Int) -> Service<TransactionResponse>
}

struct TransactionServiceImplementation: TransactionService {
    
    var config: PaystackConfig
    
    var parentPath: String {
        return "transaction"
    }
    
    func getVerifyAccessCode(_ id: Int) -> Service<TransactionResponse> {
        return get("/verify_access_code/\(id)")
            .asService()
    }
    
}
