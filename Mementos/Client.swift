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
  
  func create_album(title: String) {
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
        if let headerFields = response.response?.allHeaderFields as? [String: String],
           let URL = response.request?.url
        {
          let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
          let csrfToken = self.extractCSRFToken(from: body)!
          var fresh_headers = HTTPHeaders(HTTPCookie.requestHeaderFields(with: cookies))
//          var fresh_headers = HTTPHeaders(headerFields)
          fresh_headers.add(name: "authenticity_token", value: csrfToken)
          AF.request(url, method: .post, parameters: params, headers: fresh_headers).responseString { response in
            print(response)
          }
        }
        
     case .failure(let error):
        // TODO: Something
        print(error.localizedDescription)
      }
    }
 }
  
  // Code grabbed from ChatGPT, a bit out of date but this is all hacky anyway
  func extractCSRFToken(from string: String) -> String? {
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
