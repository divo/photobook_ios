//
//  ShowAlbumView.swift
//  Mementos
//
//  Created by Steven Diviney on 20/06/2023.
//

import SwiftUI
import WebKit

// Whats the difference between this and WebViewContainer
// The ability to pop all the way to the back of the nav stack
// Adding optional behaviour like that is not easy in SwiftUI
// so the alternative is to have every parent pass their child the
// state they use to present the child and allow the child to un-present
// itself by always overriding the navbar. Instead I'm making things
// less dry by copying the WebViewContainer here and adding behaviour
// TODO: Fix this
struct ShowAlbumView: View {
  @StateObject var viewModel: WebViewModel = WebViewModel()
  @Binding var title: String
  @Binding var url: URL
  @Binding var shouldPopToRootView : Bool
  
  @State var profileTitle: String = "Profile"
  @State var profileUrl = URL(string: Constants.baseURL + "/users/edit/")!
  @State var pushProfile: Bool = false
  
  init(shouldPopToRootView: Binding<Bool>, url: Binding<URL>, title: Binding<String>) {
    self._shouldPopToRootView = shouldPopToRootView
    self._url = url
    self._title = title
  }
  
  var body: some View {
    NavigationLink(destination: WebViewContainer(url: $profileUrl, title: $profileTitle), isActive: $pushProfile) { EmptyView() }
    WebView(webView: viewModel.webView)
      .navigationBarBackButtonHidden(true)
      .navigationBarItems(leading: btnBack)
      .toolbar {
        ToolbarItem(placement: .principal) { // <3>
          Text(title).font(.headline)
        }
      }.toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            self.pushProfile = true
          } label: {
            Image(systemName: "person.crop.circle")
          }
        }
      }.edgesIgnoringSafeArea(.bottom)
      .onAppear {
        viewModel.url = self.url
      }.onChange(of: url) { newValue in
        // Using onChange here instead of didSet like in WebView container
        // Tbh I'm not sure on why, but I need it so I can update the URL after
        // the fact.
        viewModel.url = self.url
      }
  }
  
  var btnBack : some View {
    Button(action: {
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
