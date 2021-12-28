//
//  HeaderRequest.swift
//  TrailGuru
//
//  Created by kishlay kishore on 02/03/21.
//

import Foundation
import Alamofire

final class ApiHeaders {
  class func defaultHeaders() -> HTTPHeaders {
    guard MemberModel.getMemberModel() != nil else {
      return [:]
    }
    let token = UserDefaults.standard.object(forKey: "headerToken")
    return HTTPHeaders(["Authorization": "Bearer \(token ?? "")"])
  }
}
