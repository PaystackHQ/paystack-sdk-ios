import Foundation
import Paystack

/// The Transactions API allows you create and manage payments on your integration.
public extension Paystack {
    
    private var service: CheckoutService {
        return CheckoutServiceImplementation(config: config)
    }
    
    func requestInline(_ queries: [RequestInlineQuery]) -> Service<TransactionResponse> {
        return service.getRequestInline(queries + [.key(config.apiKey)])
    }
    
    func chargeCard(_ request: ChargeRequest) -> Service<ChargeResponse> {
        // TODO: Encrypt clientdata and handle in request
        return service.postChargeCard(request)
    }
    
    func chargeAVS(_ request: AVSChargeRequest) -> Service<ChargeResponse> {
        return service.postChargeAVS(request)
    }
    
    func validateCharge(_ request: ValidateChargeRequest) -> Service<ChargeResponse> {
        return service.postValidateCharge(request)
    }
    
    func requeryCharge(_ transactionId: Int) -> Service<ChargeResponse> {
        return service.getRequeryCharge(transactionId)
    }
    
}
