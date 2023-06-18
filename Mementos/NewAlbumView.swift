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
  @ObservedObject var viewModel = NewAlbumViewModel()
  @State var readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  let client = Client()
  
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
      
      List(viewModel.images, id: \.self) { image in
        HStack {
          image.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 250)
            .clipped()
        }
      }
      
      // TODO: Test this logic makes sense and we can request again!
      HStack {
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
        Button("Test") {
//          client.create_album(title: "Test")
          if let data = viewModel.images.first?.jpegData() {
            client.direct_upload(imageModel: viewModel.images.first!) { result in
              print(result)
            }
            //            client.upload_image(data: data)
          }
        }
      }
    }.navigationTitle("Create Album")
    }.navigationTitle("Create Album").onAppear(perform: onAppear)
  }
  
  func onAppear() {
    client.request_csrf { csrfToken in
      self.viewModel.csrfToken = csrfToken
    }
  }
}
