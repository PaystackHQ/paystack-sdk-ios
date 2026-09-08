import Foundation

enum ChargePaymentType: Equatable {
    case card(transactionInformation: VerifyAccessCode)
    case mobileMoney(transactionInformation: VerifyAccessCode,
                     provider: MobileMoneyChannel)
    case bankTransfer(transactionInformation: VerifyAccessCode,
                      config: BankTransferConfig)
    case zap(transactionInformation: VerifyAccessCode,
             config: ZapConfig)
    case capitecPay(transactionInformation: VerifyAccessCode,
                    config: CapitecPayConfig)
    case qr(transactionInformation: VerifyAccessCode,
            config: QRConfig)
}
