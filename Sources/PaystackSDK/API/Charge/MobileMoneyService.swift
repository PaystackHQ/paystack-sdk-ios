import Foundation

protocol MobileMoneyService: PaystackService {
    func postChargeMobileMoney(_ request: MobileMoneyChargeRequest) -> Service<MobileMoneyChargeResponse>
}

struct MobileMoneyServiceImplementation: MobileMoneyService {

    var config: PaystackConfig

    var parentPath: String {
        return "charge"
    }

    func postChargeMobileMoney(_ request: MobileMoneyChargeRequest) -> Service<MobileMoneyChargeResponse> {
        return post("/mobile_money", request)
            .asService()
    }
}
