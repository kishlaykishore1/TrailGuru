//
//  MapFunctions.swift
//  TrailGuru
//
//  Created by kishlay kishore on 08/03/21.
//

import UIKit

open class MapFunctions {
  // constant integers for directions
  let RIGHT = 1, LEFT = -1, ZERO = 0, T_POINT = 2
  
  class point {
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
  }
  
  enum LocationDirection: String {
    case UNKNOWN
    case NORTH
    case NORTH_EAST
    case EAST
    case SOUTH_EAST
    case SOUTH
    case SOUTH_WEST
    case WEST
    case NORTH_WEST
  }
  
  func getTrackDifficulty(trkName: String) -> String {
    if trkName.contains("black") {
      return "Hard"
    } else if trkName.contains("green") {
      return "Easy"
    } else if trkName.contains("white") {
      return "White"
    } else if trkName.contains("blue") {
      return "Medium"
    } else {
      return ""
    }
  }
  
  
  func metersToMiles(meters:Double) -> Double {
    return meters / 1609.3440057765
  }
  
  
  //  public static double distance(double lat1, double lon1, double lat2, double lon2) {
  //          double theta = lon1 - lon2;
  //          double dist = Math.sin(deg2rad(lat1))
  //                  * Math.sin(deg2rad(lat2))
  //                  + Math.cos(deg2rad(lat1))
  //                  * Math.cos(deg2rad(lat2))
  //                  * Math.cos(deg2rad(theta));
  //          dist = Math.acos(dist);
  //          dist = rad2deg(dist);
  //          dist = dist * 60 * 1.1515;
  //          return (dist);
  //      }
  
  
  // MARK: Function to return the modified string
  func extractInt(str:String) -> String {
    var data = str.replacingOccurrences(of: "[^\\d]", with: " ")
    data = str.trim()
    data = str.replacingOccurrences(of: " +", with: " ")
    if data.elementsEqual("") {
      return "-1"
    }
    return data
  }
  
  func directionOfPoint(A: point,B: point,P: point) -> Int {
    // subtracting co-ordinates of point A from B and P, to make A as origin
    B.x -= A.x
    B.y -= A.y
    P.x -= A.x
    P.y -= A.y
    
    // Determining cross Product
    let cross_product = Double(B.x * P.y - B.y * P.x);
    
    // return RIGHT if cross product is positive
    if cross_product > 0 {
      return RIGHT
    }
    
    // return LEFT if cross product is negative
    if cross_product < 0 {
      return LEFT
    }
    
    // return ZERO if cross product is zero.
    return ZERO;
  }
  
}
