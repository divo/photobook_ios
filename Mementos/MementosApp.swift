//
//  MementosApp.swift
//  Mementos
//
//  Created by Steven Diviney on 14/06/2023.
//

import SwiftUI

struct Constants {
#if DEBUG
  static let baseURL = "http://192.168.0.88:3000"
#else
  static let baseURL = "https://mementos.ink"
#endif
}

@main
struct MementosApp: App {
    var body: some Scene {
        WindowGroup {
          IndexView()
        }
    }
}
