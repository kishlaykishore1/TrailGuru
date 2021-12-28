//
//  Home+Navigation.swift
//  TrailGuru
//
//  Created by kishlay kishore on 16/03/21.
//

import UIKit
import Mapbox
import CoreLocation

extension HomeVC {
  
  func checkForNavigationAndCalculateDistance() {
    if !pathCoordinates.isEmpty && pathCoordinates.count > 0 {
      var d: Double = 10000
      var sourceNode: Node? = nil
      if isNavigating {
        var tempVertexList: [Node] = []
        var tempEdgesList:[Edge] = []
        for (i,item) in pathCoordinates.enumerated() {
          let lat: Double = Double(item.latitude)
          let long: Double = Double(item.longitude)
          let coordinates: CLLocation = CLLocation(latitude: lat, longitude: long)
          let s = String(describing: coordinates)
          let vertex = Node(visited: false, identifier: "\(i)_V" ,name: s, indexOnTrail: i , trailName: "trk_\(i)" , latLong: coordinates, edges: [Edge]())
          tempVertexList.append(vertex)
          let tempD: Double = currentPosition.distance(from: coordinates)
          if d > tempD {
            d = tempD
            sourceNode = vertex
          }
          if (i > 0) {
            tempEdgesList.removeAll()
            let distance = Double(tempVertexList[i-1].latLong.distance(from: tempVertexList[i].latLong))
            let edgeList = Edge(id: "\(i)_\(i-1)", to: tempVertexList[i-1], from: tempVertexList[i], weight: Int(distance))
            let edgeList1 = Edge(id: "\(i-1)_\(i)", to: tempVertexList[i], from: tempVertexList[i-1], weight: Int(distance))
            tempEdgesList.append(edgeList)
            tempEdgesList.append(edgeList1)
          }
          tempVertexList[i].edges = tempEdgesList
        }
        if sourceNode != nil {
          DispatchQueue.global().sync {
            for vertex in tempVertexList {
              for edge in vertex.edges {
                edge.to.visited = false
                edge.from.visited = false
              }
              vertex.visited = false
            }
          }
          self.getShortestPath(Source: sourceNode!, Destination: self.getDestinationVertex()!)
        }
      }
    }
  }
  
  
  func onLocationChange(_ lat:Double,_ long:Double) {
   // let point = CLLocation(latitude: lat, longitude: long)
    if gpxData != nil {
      //Current Trail
      let currentTrk:Trk = getCurrentTrail(track: gpxData?.trk ?? [Trk]())
        if currentTrk != nil {
          trkName = currentTrk.name ?? ""
          if trkName.contains("_") {
            let str:[String] = trkName.components(separatedBy: "_")
            if str.count == 2 {
              let trkName01 = str[0]
              setCurrentTrailConfig(currentTrail: String(trkName01.suffix(2)), currentTrailDistance: getTrackDistance(currTrk: currentTrk), trkDifficulty: str[1])
            } else if str.count == 3 {
              setCurrentTrailConfig(currentTrail: str[1], currentTrailDistance: getTrackDistance(currTrk: currentTrk), trkDifficulty: str[2].lowercased())
            }
          }
        }
      do {
        // NEXT Trail
        nextTrkName = ""
        var nextDistance:Double = 0.0
        if currentTrk != nil {
          let nextTrkBean: Trk? = getFirstIntersectTrail(latLng: getRemainingLatLngCurrentTrail(trkData: currentTrk))
          if nextTrkBean != nil {
            nextTrkName = nextTrkBean?.name ?? ""
            nextDistance = getTrackDistanceFromLocation(currTrk: nextTrkBean!, fromPos: currentPosition)
            if isNavigating {
              getNavigationDirection()
            }
            if !nextTrkName.isEmpty {
              let str:[String] = nextTrkName.components(separatedBy: "_")
              nextTrkName = str[0]
             setNextTrailConfig(currentTrail: nextTrkName, trailDistance: nextDistance, trkDifficulty: str[1])
            } else {
              setNextTrailConfig(currentTrail: "", trailDistance: 0, trkDifficulty: "")
            }
          }
        }
      }
      if isNavigating {
        if destinationLocation != nil {
          if nearestDistance > 20 {
            if !isWrongAlertShowing {
              self.showWrongPathDialog()
            }
          }
          for vertex in self.vertexList {
            for edge in vertex.edges {
              edge.to.visited = false
              edge.from.visited = false
            }
            vertex.visited = false
          }
          self.getShortestPath(Source: self.getSourceVertex()!, Destination: self.getDestinationVertex()!)
        }
        lblCurrentDistance.isHidden = false
        let dist: Double = currentPosition.distance(from: destinationLocation)
        let dist01 = String(format: "%.2f", mapfunc.metersToMiles(meters: dist))
        self.lblCurrentDistance.text = "\(dist01) miles"
      }
      checkForReachDestination()
    }
  }
    
  
  func getTrackDistance(currTrk: Trk) -> Double {
    var distance = 0.0
    if currTrk.trkseg?.trkpt?.count ?? 0 > 2 {
      for (_ ,trkpt) in (currTrk.trkseg?.trkpt ?? [Trkpt]()).enumerated() {
        for (_,trkpt1) in (currTrk.trkseg?.trkpt ?? [Trkpt]()).enumerated() {
          
          distance += CLLocation(latitude: Double(trkpt.lat) ?? 0.0, longitude: Double(trkpt.lon) ?? 0.0).distance(from: CLLocation(latitude: Double(trkpt1.lat) ?? 0.0, longitude: Double(trkpt1.lon) ?? 0.0))
        }
      }
    }
    return distance
  }
  
  
  func getTrackDistanceFromLocation(currTrk: Trk, fromPos: CLLocation) -> Double {
    var distance:Double = -1
    if currTrk.trkseg?.trkpt?.count ?? 0 >= 2 {
      for (_ ,trkpt) in (currTrk.trkseg?.trkpt ?? [Trkpt]()).enumerated() {
        let tempDistance = CLLocation(latitude: Double(trkpt.lat) ?? 0.0, longitude: Double(trkpt.lon) ?? 0.0).distance(from: fromPos)
        if (distance == -1 || distance > tempDistance) {
          distance = tempDistance
        }
      }
    }
    return distance
  }
  
  
  func getCurrentTrail(track:[Trk]) -> Trk {
    var finalTrk:Trk? = nil
    if !track.isEmpty && track.count > 0 {
      var dist:Double = -1
      for (_,trk) in track.enumerated() {
        let trackdata:[Trkpt] = trk.trkseg?.trkpt ?? [Trkpt]()
        var minDist:Double = -1
        if !trackdata.isEmpty {
          for (_,item) in trackdata.enumerated() {
            let lat01 = Double(item.lat) ?? 0.0
            let long01 = Double(item.lon) ?? 0.0
            let latlong = CLLocation(latitude: lat01, longitude: long01)
            let tempdist:Double = latlong.distance(from: currentPosition)
            if (minDist == -1 || minDist > tempdist) {
              minDist = tempdist
            }
          }
        }
        if (dist == -1 || dist > minDist) {
          dist = minDist
          finalTrk = trk
        }
      }
    }
    return finalTrk!
  }
  
