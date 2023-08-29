//
//  IndexViewModel.swift
//  Mementos
//
//  Created by Steven Diviney on 28/08/2023.
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
