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
        Button("Create Album") {
          self.client.create_album(csrf: self.viewModel.csrfToken!, title: self.viewModel.title, images: self.viewModel.images)
        }
      }
    }.navigationTitle("Create Album").onAppear(perform: onAppear)
  }
  
  func onAppear() {
    self.viewModel.imageAddedCallback = { imageModel in
      self.upload(image: imageModel)
    }
    
    client.request_csrf { csrfToken in
      self.viewModel.csrfToken = csrfToken
    }
  }

  func upload(image: ImageModel) {
    switch image.status {
    case .waiting:
      image.status = .uploading
      client.direct_upload(csrf: viewModel.csrfToken!, imageModel: image) { response in
        switch response {
        case .success(let signed_id):
          image.status = .uploaded(signed_id)
        case .failure(_):
          image.status = .failed
        }
      }
    default:
      break
    }
  }
}
