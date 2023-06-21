//
//  NewAlbumViewModel.swift
//  Mementos
//
//  Created by Steven Diviney on 15/06/2023.
//

import Foundation
import SwiftUI
import PhotosUI

class NewAlbumViewModel: ObservableObject {
  var csrfToken: String?
  var title: String = ""
  var alertMessage = ""
  var imageAddedCallback: ((ImageModel) -> ())? = nil
  @Published var images: [ImageModel] = [] // Upload images as they are appended here
  @Published var imageSelections: [PhotosPickerItem] = [] {
    didSet {
      for item in imageSelections {
        loadTransferable(from: item)
      }
    }
  }
  
  private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
    return imageSelection.loadTransferable(type: TransferableImageWithMetadata.self) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let trans_image?):
          let imageModel = ImageModel(id : imageSelection.itemIdentifier,
                                         uiImage: trans_image.image,
                                         metadata: trans_image.metadata)
          if !self.images.contains(imageModel) {
            // TODO: Also need to remove images no longer picked
            self.images.append(imageModel)
            if let imageAddedCallback = self.imageAddedCallback { imageAddedCallback(imageModel) }
          }
        case .success(nil):
          // TODO: Add states for images
          print("Failed to get image")
        case .failure(let error):
          print("Failed to get image " + error.localizedDescription)
        }
      }
    }
  }
}
