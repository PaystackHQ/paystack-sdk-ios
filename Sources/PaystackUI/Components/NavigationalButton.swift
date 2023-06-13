import SwiftUI

@available(iOS 14.0, *)
struct NavigationalButton<Content: View, Destination: View, Result>: View {

    @StateObject
    var visibilityContainer: ViewVisibilityContainer<Result>

    @ViewBuilder
    var content: Content

    var destination: Destination

    init(onComplete: @escaping (Result) -> Void,
         destination: Destination,
         @ViewBuilder content: () -> Content) {
        self._visibilityContainer = StateObject(wrappedValue: ViewVisibilityContainer(onComplete: onComplete))
        self.content = content()
        self.destination = destination
    }

    var body: some View {
        Button(action: startFlow) {
            content
        }
        .paymentSheet(isPresented: $visibilityContainer.showModal) { destination }
        .environmentObject(visibilityContainer)
    }

    func startFlow() {
        visibilityContainer.showModal = true
    }
}
