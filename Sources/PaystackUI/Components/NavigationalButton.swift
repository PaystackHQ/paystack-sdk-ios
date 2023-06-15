import SwiftUI

@available(iOS 14.0, *)
struct NavigationalButton<Content: View, Destination: View>: View {

    @StateObject
    var visibilityContainer: ViewVisibilityContainer

    @ViewBuilder
    var content: Content

    var destination: Destination

    init(onComplete: @escaping (TransactionResult) -> Void,
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
        .paymentSheet(isPresented: $visibilityContainer.showModal,
                      onCloseTapped: closeButtonTapped) {
            destination
                .confirmationDialog(title: "Do you want to abort this transaction?",
                                    isPresented: $visibilityContainer.showCancellationConfirmation,
                                    confirmationText: "Abort Transaction",
                                    onConfirmation: visibilityContainer.cancelAndDismiss)
        }
        .environmentObject(visibilityContainer)
    }

    func startFlow() {
        visibilityContainer.showModal = true
    }

    func closeButtonTapped() {
        visibilityContainer.showCancellationConfirmation = true
    }
}
