//
//  Edges.swift
//  TrailGuru
//
//  Created by kishlay kishore on 08/03/21.
//

import Foundation

class Edge {
    var id:String
    var from: Node // does not actually need to be stored!
    var to: Node
    var weight: Int
  
  init(id: String, to: Node, from: Node, weight: Int) {
        self.id = id
        self.to = to
        self.weight = weight
        self.from = from
    }
}
