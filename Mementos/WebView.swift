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

struct WebView: UIViewRepresentable {
  let webView: WKWebView
  
  init(webView: WKWebView) {
    self.webView = webView
  }
  
  func makeUIView(context: Context) -> some UIView {
    webView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) { }
}

final class WebViewModel: ObservableObject {
  var url = URL(string: Constants.baseURL)! {
    didSet {
      loadURL()
    }
  }
  
  let webView: WKWebView
  let dataModel: WebViewDataModel
  
  init() {
    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = WKWebsiteDataStore.default()

    let scrollDisable: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"

    let script: WKUserScript =
         WKUserScript(source: scrollDisable, 
            injectionTime: .atDocumentEnd, 
            forMainFrameOnly: true)
    let userContentController: WKUserContentController = WKUserContentController()
    configuration.userContentController = userContentController
    userContentController.addUserScript(script)

    self.webView = WKWebView(frame: .zero, configuration: configuration)
    self.dataModel = WebViewDataModel(webView: self.webView)

    webView.scrollView.showsHorizontalScrollIndicator = false
    webView.customUserAgent = "Mementos-iOS"
    webView.navigationDelegate = dataModel
  }
  
  func setActionHandler(navigationActions: [String]?, navigationCallback: ((String, String, [URLQueryItem]?) -> ())?) {
    dataModel.navigationActions = navigationActions
    dataModel.navigationCallback = navigationCallback
  }
  
//  func loadURL(urlString: String) {
//    guard let url = URL(string: urlString) else {
//      return
//    }
//    loadURL(url: url)
//  }
  
  func loadURL() {
    loadURL(url: url)
  }
  
  private func loadURL(url: URL?) {
    guard let url = url else { return }
    webView.load(URLRequest(url: url))
  }
  
}


struct WebViewContainer: View {
//  @StateObject var viewModel: WebViewModel = WebViewModel()
//  var url: URL
  var navigationActions: [String]? = nil
  var navigationCallback: ((String, String, [URLQueryItem]?) -> ())? = nil
  
//  @Binding var title: String
  @State var profileTitle: String = "Profile"
  let profileUrl = URL(string: Constants.baseURL + "/users/edit/")!
  @State var pushProfile: Bool = false
  
//  init(url: URL? = nil, navigationActions: [String]? = nil, navigationCallback: ((String, String, [URLQueryItem]?) -> ())? = nil) { //, title: Binding<String>) {
//    self.url = url
//    self.navigationActions = navigationActions
//    self.navigationCallback = navigationCallback
////    self._title = title
//  }
  
//  init(url: Binding<URL>) {
//    self.viewModel = WebViewModel()
//  }
  
  func loadURL(_ url: URL) {
//      viewModel.url = url
//    self.url = url
  }
  
  var body: some View {
//    NavigationLink(destination: WebViewContainer(url: profileUrl, title: $profileTitle), isActive: $pushProfile) { EmptyView() }
//    NavigationLink(destination: WebViewContainer(url: profileUrl), isActive: $pushProfile) { EmptyView() }
//    WebView(webView: viewModel.webView)
    Spacer()
      .toolbar {
        ToolbarItem(placement: .principal) { // <3>
//          Text(title).font(.headline)
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
      .onAppear {
//        viewModel.loadURL(url: url)
//        viewModel.loadURL()
//        viewModel.setActionHandler(navigationActions: navigationActions, navigationCallback: navigationCallback)
      }
  }
  
}

//struct WebView: UIViewRepresentable{
//  let viewModel: WebViewModel
//  let webDataStore = WKWebsiteDataStore.default()
//  let configuration: WKWebViewConfiguration
//  let webView: WKWebView
//  let dataModel: WebViewDataModel
//
//  init(url: URL, navigationActions: [String]? = nil, navigationCallback: ((String, String, [URLQueryItem]?) -> ())? = nil) {
//    self.viewModel = WebViewModel(url: url)
////    self.configuration = WKWebViewConfiguration()
////    configuration.websiteDataStore = webDataStore
////
////    let scrollDisable: String = "var meta = document.createElement('meta');" +
////        "meta.name = 'viewport';" +
////        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
////        "var head = document.getElementsByTagName('head')[0];" +
////        "head.appendChild(meta);"
////
////    let script: WKUserScript = WKUserScript(source: scrollDisable, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
////    let userContentController: WKUserContentController = WKUserContentController()
////    self.configuration.userContentController = userContentController
////    userContentController.addUserScript(script)
//
////    self.webView = WKWebView(frame: .zero, configuration: configuration)
////    self.webView.scrollView.showsHorizontalScrollIndicator = false
////    self.dataModel = WebViewDataModel(navigationActions: navigationActions, navigationCallback: navigationCallback)
//
//    webView.navigationDelegate = dataModel
//    webView.customUserAgent = "Mementos-iOS"
//    if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
//        webView.isInspectable = true
//    }
//    dataModel.webView = self
//  }
//
//  func makeUIView(context: Context) -> WKWebView {
//    let request = URLRequest(url: viewModel.currentURL)
//    webView.load(request)
//    return webView
//  }
//
//  func updateUIView(_ uiView: UIViewType, context: Context) {
////    print("WebView \(ObjectIdentifier(webView)) update called: \((uiView as? WKWebView)?.url)")
//    if viewModel.needsRefresh() {
//      let request = URLRequest(url: viewModel.render())
//      (uiView as? WKWebView)?.load(request)
//    }
//  }
//
//  func updateURL(_ url: URL) {
//    self.viewModel.currentURL = url
//    let request = URLRequest(url: url)
//    webView.load(request)
//  }
//
//  func reload() {
//    webView.reload()
//  }
//}

// TODO: If this remains the UIDelegate it needs to be renamed
//class WebViewDataModel: ObservableObject {
class WebViewDataModel: NSObject, ObservableObject, WKNavigationDelegate {
  @Published var railsCookie: HTTPCookie?
  var navigationActions: [String]?
  var navigationCallback: ((String, String, [URLQueryItem]?) -> ())?
  var webView: WKWebView! // Mist be a cleaner pattern for this, I've just forgotten it

  init(webView: WKWebView) { 
    self.webView = webView
  }

//  init(navigationActions: [String]?, navigationCallback: ((String, String, [URLQueryItem]?) -> ())?) {
//    self.navigationActions = navigationActions
//    self.navigationCallback = navigationCallback
//  }

  func fetch_rails_cookie() {
    webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
//      AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: self.webView.viewModel.currentURL, mainDocumentURL: nil)
      AF.session.configuration.httpCookieStorage?
        .setCookies(cookies, for: Constants.renameMe, mainDocumentURL: nil)
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
