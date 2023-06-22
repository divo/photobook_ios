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
  let client = Client()
#if DEBUG
  let minPhotos = 1
#else
  let minPhotos = 30
#endif
  
  @ObservedObject var viewModel = NewAlbumViewModel()
  @Binding var rootIsActive: Bool
  
  // TODO: Add into view model
  @State var readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  @State var pushShow = false
  @State var presentPicker = false
  @State var showingAlert = false
  
  var body: some View {
    VStack {
      titleField()
      if viewModel.images.isEmpty {
        VStack {
          Image(systemName: "paperclip")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .padding(5)
          
          Text("Attach some photos to get started")
          Text(" Your album must have at least " + String(minPhotos))
        }.padding(20.0) //TODO: Style this thing
          .foregroundColor(.white)
          .background(Style.secondaryColor()) // Left here, need more colors
          .border(Style.secondaryColor(), width: 2)
          .cornerRadius(/*@START_MENU_TOKEN@*/6.0/*@END_MENU_TOKEN@*/)
          .shadow(color: .gray, radius: 2, x: 0, y: 2)
        
      }
      photoList()
      HStack {
        attachButton()
        createAlbumButton().padding(.horizontal)
      }
      showNavigationLink()
      
    }.navigationTitle("Create Album").onAppear(perform: onAppear)
      .photosPicker(isPresented: self.$presentPicker, selection: $viewModel.imageSelections, maxSelectionCount: 150, matching: .images, photoLibrary: .shared())
  }
  
  func requestAccess() {
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
      // https://developer.apple.com/documentation/photokit/delivering_an_enhanced_privacy_experience_in_your_photos_app
      // TODO: Display status and remind user if it's limited
      readWriteStatus = status
      if readWriteStatus == .authorized || readWriteStatus == .limited {
        self.presentPicker = true
      } else {
        // TODO: Handle again, maybe recurse, fuck em
      }
    }
  }
  
  // MARK - UI compontents
  func attachButton() -> some View {
    Button {
      if readWriteStatus != .authorized && readWriteStatus != .limited {
        // TODO: Test this logic makes sense and we can request again!
        requestAccess()
      } else {
        self.presentPicker = true
      }
    } label: {
      Image("attach")
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6)
          .stroke(Color.orange, lineWidth: 0))
    }
  }
  
  func titleField() -> some View {
    TextField("Album Title", text: $viewModel.title)
      .padding([.leading, .trailing], 10)
      .padding([.top, .bottom], 5)
      .overlay(
        Rectangle()
          .frame(height: 2)
          .foregroundColor(.black),
        alignment: .bottom
      ).padding(20)
  }
  
  func photoList() -> some View {
    List(viewModel.images, id: \.self) { image in
      HStack {
        Spacer()
        VStack {
          image.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 250)
            .clipped()
          ProgressView(value: image.uploadProgress)
        }
        Spacer()
      }
    }
  }

  func createAlbumButton() -> some View {
    Button("Create Album") {
      switch isValid() {
      case .failure(let error):
        self.viewModel.alertMessage = error.localizedDescription
        self.showingAlert = true
      case.success(_):
        self.client.create_album(csrf: self.viewModel.csrfToken!, title: self.viewModel.title, images: self.viewModel.images) { result in
          switch result {
          case .success(let album):
            print("Album created: " + album.id)
            self.viewModel.albumURL = URL(string: Constants.baseURL + "/photo_albums/\(album.id)")!
            self.pushShow = true
          case .failure(let error):
            print(error)
          }
        }
      }
    }.padding(20)
      .frame(width: 200.0)
      .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
      .background(Style.secondaryColor())
      .cornerRadius(/*@START_MENU_TOKEN@*/6.0/*@END_MENU_TOKEN@*/)
      .alert(viewModel.alertMessage, isPresented: $showingAlert) {
        Button("OK", role: .cancel) { }
      }
  }
  
  func showNavigationLink() -> some View {
    NavigationLink(destination: ShowAlbumView(shouldPopToRootView: self.$rootIsActive, url: $viewModel.albumURL), isActive: self.$pushShow) { EmptyView() }
      .isDetailLink(false)
      .navigationTitle("New Album")
  }
  
  // MARK - Behaviour
  func onAppear() {
    self.viewModel.imageAddedCallback = { imageModel in
      self.upload(image: imageModel)
    }
    
    client.request_csrf { csrfToken in
      self.viewModel.csrfToken = csrfToken
    }
  }
   
  func isValid() -> Result<String, ValidationError> {
    if viewModel.title.isEmpty {
      return Result.failure(.title)
    } else if(viewModel.images.count < minPhotos) {
      return Result.failure(.images)
    } else if(!viewModel.imagesUploaded()) {
      return Result.failure(.waiting)
    } else {
      return Result.success("")
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

enum ValidationError: Error {
  case title
  case images
  case waiting
}

extension ValidationError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .title:
      return NSLocalizedString("Your album must have a title", comment: "My error")
    case .images:
      return NSLocalizedString("You need at least 30 photos", comment: "error")
    case .waiting:
      return NSLocalizedString("Please wait for image uploads to finish", comment: "error")
    }
  }
}
