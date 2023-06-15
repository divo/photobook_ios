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
  var title: String = ""
  @Published var images: [ImageModel] = []
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
          let hashableImage = ImageModel(id : imageSelection.itemIdentifier,
                                         uiImage: trans_image.image,
                                         metadata: trans_image.metadata)
          if !self.images.contains(hashableImage) {
            self.images.append(hashableImage)
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