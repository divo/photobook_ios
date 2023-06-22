//
//  ContentView.swift
//  Mementos
//
//  Created by Steven Diviney on 14/06/2023.
//

import SwiftUI

struct ContentView: View {
  @State var url = URL(string: Constants.baseURL + "/photo_albums")!
  @State var isActive: Bool = false
  
  var body: some View {
    NavigationView {
      VStack {
        WebView(url: $url)
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
