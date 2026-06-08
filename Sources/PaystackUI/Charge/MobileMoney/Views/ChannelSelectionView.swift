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
    let supportedChannels: [SupportedChannel]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

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
                GeometryReader { geo in
                    LazyVGrid(columns: columns) {
                        ForEach(supportedChannels) { channel in
                            ChannelView(channelTitle: channel.displayTitle, image: channel.image)
                                .padding(.singlePadding)
                                .onTapGesture {
                                    viewModel.choose(channel)
                                }
                                .frame(width: (geo.size.width / CGFloat(supportedChannels.count)).rounded())
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

    func choose(_ channel: SupportedChannel) {
        switch channel {
        case .card:
            state = .payment(type: .card(transactionInformation: self.information))
        case .mobileMoney(let provider):
            state = .payment(type: .mobileMoney(transactionInformation: self.information,
                                                provider: provider))
        }
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
