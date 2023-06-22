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
  @Binding var url: URL
  let webDataStore = WKWebsiteDataStore.default()
  let configuration: WKWebViewConfiguration
  let webView: WKWebView
  let dataModel: WebViewDataModel
  
  init(url: Binding<URL>) {
    self._url = url
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
      AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: self.webView.url, mainDocumentURL: nil)
    }
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    fetch_rails_cookie()
  }
}
