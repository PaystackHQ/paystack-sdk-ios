import SwiftUI
import PaystackCore
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 14.0, *)
struct QRCodeImage: View {

    let url: URL

    #if canImport(UIKit)
    @State private var image: UIImage?
    #endif
    @State private var loadFailed = false

    var body: some View {
        ZStack {
            #if canImport(UIKit)
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .transition(.opacity)
            } else if loadFailed {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.warning02)
            } else {
                ShimmerPlaceholder()
            }
            #else
            ShimmerPlaceholder()
            #endif
        }
        .task { await load() }
    }

    private func load() async {
        #if canImport(UIKit)
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loaded = UIImage(data: data) {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self.image = loaded
                    }
                }
            } else {
                await MainActor.run { self.loadFailed = true }
            }
        } catch {
            PaystackCore.Logger.error("Zap QR load failed: %@",
                                    arguments: error.localizedDescription)
            await MainActor.run { self.loadFailed = true }
        }
        #endif
    }
}

@available(iOS 14.0, *)
struct ShimmerPlaceholder: View {

    @State private var phase: CGFloat = -1.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.gray01
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.white.opacity(0.0), location: 0.0),
                        .init(color: Color.white.opacity(0.5), location: 0.5),
                        .init(color: Color.white.opacity(0.0), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                    .frame(width: geo.size.width * 1.5)
                    .offset(x: phase * geo.size.width)
            }
            .cornerRadius(.cornerRadius)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1.0
                }
            }
        }
    }
}
