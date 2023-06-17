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

//TODO: Allow arbitrary loads is set for testing, delete it before release
class Client {
  let host = "http://192.168.0.88:3000"
//  let host = "https://mementos.com"
  
  // TODO: Passing the webView so I can grab the cookie, which will come some time after setup
  // so I need the webView to grab the cookie in the future.
  // I have to pass the WebView all the way to the Client because I need to futz around with reference
  // If there is no cookie I need to present the login form and then load the rest of the view.
  // or something
  //  init(webView: WebView) {
  //    self.webView = webView
  //  }
  
  public func test() {
    let url = "http://192.168.0.88:3000/photo_albums.json"
    // The cookie should always be there as Rails will prompt the user to login if needed
    // and we try to grab it after every request.
    // If cookie is not there we shouldn't have got this far and crash
    let cookies = AF.session.configuration.httpCookieStorage!.cookies!
    let header_cookie = HTTPCookie.requestHeaderFields(with: cookies)
    let headers = HTTPHeaders(header_cookie)
    
    AF.request(url, headers: headers).responseString { response in
      print(response.value)
    }
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
  
  func direct_upload(imageModel: ImageModel, completion: @escaping (String? /* What to pass up?? */) -> ()) {
    
    request_csrf { csrf in
      guard let csrf = csrf else { completion(nil); return }
      
      let direct_upload_url = self.host + "/rails/active_storage/direct_uploads"
      var headers = self.header_cookies()
      headers.add(name: "X-CSRF-Token", value: csrf)
      
      do {
        let params = try imageModel.to_json()
        AF.request(direct_upload_url, method: .post, parameters: params, headers: headers).responseDecodable(of: DirectUploadResponse.self) { response in
          switch response.result {
          case .success(let body):
            AF.upload(imageModel.jpegData()! /* ! because we did it in to_json */, to: body.direct_upload.url, method: .put, headers: HTTPHeaders(body.direct_upload.headers)).response { response in
              print(response)
            }
          case .failure(let error):
            print(error.localizedDescription)
          }
        }
        print(params)
      } catch {
        print("Could not prepare upload")
      }
    }
  }
  
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
  
  func upload_image(data: Data) {
    //    AF.upload(data, to: "http://192.168.0.88:3000/rails/active_storage/direct_uploads").responseDecodable(of: DecodableType.self) { response in
    //        debugPrint(response)
    //    }
    let cookies = AF.session.configuration.httpCookieStorage!.cookies!
    let header_cookie = HTTPCookie.requestHeaderFields(with: cookies)
    var headers = HTTPHeaders(header_cookie)
    
    AF.request("http://192.168.0.88:3000/photo_albums/new", method: .get, headers: headers).responseString { response in
      switch response.result {
      case.success(let body):
        let csrfToken = self.extractCSRFToken(from: body)!
        headers.add(name: "X-CSRF-Token", value: csrfToken)
        
        AF.upload( multipartFormData: { multipartFormData in
          multipartFormData.append(data, withName: "blob", fileName: "file0", mimeType: "image/jpeg")
        }, to: "http://192.168.0.88:3000/rails/active_storage/direct_uploads.json", headers: headers).uploadProgress { progress in
          print("Upload progress: \(progress.fractionCompleted)")
        }
        .responseString { response in
          print(response)
        }
        
      case .failure(let error):
        // TODO: Something
        print(error.localizedDescription)
      }
    }
  }
  
  func create_album(title: String, imageData: Data) {
    let url = "http://192.168.0.88:3000/photo_albums.json"
    let params = ["title": title]
    
    // The cookie should always be there as Rails will prompt the user to login if needed
    // and we try to grab it after every request.
    // If cookie is not there we shouldn't have got this far and crash
    let cookies = AF.session.configuration.httpCookieStorage!.cookies!
    let header_cookie = HTTPCookie.requestHeaderFields(with: cookies)
    var headers = HTTPHeaders(header_cookie)
    
    AF.request("http://192.168.0.88:3000/photo_albums/new", method: .get, headers: headers).responseString { response in
      switch response.result {
      case.success(let body):
        let csrfToken = self.extractCSRFToken(from: body)!
        headers.add(name: "X-CSRF-Token", value: csrfToken)
        
        //        AF.upload(multipartFormData: { multipartFormData in
        //          for (index, data) in imageData.enumerated() {
        //            multipartFormData.append(data.value, withName: "file\(index)", filename: data.key, mimeType: "image/jpeg")
        //          }
        //        }, to: "http://192.168.0.88:300/rails/active_storage/direct_uploads").uploadProgress { progress in
        //          print("Upload progress: \(progress.fractionCompleted)")
        //        }
        //        .responseString { response
        //          print(response)
        //        }
        //        AF.request(url, method: .post, parameters: params, headers: headers).responseString { response in
        //          print(response)
        //        }
      case .failure(let error):
        // TODO: Something
        print(error.localizedDescription)
      }
    }
  }
  
  private func header_cookies() -> HTTPHeaders {
    let cookies = AF.session.configuration.httpCookieStorage!.cookies!
    let header_cookie = HTTPCookie.requestHeaderFields(with: cookies)
    return HTTPHeaders(header_cookie)
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
