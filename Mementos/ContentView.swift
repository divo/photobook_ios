//
//  ContentView.swift
//  Mementos
//
//  Created by Steven Diviney on 14/06/2023.
//

import SwiftUI

struct ContentView: View {
  @State var url = URL(string: Constants.baseURL + "/photo_albums")!
  @State var pushNew: Bool = false
  @State var showUrl = URL(string: Constants.baseURL)!
  @State var pushShow: Bool = false
  
  var body: some View {
    NavigationView {
      VStack {
        let webView = WebView(url: $url, navigationActions: ["show_album", "new_album"]) { action, destination in
          if action == "show_album" {
            showUrl = URL(string: Constants.baseURL + "/photo_albums/\(destination)")!
            pushShow = true
          } else if action == "new_album" {
            pushNew = true
          }
        }
        
        webView.onAppear {
          webView.reload()
        }
        
        NavigationLink(destination: NewAlbumView(rootIsActive: self.$pushNew), isActive: self.$pushNew) { EmptyView() }.isDetailLink(false)
        NavigationLink(destination: WebView(url: $showUrl), isActive: $pushShow) { EmptyView() }
          .navigationTitle("Mementos")
      }
    }
  }
  
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
