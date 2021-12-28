//
//  ForgetPass.swift
//  TrailGuru
//
//  Created by kishlay kishore on 03/03/21.
//

import Foundation

// MARK: - ForgetPassModel
struct ForgetPassModel: Codable {
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}
