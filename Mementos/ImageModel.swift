//
//  ImageModel.swift
//  Mementos
//
//  Created by Steven Diviney on 15/06/2023.
//

import Foundation
import SwiftUI
import CoreLocation
import ImageMetadataUtil
import UniformTypeIdentifiers
import CryptoKit

enum ImageStatus {
  case waiting
  case uploading
  case uploaded(String)
  case failed
}

class ImageModel: Hashable, Equatable, ObservableObject {
  let id: String
  let uiImage: UIImage
  let metadata: [String : Any]?
  let image: Image
  var status: ImageStatus = .waiting
  
  init(id: String?, uiImage: UIImage, metadata: [String : Any]?) {
    self.id = id ?? UUID().uuidString
    self.image = Image(uiImage: uiImage) // Doesn't seem to use extra memory, runtime is doing something intelligent
    self.uiImage = uiImage
    self.metadata = metadata
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

   static func ==(lhs: ImageModel, rhs: ImageModel) -> Bool {
    return lhs.id == rhs.id
  }
}

extension ImageModel {
  enum ImageSerializationError: Error {
    case EncodingFailed
  }
  
  func jpegData() throws -> Data {
    guard let data = uiImage.jpegData(compressionQuality: 0.9) else {
      //TODO: I should upload it as is and let Rails have a go
      print("Unable able to encode JPEG data")
      throw ImageSerializationError.EncodingFailed
    }
    
    guard let metadata = self.metadata else {
      return data
    }
    
    return ImageMetadataUtil.writeMetadataToImageData(sourceData: data, metadata: metadata, type: UTType.jpeg.identifier as CFString)
  }
}

extension ImageModel {
  // Converting everything to JPEG on device. I think this is ok do, cuts down on upload size
  // If this is changed, update the file ext bit below
  func to_json(data: Data) -> [String : [String: String]] {
      let checksum = Insecure.MD5.hash(data: data)
    
    return ["blob": [
      "filename" : self.id + ".jpg",
      "content_type" : UTType.jpeg.preferredMIMEType!,
      "byte_size" : String(data.count),
      "checksum": Data(checksum).base64EncodedString()
    ]]
  }
}

extension ImageModel {
  func gpsDictionary() -> CLLocationCoordinate2D? {
    guard let imageProperties = metadata else { return nil }
    
    return ImageMetadataUtil.gps(from: imageProperties)
  }
}
