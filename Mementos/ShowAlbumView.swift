//
//  ShowAlbumView.swift
//  Mementos
//
//  Created by Steven Diviney on 20/06/2023.
//

import SwiftUI
import WebKit

struct ShowAlbumView: View {
  let webView : WebView
  @Binding var shouldPopToRootView : Bool
  
  @State var profileTitle: String = "Profile"
  @State var profileUrl = URL(string: Constants.baseURL + "/users/edit/")!
  @State var pushProfile: Bool = false
  
  init(shouldPopToRootView: Binding<Bool>, url: Binding<URL>) {
    self._shouldPopToRootView = shouldPopToRootView
    self.webView = WebView(url: url)
  }
  
  var body: some View {
    NavigationLink(destination: WebViewContainer(url: $profileUrl, title: $profileTitle), isActive: $pushProfile) { EmptyView() }
    webView
      .navigationBarBackButtonHidden(true)
      .navigationBarItems(leading: btnBack)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            self.pushProfile = true
          } label: {
            Image(systemName: "person.crop.circle")
          }
        }
      }.edgesIgnoringSafeArea(.bottom)
  }
  
  var btnBack : some View { Button(action: {
    self.shouldPopToRootView = false
  }) {
    HStack {
      Image("back_arrow") // set image here
        .aspectRatio(contentMode: .fit)
        .foregroundColor(.white)
      Text("Back")
    }
  }
  }
}
