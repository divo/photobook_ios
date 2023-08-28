//
//  WebView.swift
//  Mementos
//
//  Created by Steven Diviney on 15/06/2023.
//

import Foundation
import WebKit
import SwiftUI
import Alamofire

struct WebViewContainer: View {
  let webView: WebView
  @Binding var title: String
  @State var profileTitle: String = "Profile"
  let profileUrl = URL(string: Constants.baseURL + "/users/edit/")!
  @State var pushProfile: Bool = false
  
  init(url: URL, navigationActions: [String]? = nil, navigationCallback: ((String, String, [URLQueryItem]?) -> ())? = nil, title: Binding<String>) {
    self._title = title
    self.webView = WebView(url: url, navigationActions: navigationActions, navigationCallback: navigationCallback)
  }
  
  var body: some View {
    NavigationLink(destination: WebViewContainer(url: profileUrl, title: $profileTitle), isActive: $pushProfile) { EmptyView() }
    webView
      .toolbar {
        ToolbarItem(placement: .principal) { // <3>
          Text(title).font(.headline)
        }
      }.toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            self.pushProfile = true
          } label: {
            Image(systemName: "person.crop.circle")
          }
        }
      }.edgesIgnoringSafeArea(.bottom)
  }
  
}

struct WebView: UIViewRepresentable{
  let url: URL
  let webDataStore = WKWebsiteDataStore.default()
  let configuration: WKWebViewConfiguration
  let webView: WKWebView
  let dataModel: WebViewDataModel
  
  init(url: URL, navigationActions: [String]? = nil, navigationCallback: ((String, String, [URLQueryItem]?) -> ())? = nil) {
    self.url = url
    self.configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = webDataStore
    self.webView = WKWebView(frame: .zero, configuration: configuration)
    self.webView.scrollView.showsHorizontalScrollIndicator = false
    self.dataModel = WebViewDataModel(navigationActions: navigationActions, navigationCallback: navigationCallback)
    
    webView.navigationDelegate = dataModel
    webView.scrollView.delegate = ScrollViewDelegate()
    webView.customUserAgent = "Mementos-iOS"
    if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
        webView.isInspectable = true
    }
    dataModel.webView = self
  }
  
  func makeUIView(context: Context) -> WKWebView {
    return webView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
//    print("WebView \(ObjectIdentifier(webView)) update called: \((uiView as? WKWebView)?.url)")
    let request = URLRequest(url: url)
    (uiView as? WKWebView)?.load(request)
  }
  
  func reload() {
    webView.reload()
  }
}

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
  func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    scrollView.pinchGestureRecognizer?.isEnabled = false
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    scrollView.minimumZoomScale = scrollView.zoomScale
    scrollView.maximumZoomScale = scrollView.zoomScale
  }
}

// TODO: If this remains the UIDelegate it needs to be renamed
//class WebViewDataModel: ObservableObject {
class WebViewDataModel: NSObject, ObservableObject, WKNavigationDelegate {
  @Published var railsCookie: HTTPCookie?
  let navigationActions: [String]?
  let navigationCallback: ((String, String, [URLQueryItem]?) -> ())?
  var webView: WebView! // Mist be a cleaner pattern for this, I've just forgotten it
  
  init(navigationActions: [String]?, navigationCallback: ((String, String, [URLQueryItem]?) -> ())?) {
    self.navigationActions = navigationActions
    self.navigationCallback = navigationCallback
  }
  
  func fetch_rails_cookie() {
    webView.webDataStore.httpCookieStore.getAllCookies { cookies in
      AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: self.webView.url, mainDocumentURL: nil)
    }
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    fetch_rails_cookie()
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//    print("WebView \(ObjectIdentifier(webView)) navigation: \(navigationAction.request.url)")
    guard let url = navigationAction.request.url else {
      decisionHandler(.cancel)
      return
    }
    
    if let navigationActions = self.navigationActions,
       let navigationCallback = self.navigationCallback,
       let action = url.host() {
      if navigationActions.contains(action) {
        let destination = url.lastPathComponent
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        navigationCallback(action, destination, queryItems)
        decisionHandler(.cancel)
        return
      }
    }
    decisionHandler(.allow)
  }
}
