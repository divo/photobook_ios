//
//  WebViewContainer.swift
//  Mementos
//
//  Created by Steven Diviney on 01/09/2023.
//

import Foundation
import WebKit
import SwiftUI
import Alamofire

struct WebViewContainer: View {
  @StateObject var viewModel: WebViewModel = WebViewModel()
  @Binding var title: String
  @Binding var url: URL {
    didSet {
      viewModel.url = url
    }
  }
  var navigationActions: [String]? = nil
  var navigationCallback: ((String, String, [URLQueryItem]?) -> ())? = nil
  
  @State var profileTitle: String = "Profile"
  @State var profileUrl = URL(string: Constants.baseURL + "/users/edit/")!
  @State var pushProfile: Bool = false
  
  init(url: Binding<URL>, title: Binding<String>) {
    self._url = url
    self._title = title
  }
  
  var body: some View {
    NavigationLink(destination: WebViewContainer(url: $profileUrl, title: $profileTitle), isActive: $pushProfile) { EmptyView() }
    WebView(webView: viewModel.webView)
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
      .onAppear {
        viewModel.url = self.url
      }
  }
}
