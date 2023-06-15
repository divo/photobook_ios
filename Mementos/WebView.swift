//
//  WebView.swift
//  Mementos
//
//  Created by Steven Diviney on 15/06/2023.
//

import Foundation
import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
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

class WebViewDataModel: ObservableObject {
  @Published var railsCookie: HTTPCookie?
  var webView: WebView! // Mist be a cleaner pattern for this, I've just forgotten it
  
  func fetch_rails_cookie() {
    webView.webDataStore.httpCookieStore.getAllCookies { cookies in
      self.railsCookie = cookies.first { cookie in cookie.name == "_photobook_rails_session" }
    }
  }
}
