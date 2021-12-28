//
//  Home+ShortestRoutFunction.swift
//  TrailGuru
//
//  Created by kishlay kishore on 08/03/21.
//

import UIKit
import Mapbox
import CoreLocation

extension HomeVC {
  
  // MARK: Polyline for Dijkstra Algorithm
  func addDijkstraPolyline(to style: MGLStyle, allCoordinates:[CLLocationCoordinate2D]) {
    var polylineSource: MGLShapeSource?
    var line:MGLPolyline?
    removeLayer(mapView: self.mapView, layerIdentifier: "polyline")
    let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
    style.addSource(source)
    polylineSource = source
    let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
    layer.lineJoin = NSExpression(forConstantValue: "round")
    layer.lineCap = NSExpression(forConstantValue: "round")
    layer.lineColor = NSExpression(forConstantValue: UIColor.red)
    layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 5, 18: 12])
    style.addLayer(layer)
    line = MGLPolyline(coordinates: allCoordinates, count: UInt(allCoordinates.count))
    line?.title = "Name Not Available"
    polylineSource?.shape = line
    self.mapView.addAnnotation(line!)
  }
  
  func removeLayer(mapView: MGLMapView, layerIdentifier: String) {
    guard let currentLayers = mapView.style?.layers else { return }
    if currentLayers.filter({ $0.identifier == layerIdentifier}).first != nil {
      print("Layer \(layerIdentifier) found.")
      guard let mapStyle = mapView.style else { return }
      // remove layer first
      if let styleLayer = mapStyle.layer(withIdentifier: layerIdentifier) {
        mapStyle.removeLayer(styleLayer)
      }
      if let source = mapStyle.source(withIdentifier: layerIdentifier) {
        mapStyle.removeSource(source)
      }
    }
  }
  
  func getShortestPath(Source: Node, Destination: Node) {
    let path = shortestPath(source: Source, destination: Destination)
    if let succession: [String] = path?.array.reversed().compactMap({ $0 }).map({$0.name}) {
      let coordinates: [CLLocation] = path?.array.reversed().compactMap({ $0 }).map({$0.latLong}) ?? [CLLocation]()
      pathCoordinates.removeAll()
      for (_,item) in coordinates.enumerated() {
        pathCoordinates.append(item.coordinate)
      }
      print("🏁 Quickest path: \(succession)")
      addDijkstraPolyline(to: mapView.style!, allCoordinates: pathCoordinates)
    
    } else {
      Common.showAlertMessage(message: "No Route Found", alertType: .error)
      print("💥 No path between \(Source.name) & \(Destination.name)")
    }
  }
  
  