  func getNearestPosition(trackData:[Trkpt],crrPos:CLLocation) -> CLLocation? {
    var minDist:Double = -1
    var nearestPosition:CLLocation? = nil
    if !trackData.isEmpty {
      for (_,item) in trackData.enumerated() {
        let lat01 = Double(item.lat) ?? 0.0
        let long01 = Double(item.lon) ?? 0.0
        let latlong = CLLocation(latitude: lat01, longitude: long01)
        let tmpDist:Double = latlong.distance(from: crrPos)
        if (minDist == -1 || minDist > tmpDist) {
          minDist = tmpDist
          nearestPosition = latlong
        }
      }
    }
    return nearestPosition
  }
  
  func getNearestPosition(trackData:Trk,position:CLLocation) -> CLLocation? {
    var minDist:Double = -1
    var nearestPosition:CLLocation? = nil
    if trackData != nil {
      for (_,item) in (trackData.trkseg?.trkpt ?? [Trkpt]()).enumerated() {
        let lat01 = Double(item.lat) ?? 0.0
        let long01 = Double(item.lon) ?? 0.0
        let latlong = CLLocation(latitude: lat01, longitude: long01)
        let tmpDist:Double = latlong.distance(from: position)
        if (minDist == -1 || minDist > tmpDist) {
          minDist = tmpDist
          nearestPosition = latlong
        }
      }
    }
    if  CLLocationDegrees(trackData.trkseg?.trkpt?[0].lat ?? "") == nearestPosition?.coordinate.latitude &&
          CLLocationDegrees(trackData.trkseg?.trkpt?[0].lon ?? "") == nearestPosition?.coordinate.longitude {
      isLastLocationonTrail = true
    } else {
      isLastLocationonTrail = CLLocationDegrees(trackData.trkseg?.trkpt?[(trackData.trkseg?.trkpt?.count ?? 0) - 1].lat ?? "") == nearestPosition?.coordinate.latitude &&
        CLLocationDegrees(trackData.trkseg?.trkpt?[(trackData.trkseg?.trkpt?.count ?? 0) - 1].lon ?? "") == nearestPosition?.coordinate.longitude
    }
    return nearestPosition
  }
  
  
  func getNextTrail(trk:[Trk],fromPosition:CLLocation) -> Trk? {
    var finalTrk:Trk? = nil
    if !trk.isEmpty && trk.count > 0 {
      var dist:Double = -1
      var tempLatLong:CLLocation? = nil
      for (_,item) in trk.enumerated() {
        let data:Trk = item
        if !(data.name?.elementsEqual(trkName) ?? false) {
          let trkData:[Trkpt] = data.trkseg?.trkpt ?? [Trkpt]()
          var minDist:Double = -1
          if !trkData.isEmpty {
            for (_,item) in trkData.enumerated() {
              let lat01 = Double(item.lat) ?? 0.0
              let long01 = Double(item.lon) ?? 0.0
              let latlong = CLLocation(latitude: lat01, longitude: long01)
              let tmpDist:Double = latlong.distance(from: fromPosition)
              if (minDist == -1 || minDist > tmpDist) {
                minDist = tmpDist;
                tempLatLong = latlong
              }
            }
          }
          if (dist == -1 || dist > minDist) {
            dist = minDist;
            finalTrk = item
            tempInteractionPoint = tempLatLong ?? CLLocation()
          }
        }
      }
    }
    return finalTrk
  }
  
