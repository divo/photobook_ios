//
//  NewAlbumView.swift
//  Mementos
//
//  Created by Steven Diviney on 15/06/2023.
//

import Foundation
import SwiftUI
import PhotosUI

struct NewAlbumView: View {
  @ObservedObject var viewModel = NewAlbumModel()
  @State var readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  
  var body: some View {
    VStack {
      TextField("Album Title", text: $viewModel.title)
        .padding([.leading, .trailing], 10)
        .padding([.top, .bottom], 5)
        .overlay(
          Rectangle()
              .frame(height: 2)
              .foregroundColor(.black),
          alignment: .bottom
        ).padding(20)
      if readWriteStatus != .authorized && readWriteStatus != .limited {
        Button("Allow photo access") {
          PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            // https://developer.apple.com/documentation/photokit/delivering_an_enhanced_privacy_experience_in_your_photos_app
            // TODO: Display status and remind user if it's limited
            readWriteStatus = status
          }
        }
      } else {
        PhotosPicker(selection: $viewModel.imageSelections, maxSelectionCount: 150, matching: .images, photoLibrary: .shared()) {
          Text("Select Photos").padding(20)
        }
      }
    }.navigationTitle("Create Album")
  }
}

class NewAlbumModel: ObservableObject {
  @Published var images: [Image] = []
  @Published var imageSelections: [PhotosPickerItem] = [] {
    didSet {
    }
  }
  var title: String = ""
}
