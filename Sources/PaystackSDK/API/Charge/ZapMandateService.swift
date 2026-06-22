import Foundation


protocol ZapMandateService: PaystackService {
    func postZapMandate(_ request: ZapMandateRequest)
        -> Service<ZapMandateResponse>
}

struct ZapMandateServiceImplementation: ZapMandateService {

    var config: PaystackConfig

    var parentPath: String { "bank/digitalbankmandate" }

    var baseURL: String { "https://standard.paystack.co" }

    func postZapMandate(_ request: ZapMandateRequest)
        -> Service<ZapMandateResponse> {
        return postForm("/\(request.id)/\(request.transactionId)",
                        ["wallet_id": request.walletId])
            .asService()
    }
}
