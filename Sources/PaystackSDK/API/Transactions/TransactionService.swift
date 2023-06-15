import Foundation

protocol TransactionService: PaystackService {
    func getVerifyAccessCode(_ code: String) -> Service<VerifyAccessCodeResponse>
}

struct TransactionServiceImplementation: TransactionService {
    
    var config: PaystackConfig
    
    var parentPath: String {
        return "transaction"
    }
    
    func getVerifyAccessCode(_ code: String) -> Service<VerifyAccessCodeResponse> {
        return get("/verify_access_code/\(code)")
            .asService()
    }
    
}
