import Foundation

protocol PayWithTransferService: PaystackService {
    func postPayWithTransfer(_ request: PayWithTransferRequest)
        -> Service<PayWithTransferResponse>
}

struct PayWithTransferServiceImplementation: PayWithTransferService {

    var config: PaystackConfig

    var parentPath: String {
        return "checkout"
    }

    func postPayWithTransfer(_ request: PayWithTransferRequest)
        -> Service<PayWithTransferResponse> {
        return post("/pay_with_transfer", request)
            .asService()
    }
}
