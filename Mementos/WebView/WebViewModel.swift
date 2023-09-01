//
//  WebViewModel.swift
//  Mementos
//
//  Created by Steven Diviney on 01/09/2023.
//

import Foundation
import WebKit
import SwiftUI
import Alamofire

final class WebViewModel: ObservableObject {
  var url = URL(string: Constants.baseURL)! {
    didSet {
      loadURL()
    }
  }
  
  let webView: WKWebView
  let delegate: WebViewDelegate
  
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
    self.delegate = WebViewDelegate(webView: self.webView)

    webView.scrollView.showsHorizontalScrollIndicator = false
    webView.customUserAgent = "Mementos-iOS"
    webView.navigationDelegate = delegate
  }
  
  func setActionHandler(navigationActions: [String]?, navigationCallback: ((String, String, [URLQueryItem]?) -> ())?) {
    delegate.navigationActions = navigationActions
    delegate.navigationCallback = navigationCallback
  }
  
  private func loadURL() {
    loadURL(url: url)
  }
  
  private func loadURL(url: URL?) {
    guard let url = url else { return }
    webView.load(URLRequest(url: url))
  }
  
}
