//
//  ContentView.swift
//  Mementos
//
//  Created by Steven Diviney on 14/06/2023.
//

import SwiftUI

struct ContentView: View {
  @State var url = URL(string: Constants.baseURL + "/photo_albums")!
  @State var showUrl = URL(string: Constants.baseURL)!
  @State var profileUrl = URL(string: Constants.baseURL + "/users/edit/")!
  @State var pushNew: Bool = false
  @State var pushShow: Bool = false
  @State var pushProfile: Bool = false
  @State var childTitle: String = "Mementos"
  @State var profileTitle: String = "Profile"
  
  var body: some View {
    NavigationView {
      VStack {
        let webView = WebView(url: $url, navigationActions: ["show_album", "new_album"]) { action, destination, queryItems in
          if action == "show_album" {
            if let queryItems = queryItems,
               let titleParam = queryItems.first(where: { item in item.name == "name" }), // Why in gods name did I call the title "name"
               let title = titleParam.value {
              self.childTitle = title
            }
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
        NavigationLink(destination: WebViewContainer(url: $showUrl, title: $childTitle), isActive: $pushShow) { EmptyView() }
        NavigationLink(destination: WebViewContainer(url: $profileUrl, title: $profileTitle), isActive: $pushProfile) { EmptyView() }
      }.navigationTitle("Mementos")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              self.pushProfile = true
            } label: {
              Image(systemName: "person.crop.circle")
            }
          }
      }
    }
  }
  
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