//  func manualLocationUpdate(lat: Double, long: Double) {
//    let coordinates: CLLocation = CLLocation(latitude: lat, longitude: long)
//    self.currentPosition = coordinates
//    if destinationLocation != nil {
//      checkForNavigationAndCalculateDistance()
//    }
//  }
  
  func getAllCrossPoints() {
    vertexList.removeAll()
    var vertexS: Node? = nil
    for (i ,trk) in (gpxData?.trk ?? [Trk]()).enumerated() {
      let name = trk.name
      for (j ,trkpt) in (trk.trkseg?.trkpt ?? [Trkpt]()).enumerated() {
        let lat: Double = Double(trkpt.lat) ?? 0.0
        let long: Double = Double(trkpt.lon) ?? 0.0
        let coordinates: CLLocation = CLLocation(latitude: lat, longitude: long)
        let s = String(describing: coordinates)
        
        let vertices = Node(visited: false, identifier: "\(i)_\(j)" ,name: s, indexOnTrail: j , trailName: "trk_\(name ?? "")" , latLong: coordinates, edges: [Edge]())
        vertexList.append(vertices)
        let tempD:Double = currentPosition.distance(from: coordinates)
        if (tempD < nearestDistance) {
          nearestDistance = tempD
            vertexS = vertices
        }

      }
    }
    if (gpxData?.wpt != nil && gpxData?.wpt?.count ?? 0 > 0) {
      for (i,wpt) in (gpxData?.wpt ?? [Wpt]()).enumerated() {
        let name = wpt.name?.text
        
        let lat: Double = Double(wpt.lat) ?? 0.0
        let long: Double = Double(wpt.lon) ?? 0.0
        let coordinates: CLLocation = CLLocation(latitude: lat, longitude: long)
        let s = String(describing: coordinates)
        let vertices = Node(visited: false, identifier: "\(i)_-1" , name: s, indexOnTrail: i, trailName: "wpt_\(name ?? "")" , latLong: coordinates, edges: [Edge]())
        vertexList.append(vertices)
      }
    }
    setAllEdges(vertexList)
  }
  
  func setAllEdges(_ vertexList: [Node]) {
    for (i,list) in vertexList.enumerated() {
      var edgesList:[Edge] = []
      for (j,list1) in vertexList.enumerated() {
        // check for same vertix
        if !(list == list1) {
          if list.trailName == list1.trailName {
            //if on same trail...
            if (list.indexOnTrail == list1.indexOnTrail + 1) || (list.indexOnTrail == list1.indexOnTrail - 1) {
              let distance = Double(list.latLong.distance(from: list1.latLong))
              let edgeList = Edge(id: "\(i)_\(j)", to: list1, from: list, weight: Int(distance))
              let edgeList1 = Edge(id: "\(j)_\(i)", to: list, from: list1, weight: Int(distance))
              edgesList.append(edgeList)
              edgesList.append(edgeList1)
            }
          }
          if list.trailName.contains("wpt_") {
            guard let nodeK = setVertixToNearestPoint(list) else {
              return
            }
            let distance = Double(list.latLong.distance(from: nodeK.latLong))
            let edgeList = Edge(id: "\(i)_\(j)", to: list, from: nodeK, weight: Int(distance))
            let edgeList1 = Edge(id: "\(j)_\(i)", to: nodeK, from: list, weight: Int(distance))
            edgesList.append(edgeList)
            edgesList.append(edgeList1)
          }
          let distance: Double = list.latLong.distance(from: list1.latLong)
          if distance <= 15 {
            edgesList.append(Edge(id: "\(i)_\(j)", to: list, from: list1, weight: Int(distance)))
            edgesList.append(Edge(id: "\(j)_\(i)", to: list1, from: list, weight: Int(distance)))
          }
        }
      }
      vertexList[i].edges = edgesList
    }
    
  }
  
  
  func setVertixToNearestPoint(_ vertexfirstIndex: Node) -> Node? {
    var result: Node?
    var dd: Double = 12000.00
    for (_,item) in vertexList.enumerated() {
      if vertexfirstIndex.identifier != item.identifier {
        let d: Double = vertexfirstIndex.latLong.distance(from: item.latLong)
        if (dd > d) {
          dd = d
          result = item
        }
      }
    }
    return result
  }
  
  // MARK: Get Source Vertex
  func getSourceVertex() -> Node? {
    var result: Node? = nil
    var distance: Double = 10000.00
    var dd: Double = 0.0
    if !vertexList.isEmpty && vertexList.count > 0 {
      print(vertexList.count)
      for (_,item) in vertexList.enumerated() {
        if !item.trailName.contains("black") {
          dd = currentPosition.distance(from: item.latLong)
          if distance > dd {
            distance = dd
            result = item
          }
        }
      }
    }
    return result
  }
  
  // MARK: Get Destination Vertex
  func getDestinationVertex() -> Node? {
    var result: Node? = nil
    var distance: Double = 10000.00
    if !vertexList.isEmpty && vertexList.count > 0 {
      for (_,item) in vertexList.enumerated() {
        if destinationLocation != nil {
          if !item.trailName.contains("black") {
            let dd: Double = destinationLocation.distance(from: item.latLong)
            if distance > dd {
              distance = dd
              result = item
            }
          }
        }
      }
    }
    return result
  }
}




//else {
//  DispatchQueue.main.async {
//    let alertController = UIAlertController(title: "WARNING!!", message: "Current Location Is Too Far Fro Trail", preferredStyle: .alert)
//
//    let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: { alert -> Void in
//      alertController.dismiss(animated: true, completion: nil)
//    })
//    alertController.addAction(dismissAction)
//
//    self.present(alertController, animated: true, completion: nil)
//  }
//}
