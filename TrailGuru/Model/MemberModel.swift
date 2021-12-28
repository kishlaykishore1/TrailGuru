//
//  MemberModel.swift
//  TrailGuru
//
//  Created by kishlay kishore on 02/03/21.
//

import Foundation

// MARK: - MemberModel
class MemberModel: Codable {
  let id, isMobileVerified: Int
  let username, email, mobile, dob: String
  let image: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case isMobileVerified = "is_mobile_verified"
    case username, email, mobile, dob, image
  }
  
  static func storeMemberModel(value: [String: Any]) {
    Constants.kUserDefaults.set(value, forKey: "Member")
  }
  
  static func getMemberModel() -> MemberModel? {
    if let getDate = Constants.kUserDefaults.value(forKey: "Member") as? [String: Any] {
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: getDate, options: .prettyPrinted)
        do {
          let decoder = JSONDecoder()
          return try decoder.decode(MemberModel.self, from: jsonData)
          
        } catch let err {
          print("Err", err)
        }
      } catch {
        print(error.localizedDescription)
      }
    }
    
    return nil
  }
}