  func getRemainingLatLngCurrentTrail(trkData:Trk) -> [CLLocation] {
    var latLongRemain:[CLLocation] = [CLLocation]()
    let trackPointData:[Trkpt] = trkData.trkseg?.trkpt ?? [Trkpt]()
    let nearestPosition = getNearestPosition(trackData: trackPointData, crrPos: currentPosition)
    if (nearestPosition != nil && self.nearestposition != nearestPosition) {
      nearestPrevposition = self.nearestposition
      self.nearestposition = nearestPosition ?? CLLocation()
    }
    if nearestPosition != nil {
      for (i,item) in trackPointData.enumerated() {
        let tempTrkptData: Trkpt = item
        let currentLat01 = self.nearestposition.coordinate.latitude
        let currentLng01 = self.nearestposition.coordinate.longitude
        let currentLat02 = nearestPrevposition.coordinate.latitude
        let currentLng02 = nearestPrevposition.coordinate.longitude
        let tempLat = Double(tempTrkptData.lat)
        let tempLng = Double(tempTrkptData.lon)
        
        if (currentLat01 == tempLat && currentLng01 == tempLng) {currentTempPosition = i}
        if (currentLat02 == tempLat && currentLng02 == tempLng) {prevPosition = i}
      }
      if (currentTempPosition > prevPosition) {
        for k in (0...(trackPointData.count - 1)).reversed() {
          if k > currentTempPosition {
            latLongRemain.append(CLLocation(latitude: CLLocationDegrees(trackPointData[k].lat) ?? 0.0, longitude: CLLocationDegrees(trackPointData[k].lon) ?? 0.0))
          }
        }
      }
      if (currentTempPosition < prevPosition) {
        for k in 0..<currentTempPosition {
          latLongRemain.append(CLLocation(latitude: CLLocationDegrees(trackPointData[k].lat) ?? 0.0, longitude: CLLocationDegrees(trackPointData[k].lon) ?? 0.0))
        }
      }
    }
    return latLongRemain
  }
  
