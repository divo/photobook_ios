//
//  LocationSearchView.swift
//  Mementos
//
//  Created by Steven Diviney on 26/06/2023.
//

import SwiftUI

struct LocationSearchView: View {
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    Button("Done") {
      dismiss()
    }
  }
}
