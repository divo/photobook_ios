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
  
  init(shouldPopToRootView: Binding<Bool>, url: Binding<URL>) {
    self._shouldPopToRootView = shouldPopToRootView
    self.webView = WebView(url: url)
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
