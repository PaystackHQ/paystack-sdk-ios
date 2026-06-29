import SwiftUI
import PaystackCore

@available(iOS 14.0, *)
struct ChannelSelectionView: View {

    @EnvironmentObject
    var visibilityContainer: ViewVisibilityContainer
    @StateObject
    var viewModel: ChannelSelectionViewModel
    let supportedChannels: [SupportedChannel]

    init(state: Binding<ChargeState>,
         supportedChannels: [SupportedChannel],
         information: VerifyAccessCode) {
        self._viewModel = StateObject(wrappedValue: ChannelSelectionViewModel(state: state, information: information))
        self.supportedChannels = supportedChannels
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {

                Text("Choose a payment method to continue")
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
                    .multilineTextAlignment(.center)

                VStack(spacing: .singlePadding) {
                    ForEach(supportedChannels) { channel in
                        Button(action: { viewModel.choose(channel) }) {
                            ChannelView(channelTitle: channel.displayTitle,
                                        image: channel.image)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, .doublePadding)
        }
    }
}

class ChannelSelectionViewModel: ObservableObject {
    @Binding
    var state: ChargeState
    private let information: VerifyAccessCode
    init(state: Binding<ChargeState>, information: VerifyAccessCode) {
        self._state = state
        self.information = information
    }

    func choose(_ channel: SupportedChannel) {
        switch channel {
        case .card:
            state = .payment(type: .card(transactionInformation: self.information))
        case .mobileMoney(let provider):
            state = .payment(type: .mobileMoney(transactionInformation: self.information,
                                                provider: provider))
        case .bankTransfer(let config):
            state = .payment(type: .bankTransfer(transactionInformation: self.information,
                                                 config: config))
        case .zap(let config):
            state = .payment(type: .zap(transactionInformation: self.information,
                                        config: config))
        }
    }
}

struct ChannelView: View {

    let channelTitle: String
    let image: Image

    private let imageSlotSize: CGFloat = 20

    var body: some View {

        HStack(spacing: .doublePadding) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSlotSize, height: imageSlotSize)

            Text(channelTitle)
                .font(.body16M)
                .foregroundColor(.stackBlue)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer()
        }
        .padding(.doublePadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .cornerRadius(.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadius)
                .stroke(Color.navy05, lineWidth: 1)
        )
    }
}
