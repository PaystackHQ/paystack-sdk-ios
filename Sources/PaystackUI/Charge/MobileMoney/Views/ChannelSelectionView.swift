//
//  ChannelSelectionView.swift
//  PaystackUI
//
//  Created by Peter-John Welcome on 2023/12/01.
//

import SwiftUI
import PaystackCore
@available(iOS 14.0, *)
struct ChannelSelectionView: View {

    @EnvironmentObject
    var visibilityContainer: ViewVisibilityContainer
    @StateObject
    var viewModel: ChannelSelectionViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var items: [PaymentChannel] = []
    init(state: Binding<ChargeState>,
         supportedChannels: [SupportedChannels],
         information: VerifyAccessCode) {
        self._viewModel = StateObject(wrappedValue: ChannelSelectionViewModel(state: state, information: information))
        items = supportedChannels.map {
            PaymentChannel(channel: $0)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .triplePadding) {

                Text("Choose a payment method to continue")
                    .font(.body16M)
                    .foregroundColor(.stackBlue)
                    .multilineTextAlignment(.center)
                GeometryReader { geo in
                    LazyVGrid(columns: columns) {
                        ForEach(items) { value in
                            ChannelView(channelTitle: value.title, image: value.image)
                                .padding(.singlePadding)
                                .onTapGesture {
                                    viewModel.chooseChannel(channel: value.channel)
                                }
                                .frame(width: (geo.size.width / CGFloat(items.count)).rounded())
                        }
                    }
                }
            }
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

    func chooseChannel(channel: SupportedChannels) {
        let message = "Card/MPesa payments are not supported. " +
        "Please reach out to your merchant for further information"
        let cause = "There are currently no payment channels on " +
        "your integration that are supported by the SDK"
        switch channel {
        case .CARD:
            state = .payment(type: .card(transactionInformation: self.information))
        case .MPESA:
            state = .payment(type: .mobileMoney(transactionInformation: self.information))
        case .unsupportedChannel:
            state = .error(ChargeError(displayMessage: message, causeMessage: cause))
        }

    }
}

struct PaymentChannel: Identifiable {
    var id: String = UUID().uuidString
    let channel: SupportedChannels
    var title: String {
        channel.rawValue
    }
    var image: Image {
        channel.image
    }
}

struct ChannelView: View {

    let channelTitle: String
    let image: Image

    var body: some View {

        HStack(spacing: .singlePadding) {

            VStack(alignment: .leading, spacing: .singlePadding) {
                image.frame(width: 20, height: 20)
                Text(channelTitle)
                    .font(.body14M)
                    .foregroundColor(.navy02)
            }
            Spacer()
        }
        .padding(.doublePadding)
        .cornerRadius(.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadius)
                .stroke(Color.navy05, lineWidth: 1)
        )
    }
}
