import SwiftUI

@available(iOS 14.0, *)
struct NavigationalButton<Content: View, Destination: View, Result>: View {

    @StateObject
    var chargeCardContainer: ViewVisibilityContainer<Result>

    @ViewBuilder
    var content: Content

    var destination: Destination

    init(onComplete: @escaping (Result) -> Void,
         destination: Destination,
         @ViewBuilder content: () -> Content) {
        self._chargeCardContainer = StateObject(wrappedValue: ViewVisibilityContainer(onComplete: onComplete))
        self.content = content()
        self.destination = destination
    }

    var body: some View {
        Button(action: startFlow) {
            content
        }
        .sheet(isPresented: $chargeCardContainer.showChargeCardFlow) {
            destination
        }
        .environmentObject(chargeCardContainer)
    }

    func startFlow() {
        chargeCardContainer.showChargeCardFlow = true
    }
}
