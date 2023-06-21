//
//  ContentView.swift
//  Mementos
//
//  Created by Steven Diviney on 14/06/2023.
//

import SwiftUI

struct ContentView: View {
#if DEBUG
  var webView = WebView(url: URL(string: "http://192.168.0.88:3000/photo_albums")!)
#else
  var webView = WebView(url: URL(string: "https://mementos.ink/photo_albums")!)
#endif
  
  @State var isActive: Bool = false
  
  var body: some View {
    NavigationView {
      VStack {
        webView
        NavigationLink(destination: NewAlbumView(rootIsActive: self.$isActive), isActive: self.$isActive) {
          Text("New Album")
            .padding(20.0)
            .frame(width: 300.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(Style.primaryColor())
            .cornerRadius(/*@START_MENU_TOKEN@*/6.0/*@END_MENU_TOKEN@*/)
        }.isDetailLink(false)
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
