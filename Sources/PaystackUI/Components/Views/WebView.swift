// Implementation based on: https://github.com/danielsaidi/WebViewKit

#if os(iOS)
typealias WebViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias WebViewRepresentable = NSViewRepresentable
#endif

#if os(iOS) || os(macOS)
import SwiftUI
import WebKit

/**
 This view wraps a `WKWebView` and can be used to load a URL
 that refers to both remote or local web pages.

 When you create this view, you can either provide it with a
 url, or an optional url and a view configuration block that
 can be used to configure the created `WKWebView`.

 You can also provide a custom `WKWebViewConfiguration` that
 can be used when initializing the `WKWebView` instance.
 */
struct WebView: WebViewRepresentable {

    // MARK: - Initializers

    /**
     Create a web view that loads the provided url after the
     provided configuration has been applied.

     If the `url` parameter is `nil`, you must manually load
     a url in the configuration block. If you don't, the web
     view will not present any content.

     - Parameters:
       - url: The url of the page to load into the web view, if any.
       - isLoading: A Binding that updates with the current loading state of the web view
       - normalizeScaling: Sets the vieport initial scale to prevent pages looking smaller than expected. Defaults to true.
       - webConfiguration: The WKWebViewConfiguration to apply to the web view, if any.
       - webView: The custom configuration block to apply to the web view, if any.
     */
    init(
        url: URL? = nil,
        isLoading: Binding<Bool> = .constant(false),
        normalizeScaling: Bool = true,
        webConfiguration: WKWebViewConfiguration? = nil,
        viewConfiguration: @escaping (WKWebView) -> Void = { _ in }) {
            self.url = url
            self.normalizeScaling = normalizeScaling
            self._isLoading = isLoading
            self.webConfiguration = webConfiguration
            self.viewConfiguration = viewConfiguration
        }

    // MARK: - Properties
    @Binding var isLoading: Bool
    let normalizeScaling: Bool

    private let url: URL?
    private let webConfiguration: WKWebViewConfiguration?
    private let viewConfiguration: (WKWebView) -> Void

    // MARK: - Functions

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    #if os(iOS)
    func makeUIView(context: Context) -> WKWebView {
        makeView(context: context)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
    #endif

    #if os(macOS)
    func makeNSView(context: Context) -> WKWebView {
        makeView(context: context)
    }

    func updateNSView(_ view: WKWebView, context: Context) {}
    #endif
}

private extension WebView {

    func makeWebView() -> WKWebView {
        guard let configuration = webConfiguration else { return WKWebView() }
        return WKWebView(frame: .zero, configuration: configuration)
    }

    func makeView(context: Context) -> WKWebView {
        let view = makeWebView()
        view.navigationDelegate = context.coordinator
        viewConfiguration(view)
        tryLoad(url, into: view)
        return view
    }

    func tryLoad(_ url: URL?, into view: WKWebView) {
        guard let url = url else { return }
        view.load(URLRequest(url: url))
    }
}

class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WebView

    init(_ parent: WebView) {
        self.parent = parent
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        parent.isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        parent.isLoading = false
        normalizeScaling(on: webView)
    }

    private func normalizeScaling(on webView: WKWebView) {
        guard parent.normalizeScaling else { return }
        var scriptContent = "var meta = document.createElement('meta');"
        scriptContent += "meta.name='viewport';"
        scriptContent += "meta.content='initial-scale=1.0';"
        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"

        webView.evaluateJavaScript(scriptContent, completionHandler: nil)
    }
}
#endif
