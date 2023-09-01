//
//  ContentView.swift
//  Mementos
//
//  Created by Steven Diviney on 14/06/2023.
//

import SwiftUI
import Network

struct IndexView: View {
  @StateObject var viewModel: IndexViewModel = IndexViewModel()
//  @StateObject var webViewModel: WebViewModel = WebViewModel()
  @StateObject var webViewModel: WebViewModel = WebViewModel()
//  let showAlbumView: WebViewContainer = WebViewContainer(url: Constants.renameMe)
  

  var body: some View {
    NavigationView {
      VStack {
        if !viewModel.connected {
         Image(systemName: "wifi.exclamationmark")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
            .clipped()
          Text("A internet connection is required")
            .bold()
        } else {
          WebView(webView: webViewModel.webView)
            .onAppear {
              webViewModel.url = viewModel.url
              setActionHander()
            }.edgesIgnoringSafeArea(.bottom)
        }
       
//        NavigationLink(destination: NewAlbumView(rootIsActive: self.$viewModel.pushNew), isActive: self.$viewModel.pushNew) { EmptyView() }.isDetailLink(false)
//        NavigationLink(destination: self.showAlbumView, isActive: $viewModel.pushShow) { EmptyView() }
//        NavigationLink(destination: WebViewContainer(url: viewModel.profileUrl, title: $viewModel.profileTitle), isActive: $viewModel.pushProfile) { EmptyView() }
      }.navigationTitle("Mementos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              self.viewModel.pushProfile = true
            } label: {
              Image(systemName: "person.crop.circle")
            }
          }
        }
    }
  }
  
  func setActionHander() {
    webViewModel.setActionHandler(navigationActions: ["show_album", "new_album"]) { action, destination, queryItems in
      if action == "show_album" {
        if let queryItems = queryItems,
           let titleParam = queryItems.first(where: { item in item.name == "name" }), // Why in gods name did I call the title "name"
           let title = titleParam.value {
          self.viewModel.childTitle = title // TODO: Need to wire this through somehow
        }
//        self.showAlbumView.loadURL(URL(string: Constants.baseURL + "/photo_albums/\(destination)")!)
        self.viewModel.pushShow = true
      } else if action == "new_album" {
        self.viewModel.pushNew = true
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    IndexView()
  }
}
