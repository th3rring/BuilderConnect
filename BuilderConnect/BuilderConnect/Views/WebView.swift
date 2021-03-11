import SwiftUI
import Combine
import WebKit

@dynamicMemberLookup
public class WebViewStore: ObservableObject {
  @Published public var webView: WKWebView {
    didSet {
      setupObservers()
    }
  }
  
  public init(webView: WKWebView = WKWebView()) {
    self.webView = webView
    setupObservers()
  }
  
  private func setupObservers() {
    func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
      return webView.observe(keyPath, options: [.prior]) { _, change in
        if change.isPrior {
          self.objectWillChange.send()
        }
      }
    }
    // Setup observers for all KVO compliant properties
    observers = [
      subscriber(for: \.title),
      subscriber(for: \.url),
      subscriber(for: \.isLoading),
      subscriber(for: \.estimatedProgress),
      subscriber(for: \.hasOnlySecureContent),
      subscriber(for: \.serverTrust),
      subscriber(for: \.canGoBack),
      subscriber(for: \.canGoForward)
    ]
  }
  
  private var observers: [NSKeyValueObservation] = []
  
  public subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T {
    webView[keyPath: keyPath]
  }
}

/// A container for using a WKWebView in SwiftUI
public struct WebView: View, UIViewRepresentable {
  /// The WKWebView to display
  public let webView: WKWebView
  
  public init(webView: WKWebView) {
    
    let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        
        "meta.content = 'width=\(UIScreen.main.bounds.size.width), initial-scale=0.75, maximum-scale=1.0, user-scalable=yes';" +
        "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"
    
    
    let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    webView.configuration.ignoresViewportScaleLimits = true
    
    
    self.webView = webView
    webView.configuration.userContentController.addUserScript(script)
    

  }
  
  public func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
    
    webView
  }
  
  public func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
  }
}
