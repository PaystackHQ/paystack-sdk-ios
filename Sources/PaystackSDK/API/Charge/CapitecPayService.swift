import Foundation

protocol CapitecPayService: PaystackService {
    func postAuthenticate(_ request: CapitecPayAuthenticateRequest)
        -> Service<CapitecPayAuthenticateResponse>
    func postRequery(transactionReference: String)
        -> Service<ChargeResponse>
}

struct CapitecPayServiceImplementation: CapitecPayService {

    var config: PaystackConfig

    var parentPath: String { "capitec-pay" }

    func postAuthenticate(_ request: CapitecPayAuthenticateRequest)
        -> Service<CapitecPayAuthenticateResponse> {
        return post("/authenticate", request)
            .asService()
    }

    func postRequery(transactionReference: String)
        -> Service<ChargeResponse> {
        return post("/requery/\(transactionReference)", EmptyRequest())
            .asService()
    }
}
