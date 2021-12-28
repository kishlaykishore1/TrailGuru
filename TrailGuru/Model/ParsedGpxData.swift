//
//  ParsedGpxData.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 25/02/21.
//

import Foundation
import XMLMapper

class GpxData: XMLMappable {
    
    var nodeName: String!
    var name: String?
    var desc: String?
    var trk: [Trk]?
    var wpt: [Wpt]?

    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        name <- map["name"]
        desc <- map["desc"]
        trk <- map["trk"]
        wpt <- map["wpt"]
    }
}

class Wpt: XMLMappable {
   
    var nodeName: String!
    var lat: String!
    var lon: String!
    var name: Name?
    var ele: Ele?
    var sym: Sym?
    var type: Sym?

    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        lat <- map["_lat"]
        lon <- map["_lon"]
        name <- map["name"]
        sym <- map["sym"]
        ele <- map["ele"]
        type <- map["Type"]
    }
}

class Trk:XMLMappable {
   
    var nodeName: String!
    var name: String?
    var desc: String?
    var topografixColor: String?
    var trkseg: Trkseg?

    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        name <- map["name"]
        desc <- map["desc"]
        topografixColor <- map["topografix:color"]
        trkseg <- map["trkseg"]
    }
}

class Trkseg: XMLMappable {
   
    var nodeName: String!
    var trkpt: [Trkpt]?

    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        trkpt <- map["trkpt"]
    }
}

class Trkpt: XMLMappable {
    var nodeName: String!
    var lat: String!
    var lon: String!
    var sym: Sym?
    var ele: Ele?

    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        lat <- map["_lat"]
        lon <- map["_lon"]
        sym <- map["sym"]
        ele <- map["ele"]
    }
}

class Name:XMLMappable {
  
    var nodeName: String!
    var xmlns: String?
    var text:String?
    
    required init?(map: XMLMap) {}
    
    func mapping(map: XMLMap) {
        xmlns <- map["_xmlns"]
        text <- map["__text"]
    }
}

class Sym: XMLMappable {
    var nodeName: String!
    var xmlns: String?
    var content: String?

    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        xmlns <- map["_xmlns"]
        content <- map["__text"]
    }
}

class Ele: XMLMappable {
    var nodeName: String!
    var xmlns: String?

    required init?(map: XMLMap) {}

    func mapping(map: XMLMap) {
        xmlns <- map["_xmlns"]
    }
}
