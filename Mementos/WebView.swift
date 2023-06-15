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
  
  init(url: URL) {
    self.url = url
    self.configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = webDataStore
    self.webView = WKWebView(frame: .zero, configuration: configuration)
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
