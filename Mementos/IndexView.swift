//
//  ContentView.swift
//  Mementos
//
//  Created by Steven Diviney on 14/06/2023.
//

import SwiftUI
import Network

class IndexViewModel: ObservableObject {
  @Published var url = URL(string: Constants.baseURL + "/photo_albums")!
  @Published var showUrl = URL(string: Constants.baseURL)!
  @Published var profileUrl = URL(string: Constants.baseURL + "/users/edit/")!
  // TODO: Consilidate bools into one string
  @Published var pushNew: Bool = false
  @Published var pushShow: Bool = false
  @Published var pushProfile: Bool = false
  @Published var childTitle: String = "Mementos"
  @Published var profileTitle: String = "Profile"
  
  let monitor = NWPathMonitor()
  let queue = DispatchQueue(label: "Monitor")
  @Published private(set) var connected: Bool = true
  
  init() {
    checkConnection()
  }
  
  func checkConnection() {
    monitor.pathUpdateHandler = { path in
      if path.status == .satisfied {
        DispatchQueue.main.async {
          self.connected = true
        }
      } else {
        DispatchQueue.main.async {
          self.connected = false
        }
      }
    }
    monitor.start(queue: queue)
  }
}

struct IndexView: View {
  @ObservedObject var viewModel = IndexViewModel()

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
          let webView = WebView(url: viewModel.url, navigationActions: ["show_album", "new_album"]) { action, destination, queryItems in
            if action == "show_album" {
              if let queryItems = queryItems,
                 let titleParam = queryItems.first(where: { item in item.name == "name" }), // Why in gods name did I call the title "name"
                 let title = titleParam.value {
                self.viewModel.childTitle = title
              }
              viewModel.showUrl = URL(string: Constants.baseURL + "/photo_albums/\(destination)")!
              viewModel.pushShow = true
            } else if action == "new_album" {
              viewModel.pushNew = true
            }
          }
          
          webView.onAppear {
            webView.reload()
          }.edgesIgnoringSafeArea(.all)
        }
       
        NavigationLink(destination: NewAlbumView(rootIsActive: self.$viewModel.pushNew), isActive: self.$viewModel.pushNew) { EmptyView() }.isDetailLink(false)
        NavigationLink(destination: WebViewContainer(url: viewModel.showUrl, title: $viewModel.childTitle), isActive: $viewModel.pushShow) { EmptyView() }
        NavigationLink(destination: WebViewContainer(url: viewModel.profileUrl, title: $viewModel.profileTitle), isActive: $viewModel.pushProfile) { EmptyView() }
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
  
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    IndexView()
  }
}
