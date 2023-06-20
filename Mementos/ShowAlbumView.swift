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
  let baseUrl = "http://192.168.0.87:3000"
#else
  let baseUrl = "https://mementos.com"
#endif
  
//  let albumId: String
  let webView = WebView(url: URL(string: "http://192.168.0.87:3000" + "/photo_albums/" + "1")!)
  @Binding var shouldPopToRootView : Bool
  
//  init(albumId: String) {
//    self.albumId = albumId
//    self.webView = WebView(url: URL(string: baseUrl + "/photo_albums/" + albumId)!)
//  }
  
  var body: some View {
    webView
      .navigationBarBackButtonHidden(true)
      .navigationBarItems(leading: btnBack)
  }
  
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  
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
