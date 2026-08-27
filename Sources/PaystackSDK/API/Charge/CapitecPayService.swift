import Foundation

protocol CapitecPayService: PaystackService {
    func postAuthenticate(_ request: CapitecPayAuthenticateRequest)
        -> Service<CapitecPayAuthenticateResponse>
    func postRequery(transactionReference: String)
        -> Service<CapitecResponse>
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
        -> Service<CapitecResponse> {
        return get("/requery/\(transactionReference)")
            .asService()
    }
}
