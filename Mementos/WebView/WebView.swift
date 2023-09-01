//
//  WebView.swift
//  Mementos
//
//  Created by Steven Diviney on 01/09/2023.
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
