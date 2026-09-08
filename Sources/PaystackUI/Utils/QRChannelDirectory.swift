import Foundation

enum QRChannelDirectory {

    static func entries(for options: [String],
                        transactionId: Int) -> [SupportedChannel] {
        var result: [SupportedChannel] = []

        if options.contains("MPASS_OLTI") {
            result.append(.scanToPay(QRConfig(
                channelOption: "MPASS_OLTI",
                transactionId: transactionId,
                variant: .scanToPay)))
            result.append(.snapScan(QRConfig(
                channelOption: "MPASS_OLTI",
                transactionId: transactionId,
                variant: .snapScan)))
        }

        return result
    }
}
