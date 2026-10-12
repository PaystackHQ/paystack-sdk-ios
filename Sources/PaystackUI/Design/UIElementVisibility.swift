import SwiftUI
import PaystackCore

enum AudienceGatedElement: CaseIterable {
    case zapQRCode
    case zapOpenAppButton
    case bankTransferCopyButtons
    case scanToPayQRCode
    case scanToPayQRNumber
    case scanToPaySeeAppsButton
}

enum AudienceCopy: CaseIterable {
    case zapInstruction
    case scanToPayInstruction
}

extension DisplayAudience {

    func shows(_ element: AudienceGatedElement) -> Bool {
        switch element {
        case .zapQRCode:
            return resolve(customerFacing: false, merchantFacing: true)
        case .zapOpenAppButton:
            return resolve(customerFacing: true, merchantFacing: false)
        case .bankTransferCopyButtons:
            return resolve(customerFacing: true, merchantFacing: false)
        case .scanToPayQRCode:
            return resolve(customerFacing: false, merchantFacing: true)
        case .scanToPayQRNumber:
            return resolve(customerFacing: true, merchantFacing: false)
        case .scanToPaySeeAppsButton:
            return resolve(customerFacing: true, merchantFacing: false)
        }
    }

    func text(_ copy: AudienceCopy) -> String {
        switch copy {
        case .zapInstruction:
            return resolve(customerFacing: "Open Zap to complete this payment",
                           merchantFacing: "Scan this QR code with Zap to complete this payment")
        case .scanToPayInstruction:
            return resolve(customerFacing: "Open any Scan to Pay app to complete this payment",
                           merchantFacing: "Open any Scan to Pay app on your phone to scan the QR code")
        }
    }

    private func resolve<Value>(customerFacing: Value, merchantFacing: Value) -> Value {
        self == .merchantFacing ? merchantFacing : customerFacing
    }
}

private struct AudienceVisibilityModifier: ViewModifier {

    @Environment(\.displayAudience)
    private var displayAudience

    let element: AudienceGatedElement

    @ViewBuilder
    func body(content: Content) -> some View {
        if displayAudience.shows(element) {
            content
        }
    }
}

extension View {

    func visible(for element: AudienceGatedElement) -> some View {
        modifier(AudienceVisibilityModifier(element: element))
    }
}
