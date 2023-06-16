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

struct WebView: UIViewRepresentable{
  let url: URL
  let webDataStore = WKWebsiteDataStore.default()
  let configuration: WKWebViewConfiguration
  let webView: WKWebView
  let dataModel: WebViewDataModel
  
  init(url: URL) {
    self.url = url
    self.configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = webDataStore
    self.webView = WKWebView(frame: .zero, configuration: configuration)
    self.dataModel = WebViewDataModel()
    
    webView.navigationDelegate = dataModel
    dataModel.webView = self
  }
  
  func makeUIView(context: Context) -> some UIView {
    webView.customUserAgent = "Mementos-iOS"
    return webView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    let request = URLRequest(url: url)
    (uiView as? WKWebView)?.load(request)
  }
}

// TODO: If this remains the UIDelegate it needs to be renamed
//class WebViewDataModel: ObservableObject {
class WebViewDataModel: NSObject, ObservableObject, WKNavigationDelegate{
  @Published var railsCookie: HTTPCookie?
  var webView: WebView! // Mist be a cleaner pattern for this, I've just forgotten it
  
  func fetch_rails_cookie() {
    webView.webDataStore.httpCookieStore.getAllCookies { cookies in
      self.railsCookie = cookies.first { cookie in cookie.name == "_photobook_rails_session" }
      // TODO: If I need to force the user to login this can't stay here
      if let cookie = self.railsCookie {
        AF.session.configuration.httpCookieStorage?.setCookie(cookie)
      }
    }
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if railsCookie == nil {
      fetch_rails_cookie()
    }
  }
}
