import Foundation

protocol TransactionService: PaystackService {
    func getVerifyAccessCode(_ code: String) -> Service<VerifyAccessCodeResponse>
    func postSubmitCardCharge(_ request: ChargeCardRequest) -> Service<ChargeResponse>
}

struct TransactionServiceImplementation: TransactionService {

    var config: PaystackConfig

    var parentPath: String {
        return "transaction"
    }

    func postSubmitCardCharge(_ request: ChargeCardRequest) -> Service<ChargeResponse> {
        return post("/charge", request)
            .asService()
    }

    func getVerifyAccessCode(_ code: String) -> Service<VerifyAccessCodeResponse> {
        return get("/verify_access_code/\(code)")
            .asService()
    }

}
