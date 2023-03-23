import Foundation
import PaystackSDK

protocol CheckoutService: PaystackService {
    func getRequestInline(_ queries: [RequestInlineQuery]) -> Service<TransactionResponse>
    func postChargeCard(_ request: ChargeRequest) -> Service<ChargeResponse>
    func postChargeAVS(_ request: AVSChargeRequest) -> Service<ChargeResponse>
    func postValidateCharge(_ request: ValidateChargeRequest) -> Service<ChargeResponse>
    func getRequeryCharge(_ transactionId: Int) -> Service<ChargeResponse>
}

struct CheckoutServiceImplementation: CheckoutService {
    
    var config: PaystackConfig
    
    var parentPath: String {
        return "checkout"
    }
    
    func getRequestInline(_ queries: [RequestInlineQuery]) -> Service<TransactionResponse> {
        return get("/request_inline")
            .setQueryItems(queries.keyPairs)
            .asService()
    }
    
    func postChargeCard(_ request: ChargeRequest) -> Service<ChargeResponse> {
        return post("/card/charge", request)
            .asService()
    }
    
    func postChargeAVS(_ request: AVSChargeRequest) -> Service<ChargeResponse> {
        return post("/card/avs", request)
            .asService()
    }
    
    func postValidateCharge(_ request: ValidateChargeRequest) -> Service<ChargeResponse> {
        return post("/card/validate", request)
            .asService()
    }
    
    func getRequeryCharge(_ transactionId: Int) -> Service<ChargeResponse> {
        return get("/requery/\(transactionId)")
            .asService()
    }
}
