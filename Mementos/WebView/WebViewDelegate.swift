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

class WebViewDelegate: NSObject, ObservableObject, WKNavigationDelegate {
  @Published var railsCookie: HTTPCookie?
  var navigationActions: [String]?
  var navigationCallback: ((String, String, [URLQueryItem]?) -> ())?
  var webView: WKWebView

  init(webView: WKWebView) { 
    self.webView = webView
  }

  func fetch_rails_cookie() {
    webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
      AF.session.configuration.httpCookieStorage?
        .setCookies(cookies, for: Constants.renameMe, mainDocumentURL: nil)
    }
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    fetch_rails_cookie()
  }

  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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
