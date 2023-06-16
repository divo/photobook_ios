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
 
  // TODO: Passing the webView so I can grab the cookie, which will come some time after setup
  // so I need the webView to grab the cookie in the future.
  // I have to pass the WebView all the way to the Client because I need to futz around with reference
  // If there is no cookie I need to present the login form and then load the rest of the view.
  // or something
//  init(webView: WebView) {
//    self.webView = webView
//  }
  
  public func test() {
    let url = "http://192.168.0.88:3000/photo_albums"
    let cookies = AF.session.configuration.httpCookieStorage!.cookies!
    let header_cookie = HTTPCookie.requestHeaderFields(with: cookies)
    var headers = HTTPHeaders(header_cookie)
    
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
