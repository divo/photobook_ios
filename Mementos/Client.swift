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

enum ClientError: Error {
  case CSRFNotFound
}

struct DirectUploadResponse: Decodable {
  let id: String
  let direct_upload: DirectUploadData
  let signed_id: String
  
  struct DirectUploadData: Decodable {
    let url: URL
    let headers: [String: String]
  }
}

struct CreateAlbumResponse: Decodable {
  let id: String
  let name: String
  let url: URL
}

//TODO: Allow arbitrary loads is set for testing, delete it before release
class Client {
#if DEBUG
  let host = "http://192.168.0.88:3000"
#else
  let host = "https://mementos.ink"
#endif
  
  // Followed https://cameronbothner.com/activestorage-beyond-rails-views/
  func direct_upload(csrf: String, imageModel: ImageModel, completion: @escaping (Result<String, Error>) -> ()) {
    let direct_upload_url = self.host + "/rails/active_storage/direct_uploads"
    var headers = self.header_cookies(csrf)
    
    do {
      let imageData = try imageModel.jpegData()
      let params = imageModel.to_json(data: imageData)
      AF.request(direct_upload_url, method: .post, parameters: params, headers: headers)
        .uploadProgress { progress in
          imageModel.uploadProgress = progress.fractionCompleted
        }.responseDecodable(of: DirectUploadResponse.self) { response in
        switch response.result {
        case .success(let body):
          let signed_id = body.signed_id
          AF.upload(imageData, to: body.direct_upload.url, method: .put, headers: HTTPHeaders(body.direct_upload.headers)).response { response in
            completion(.success(signed_id))
          }
        case .failure(let error):
          completion(.failure(error))
          print(error.localizedDescription)
        }
      }
    } catch let error {
      print("Could not prepare upload")
      completion(.failure(error))
    }
  }
  
  // This will fail the first time in development because the
  // needs to grant permission to make requests on local network
  // Works find in production
  func request_csrf(completion: @escaping (String?) -> ()) {
    let url = host + "/photo_albums/new"
    let headers = header_cookies()
    AF.request(url, method: .get, headers: headers).responseString { response in
      switch response.result {
      case .success(let body):
        guard let csrfToken = self.extractCSRFToken(from: body) else {
          print(ClientError.CSRFNotFound.localizedDescription)
          completion(nil)
          return
        }
        
        completion(csrfToken)
      case .failure(let error):
        print(error.localizedDescription)
        completion(nil)
      }
    }
  }
  
  func create_album(csrf:String, title: String, images: [ImageModel], completion: @escaping (Result<CreateAlbumResponse, AFError>) -> ()) {
    let url = self.host + "/photo_albums.json"
    let headers = self.header_cookies(csrf)
    let image_tokens = images.compactMap { image in
      switch image.status {
      case .uploaded(let signed_id):
        return signed_id
      default:
        return nil
      }
    }
    
    let params = ["photo_album": ["name": title, "images": image_tokens]]
    AF.request(url, method: .post, parameters: params, headers: headers).responseDecodable(of: CreateAlbumResponse.self) { response in
      completion(response.result)
    }
  }
 
  private func header_cookies(_ csrf: String? = nil) -> HTTPHeaders {
    let cookies = AF.session.configuration.httpCookieStorage!.cookies!
    let header_cookie = HTTPCookie.requestHeaderFields(with: cookies)
    var headers = HTTPHeaders(header_cookie)
    if let csrf = csrf {
      headers.add(name: "X-CSRF-Token", value: csrf)
    }
    
    return headers
  }
  
  // Code grabbed from ChatGPT, a bit out of date but this is all hacky anyway
  private func extractCSRFToken(from string: String) -> String? {
    let pattern = "<meta name=\"csrf-token\" content=\"([^\"]+)\" />"
    
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: [])
      let nsString = string as NSString
      let match = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: nsString.length))
      
      if let matchRange = match?.range(at: 1) {
        let csrfToken = nsString.substring(with: matchRange)
        return csrfToken
      }
    } catch {
      print("Error creating regex: \(error)")
    }
    
    return nil
  }
}
