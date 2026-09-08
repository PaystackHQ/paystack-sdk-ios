import Foundation

protocol QRService: PaystackService {
    func postGenerate(_ request: QRGenerateRequest)
        -> Service<QRGenerateResponse>
}

struct QRServiceImplementation: QRService {

    var config: PaystackConfig

    var parentPath: String { "offline/qr" }

    func postGenerate(_ request: QRGenerateRequest)
        -> Service<QRGenerateResponse> {
        return post("/generate", request)
            .asService()
    }
}
