//
//  TransferableImageWithMetadata.swift
//  Mementos
//
//  Created by Steven Diviney on 15/06/2023.
//

import Foundation
import SwiftUI
import ImageMetadataUtil

struct TransferableImageWithMetadata: Transferable {
  let image: UIImage
  let metadata: [String : Any]?
  
  enum TransferError: Error {
    case importFailed
  }
  
  // Load the image, extract the metadata, compress it and save metadata again
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(importedContentType: .image) { data in
      guard let uiImage = UIImage(data: data) else {
        throw TransferError.importFailed
      }
      let metadata = ImageMetadataUtil.extractMetadata(from: data)
      
      return TransferableImageWithMetadata(image: uiImage, metadata: metadata)
    }
  }
}