  func getFirstIntersectTrail(latLng:[CLLocation]) ->Trk? {
    var result:Trk? = nil
    if !latLng.isEmpty && latLng.count > 0 {
      for (_,item) in latLng.enumerated() {
        let nextTrail:Trk? = getNextTrail(trk: gpxData?.trk ?? [Trk](), fromPosition: CLLocation(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude))
        let dist:Double = getTrackDistanceFromLocation(currTrk: nextTrail! , fromPos: CLLocation(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude))
        let newLatLng = getNearestPosition(trackData: nextTrail!, position: currentPosition)
        if dist < 10 {
          result = nextTrail
          let point0:MapFunctions.point = MapFunctions.point()
          point0.x = CGFloat(nearestPrevposition.coordinate.latitude)
          point0.y = CGFloat(nearestPrevposition.coordinate.longitude)
          
          let point1:MapFunctions.point = MapFunctions.point()
          point1.x = CGFloat(nearestposition.coordinate.latitude)
          point1.y = CGFloat(nearestposition.coordinate.longitude)
          
          let point2:MapFunctions.point = MapFunctions.point()
          point2.x = CGFloat(newLatLng?.coordinate.latitude ?? 0.0)
          point2.y = CGFloat(newLatLng?.coordinate.longitude ?? 0.0)
          DIRECTION = mapfunc.directionOfPoint(A: point0, B: point1, P: point2)
          if isLastLocationonTrail {
            DIRECTION = mapfunc.T_POINT
          }
        }
      }
    }
    return result
  }
  
  func getNavigationDirection() {
    if isNavigating {
      let point0:MapFunctions.point = MapFunctions.point()
      point0.x = CGFloat(currentPosition.coordinate.latitude)
      point0.y = CGFloat(currentPosition.coordinate.longitude)
      
      let point1:MapFunctions.point = MapFunctions.point()
      point1.x = CGFloat(tempInteractionPoint.coordinate.latitude)
      point1.y = CGFloat(tempInteractionPoint.coordinate.longitude)
      
      let point2:MapFunctions.point = MapFunctions.point()
      point2.x = CGFloat(destinationLocation.coordinate.latitude )
      point2.y = CGFloat(destinationLocation.coordinate.longitude )
      DIRECTION = mapfunc.directionOfPoint(A: point0, B: point1, P: point2)
    }
  }
  
