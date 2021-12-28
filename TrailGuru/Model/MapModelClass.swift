//
//  MapModelClass.swift
//  TrailGuru
//
//  Created by kishlay kishore on 03/03/21.
//

import Foundation

// MARK: - MapListingModel
struct MapListingModel: Codable {
    let id: Int
    let name: String
    let image: String
    let gpx: String
    let isPurchased: Bool
    var downladedFilePath: String
    let amount, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, image, gpx
        case isPurchased = "is purchased"
        case amount,downladedFilePath
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
  
  
}

