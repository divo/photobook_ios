//
//  Client.swift
//  Mementos
//
//  Created by Steven Diviney on 15/06/2023.
//

import Foundation
import Alamofire
import PhotosUI

struct DecodableType: Decodable { let url: String }

//TODO: Allow arbitrary loads is set for testing, delete it before release
class Client {
  public func test() {
    let url = "http://192.168.0.88:3000/photo_albums"
    let headers: HTTPHeaders = [
      "Content-Type": "application/json"
    ]
    
    AF.request(url, headers: headers).responseString { response in
      print(response.value)
    }
    
  }
  
  public func upload(_ data: [String: Data]) {
    uploadImagesToServer(data)
  }
  
  private func uploadImagesToServer(_ imageData: [String : Data]) {
    let url = "http://192.168.0.88:8000/upload"
    
    AF.upload(multipartFormData: { multipartFormData in
      for (index, data) in imageData.enumerated() {
        multipartFormData.append(data.value, withName: "file\(index)", fileName: data.key, mimeType: "image/jpeg")
      }
    }, to: url)
    .uploadProgress { progress in
      print("Upload Progress: \(progress.fractionCompleted)")
    }
    .responseDecodable(of: DecodableType.self) { response in
      debugPrint(response)
    }
  }
}