  func checkForReachDestination() {
    do {
      if destinationLocation != nil {
        if currentPosition.distance(from: destinationLocation) <= 20 {
          DispatchQueue.main.async {
            let alertController = UIAlertController(title: "DESTINATION!!", message: "You Reached Your Destination", preferredStyle: .alert)
            
            let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: { alert -> Void in
              self.removeDestination()
              alertController.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(dismissAction)
            
            self.present(alertController, animated: true, completion: nil)
          }
        }
      }
    }
  }
  
  func removeDestination() {
    isNavigating = false
    destinationLocation = nil
    lblCurrentDistance.text = ""
    lblCurrentDistance.isHidden = true
    lblCurrentTrailNo.text = "0"
    lblNextTrail.isHidden = true
    do {
      removeLayer(mapView: self.mapView, layerIdentifier: "polyline")
    }
  }
  
  func setCurrentTrailConfig(currentTrail:String,currentTrailDistance:Double,trkDifficulty:String) {
    lblCurrentTrailNo.text = currentTrail
    if ("black".elementsEqual(trkDifficulty)) {
      viewCurrentTrail.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
      lblCurrentTrailNo.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
      showBlackTrailAlertDialog()
    } else if ("green".elementsEqual(trkDifficulty)) {
      viewCurrentTrail.backgroundColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
      lblCurrentTrailNo.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    } else if ("white".elementsEqual(trkDifficulty)) {
      viewCurrentTrail.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
      lblCurrentTrailNo.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    } else if ("blue".elementsEqual(trkDifficulty)) {
      viewCurrentTrail.backgroundColor = #colorLiteral(red: 0.4119389951, green: 0.8247622848, blue: 0.9853010774, alpha: 1)
      lblCurrentTrailNo.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    currentTrailInfo = "Trail \(currentTrail), \(trkDifficulty), \(String(format: "%.2f", mapfunc.metersToMiles(meters: currentTrailDistance))) Miles "
  }
  
  
  func setNextTrailConfig(currentTrail:String,trailDistance:Double,trkDifficulty:String) {
    if isNavigating {
      lblNextTrail.isHidden = false
      let dis = "\(String(format: "%.2f", mapfunc.metersToMiles(meters: trailDistance))) miles"
      let dataString = "\(currentTrail) in \(dis)"
      lblNextTrail.textColor = #colorLiteral(red: 0.03137254902, green: 0.6980392157, blue: 0.7333333333, alpha: 1)
      lblNextTrail.font = UIFont(name: "Inter-SemiBold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
      DIRECTION == mapfunc.RIGHT ? lblNextTrail.set(text: dataString,rightIcon: #imageLiteral(resourceName: "rightTurn")) :
        DIRECTION == mapfunc.LEFT ? lblNextTrail.set(text: dataString,leftIcon: #imageLiteral(resourceName: "leftTurn")) :
        DIRECTION == mapfunc.T_POINT ? lblNextTrail.set(text: dataString,rightIcon: #imageLiteral(resourceName: "tpoint_icon")) :
      lblNextTrail.set(text: "")
    }
  }
  
 
  func showBlackTrailAlertDialog() {
    if (!isBlackContinue) {
      DispatchQueue.main.async {
        let alertController = UIAlertController(title: "Warning!!", message: "Beware this trail is rated most difficult.", preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { alert -> Void in
          self.isBlackContinue = true
          alertController.dismiss(animated: true, completion: nil)
        })
        let dismissAction = UIAlertAction(title: "Quit", style: .cancel, handler: { alert -> Void in
  
          alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(dismissAction)
        alertController.addAction(continueAction)
        self.navigationController?.present(alertController, animated: true, completion: nil)
      }
    }
  }
  
  func showWrongPathDialog() {
    self.isWrongAlertShowing = true
      DispatchQueue.main.async {
        let alertController = UIAlertController(title: "Wrong Way", message: "You missed a turn.", preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Reroute again ?", style: .default, handler: { alert -> Void in
          self.onLocationChange(self.currentPosition.coordinate.latitude, self.currentPosition.coordinate.longitude)
          self.isWrongAlertShowing = false;
          alertController.dismiss(animated: true, completion: nil)
        })
        let dismissAction = UIAlertAction(title: "No", style: .cancel, handler: { alert -> Void in
          self.isWrongAlertShowing = false
          alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(dismissAction)
        alertController.addAction(continueAction)
        self.navigationController?.present(alertController, animated: true, completion: nil)
      }
  }
}


