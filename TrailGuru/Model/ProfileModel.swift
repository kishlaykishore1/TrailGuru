//
//  ProfileModel.swift
//  TrailGuru
//
//  Created by kishlay kishore on 03/03/21.
//

import Foundation

// MARK: - ProfileDataModel
struct ProfileDataModel: Codable {
    let id, isMobileVerified: Int
    let username, email, mobile, dob: String
    let image: String

    enum CodingKeys: String, CodingKey {
        case id
        case isMobileVerified = "is_mobile_verified"
        case username, email, mobile, dob, image
    }
}
