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
  @State var pushShow = false
  let client = Client()
  @Binding var rootIsActive: Bool
  
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
          Spacer()
          image.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 250)
            .clipped()
          Spacer()
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
          }.padding(20.0) //TODO: Style this thing
            .frame(width: 300.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
            .background(Style.secondaryColor())
            .cornerRadius(/*@START_MENU_TOKEN@*/6.0/*@END_MENU_TOKEN@*/)
        } else {
          PhotosPicker(selection: $viewModel.imageSelections, maxSelectionCount: 150, matching: .images, photoLibrary: .shared()) {
            Image("attach")
              .cornerRadius(10)
              .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(Color.orange, lineWidth: 0))
              .shadow(color: .gray, radius: 1, x: 0, y: 1)
              .shadow(color: .gray, radius: 3, x: 0, y: 3)
          }
        }
      }
      
      Button("Create Album") {
        self.client.create_album(csrf: self.viewModel.csrfToken!, title: self.viewModel.title, images: self.viewModel.images) { result in
          switch result {
          case .success(let album):
            print("Album created: " + album.id)
            self.pushShow = true
          case .failure(let error):
            print(error)
          }
        }
      }.padding(20)
      
      NavigationLink(destination: ShowAlbumView(shouldPopToRootView: self.$rootIsActive), isActive: self.$pushShow) { EmptyView() }
        .isDetailLink(false)
        .navigationTitle("Title")
//      Button("Test") {
//        self.pushShow = true
//      }
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
