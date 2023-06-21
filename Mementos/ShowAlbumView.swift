//
//  ShowAlbumView.swift
//  Mementos
//
//  Created by Steven Diviney on 20/06/2023.
//

import SwiftUI
import WebKit

struct ShowAlbumView: View {
#if DEBUG
  let baseUrl = "http://192.168.0.88:3000"
#else
  let baseUrl = "https://mementos.ink"
#endif
  
  let webView : WebView
  @Binding var shouldPopToRootView : Bool
  
  init(shouldPopToRootView: Binding<Bool>) {
    self._shouldPopToRootView = shouldPopToRootView
    self.webView = WebView(url: URL(string: baseUrl)!)
  }
  
  var body: some View {
    webView
      .navigationBarBackButtonHidden(true)
      .navigationBarItems(leading: btnBack)
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
