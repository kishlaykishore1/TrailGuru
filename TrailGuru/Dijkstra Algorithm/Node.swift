//
//  Node.swift
//  TrailGuru
//
//  Created by kishlay kishore on 08/03/21.
//

import Foundation
import CoreLocation

class Node {	
    // unique identifier required for each node
    var identifier: String
    var name: String
    var trailName: String
    var latLong: CLLocation
    var indexOnTrail: Int
    var visited = false
    var edges : [Edge] = []
  

  init(visited: Bool, identifier: String, name: String, indexOnTrail: Int, trailName: String, latLong: CLLocation, edges: [Edge]) {
        self.visited = visited
        self.name = name
        self.identifier = identifier
        self.indexOnTrail = indexOnTrail
        self.trailName = trailName
        self.latLong = latLong
        self.edges = edges
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
