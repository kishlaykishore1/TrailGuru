//
//  Home+MapboxExtension.swift
//  TrailGuru
//
//  Created by kishlay kishore on 05/03/21.
//

import UIKit
import Mapbox
import CoreLocation
import XMLMapper

extension HomeVC: MGLMapViewDelegate {
  
  func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
    //print(MGLOfflineStorage.shared.packs)
    downloadPackage()
    extractGpxFile()
    DispatchQueue.global(qos: .background).sync {
      self.getAllCrossPoints()
    }
  }
  
  
  func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
    //    self.currentPosition  = CLLocation(latitude: userLocation?.coordinate.latitude ?? 0.0, longitude: userLocation?.coordinate.longitude ?? 0.0)
    //    Common.showAlertMessage(message: "\(currentPosition)", alertType: .success)
    //    if destinationLocation != nil {
    //      self.getShortestPath(Source: self.getSourceVertex()!, Destination: self.getDestinationVertex()!)
    //    }
    //    if !pathCoordinates.isEmpty {
    //    //  for item in pathCoordinates {
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
    //          self.manualLocationUpdate(lat: Double(self.pathCoordinates[1].latitude), long: Double(self.pathCoordinates[1].longitude))
    //        }
    //     // }
    //    }
    print("didUpdateUserLocation")
  }
  
  // MARK: - Download Map Offline
  func startOfflinePackDownload() {
    let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: 0, toZoomLevel: 100)
    let userInfo = ["name": packageName]
    let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
    MGLOfflineStorage.shared.addPack(for: region, withContext: context) { (pack, error) in
      guard error == nil else {
        // The pack couldn’t be created for some reason.
        print("Error: \(error?.localizedDescription ?? "unknown error")")
        return
      }
      pack!.resume()
    }
  }
  // MARK: - Check For Offline Download Available
  func downloadPackage() {
    if let packs = MGLOfflineStorage.shared.packs {
      if packs.count > 0 {
        // Filter all packs that only have name
        let filteredPacks = packs.filter({
          guard let context = NSKeyedUnarchiver.unarchiveObject(with: $0.context) as? [String:String] else {
            print("Error retrieving offline pack context")
            return false
          }
          let packTitle = context["name"]!
          return packTitle.contains("(Data)") ? false : true
        })
        // Check if filtered packs contains your downloaded region
        for pack in filteredPacks {
          var packInfo = [String:String]()
          guard let context = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String:String] else {
            print("Error retrieving offline pack context")
            return
          }
          // Recieving packageName
          let packTitle = context["name"]!
          if packTitle == packageName {
            pack.resume()
            isPackageNameAlreadyDownloaded = true
            break
          } else {
            print("This Is another Reason")
          }
        }
      }
    }
    // If region is downloaded - return
    if isPackageNameAlreadyDownloaded {
      return
    }
    self.startOfflinePackDownload()
  }
  // MARK: - MGLOfflinePack notification handlers
  @objc func offlinePackProgessDidChange(notification: NSNotification) {
    if let pack = notification.object as? MGLOfflinePack,
       let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
      let progress = pack.progress
      let completedResources = progress.countOfResourcesCompleted
      let expectedResources = progress.countOfResourcesExpected
      // Calculate current progress percentage.
      let progressPercentage = Float(completedResources) / Float(expectedResources)
      // Setup the progress bar.
      if progressView == nil {
        progressView = UIProgressView(progressViewStyle: .default)
        let frame = view.bounds.size
        progressView.frame = CGRect(x: frame.width / 4, y: frame.height * 0.75, width: frame.width / 2, height: 10)
        view.addSubview(progressView)
      }
      progressView.progress = progressPercentage
      // If this pack has finished, print its size and resource count.
      if completedResources == expectedResources {
        let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
        print("Offline pack “\(userInfo["name"] ?? "unknown")” completed: \(byteCount), \(completedResources) resources")
        progressView.removeFromSuperview()
      } else {
        // Otherwise, print download/verification progress.
        print("Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(String(format: "%.2f", progressPercentage * 100))%.")
      }
    }
  }
  
  @objc func offlinePackDidReceiveError(notification: NSNotification) {
    if let pack = notification.object as? MGLOfflinePack,
       let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
       let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
      print("Offline pack “\(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")")
    }
  }
  
  @objc func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
    if let pack = notification.object as? MGLOfflinePack,
       let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
       let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
      print("Offline pack “\(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.")
    }
  }
  
  @objc func handleMapTap(sender: UILongPressGestureRecognizer) {
    // Convert tap location (CGPoint) to geographic coordinate (CLLocationCoordinate2D).
    let tapPoint: CGPoint = sender.location(in: mapView)
    let tapCoordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: nil)
    self.destinationLocation = CLLocation(latitude: tapCoordinate.latitude, longitude: tapCoordinate.longitude)
    for vertex in self.vertexList {
      for edge in vertex.edges {
        edge.to.visited = false
        edge.from.visited = false
      }
      vertex.visited = false
    }
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: "OKK", message: " Creating Route To This Destination", preferredStyle: .alert)
      
      let logoutAction = UIAlertAction(title: "NO", style: .cancel, handler: { alert -> Void in
        
      })
      let cancelAction = UIAlertAction(title: "YES", style: .destructive, handler: { (action : UIAlertAction!) -> Void in
        self.isNavigating = true
        self.onLocationChange(0.0, 0.0)
       // self.getShortestPath(Source: self.getSourceVertex()!, Destination: self.getDestinationVertex()!)
        alertController.dismiss(animated: true, completion: nil)
      })
      alertController.addAction(logoutAction)
      alertController.addAction(cancelAction)
      self.navigationController?.present(alertController, animated: true, completion: {
        
      })
    }
    print("You tapped at: \(tapCoordinate.latitude), \(tapCoordinate.longitude)")
    
  }
  
  // MARK: - Create Poly Line
  func addPolyline(to style: MGLStyle, trk: Trk, i: Int) {
    var polylineSource: MGLShapeSource?
    var line:MGLPolyline?
    trkName = trk.name ?? ""
    let trkDesc = trk.desc ?? ""
    var trkDifficulty = ""
    var distance = 0.0
    
    let source = MGLShapeSource(identifier: "\(i)_\(trk.name ?? "")", shape: nil, options: nil)
    style.addSource(source)
    polylineSource = source
    
    let layer = MGLLineStyleLayer(identifier: "\(i)_\(trk.name ?? "")", source: source)
    layer.lineJoin = NSExpression(forConstantValue: "\(i)_\(trk.name ?? "")")
    layer.lineCap = NSExpression(forConstantValue: "\(i)_\(trk.name ?? "")")
    layer.lineColor = NSExpression(forConstantValue: Common.hexStringToUIColor(hex: trk.topografixColor ?? ""))
    layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                   [14: 5, 18: 12])
    style.addLayer(layer)
    
    var allCoordinates = [CLLocationCoordinate2D]()
    for (_ ,trkpt) in (trk.trkseg?.trkpt ?? [Trkpt]()).enumerated() {
      let lat: Double = Double(trkpt.lat) ?? 0.0
      let long: Double = Double(trkpt.lon) ?? 0.0
      allCoordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: long))
    }
    
    var mutableCoordinates = allCoordinates
    if mutableCoordinates.count > 0 {
      for i in 0..<(mutableCoordinates.count - 1) {
        distance += CLLocation(latitude: mutableCoordinates[i].latitude, longitude: mutableCoordinates[i].longitude).distance(from: CLLocation(latitude: mutableCoordinates[i + 1].latitude, longitude: mutableCoordinates[i + 1].longitude))
      }
    }
    if trkName.contains("_") {
      let components = trkName.split(separator: "_")
      trkName = String(components[0])
      trkDifficulty = mapfunc.getTrackDifficulty(trkName: String(components[1]))
    }
    line = MGLPolyline(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
    line?.title = "Trail: \(trkName), Difficulty: \(trkDifficulty)"
    line?.subtitle = "Length: \(String(format: "%.2f", mapfunc.metersToMiles(meters: distance))) Miles, Description: \(trkDesc)"
    polylineSource?.shape = line
    self.mapView.addAnnotation(line!)
  }
  
  // MARK: Create point to represent where the symbol should be placed
  func addMarker() {
    var pointAnnotations = [MGLPointFeature]()
    var currentDistance = 0.0
    guard let style = mapView.style else { return }
    for (_,wpt) in (gpxData?.wpt ?? [Wpt]()).enumerated() {
      let point = MGLPointFeature()
      let lat: Double = Double(wpt.lat) ?? 0.0
      let long: Double = Double(wpt.lon) ?? 0.0
      point.coordinate = CLLocationCoordinate2D(latitude:lat, longitude: long)
      point.title = wpt.name?.text
      point.identifier = wpt.name?.text
      let currentDis:Double = CLLocation(latitude: lat, longitude: long).distance(from: CLLocation(latitude: currentPosition.coordinate.latitude, longitude: currentPosition.coordinate.longitude))
      if (currentDistance == 0 || currentDistance > currentDis) {
        currentDistance = currentDis
      }
      pointAnnotations.append(point)
    }
    style.setImage(UIImage(named: "map_Marker")!, forName: "map_Marker")
    let source = MGLShapeSource(identifier: "waypoints-source", features: pointAnnotations, options: nil)
    style.addSource(source)
    let symbols = MGLSymbolStyleLayer(identifier: "waypoints-symbols", source: source)
    symbols.iconImageName = NSExpression(forConstantValue: "map_Marker")
    symbols.text = NSExpression(forKeyPath: "name")
    style.addLayer(symbols)
    if currentDistance > 1000.0 {
      showDistanceDialog()
    }
  }
  
  
  // MARK:  Feature interaction
  @objc func handelAnnotationTap(sender: UITapGestureRecognizer) {
    if sender.state == .ended {
      // Limit feature selection to just the following layer identifiers.
      let layerIdentifiers: Set = ["waypoints-symbols"]
      
      // Try matching the exact point first.
      let point = sender.location(in: sender.view!)
      for feature in mapView.visibleFeatures(at: point, styleLayerIdentifiers: layerIdentifiers)
      where feature is MGLPointFeature {
        guard let selectedFeature = feature as? MGLPointFeature else {
          fatalError("Failed to cast selected feature as MGLPointFeature")
        }
        markerPopUp(feature: selectedFeature)
        return
      }
      
      let touchCoordinate = mapView.convert(point, toCoordinateFrom: sender.view!)
      let touchLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
      
      // Otherwise, get all features within a rect the size of a touch (44x44).
      let touchRect = CGRect(origin: point, size: .zero).insetBy(dx: -30.0, dy: -30.0)
      let possibleFeatures = mapView.visibleFeatures(in: touchRect, styleLayerIdentifiers: Set(layerIdentifiers)).filter { $0 is MGLPointFeature }
      
      // Select the closest feature to the touch center.
      let closestFeatures = possibleFeatures.sorted(by: {
        return CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude).distance(from: touchLocation) < CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude).distance(from: touchLocation)
      })
      if let feature = closestFeatures.first {
        guard let closestFeature = feature as? MGLPointFeature else {
          fatalError("Failed to cast selected feature as MGLPointFeature")
        }
        markerPopUp(feature: closestFeature)
        return
      }
      
      // If no features were found, deselect the selected annotation, if any.
      mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
    }
  }
  
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    if annotation is MGLPointAnnotation {
      return false
    } else {
      return true
    }
  }
  
  func markerPopUp(feature: MGLPointFeature) {
    DispatchQueue.main.async {
      let centre = feature.coordinate as CLLocationCoordinate2D
      let getLat: CLLocationDegrees = centre.latitude
      let getLon: CLLocationDegrees = centre.longitude
      self.destinationLocation = CLLocation(latitude: getLat, longitude: getLon)
      
      for vertex in self.vertexList {
        for edge in vertex.edges {
          edge.to.visited = false
          edge.from.visited = false
        }
        vertex.visited = false
      }
      DispatchQueue.main.async {
        let alertController = UIAlertController(title: "OKK", message: "\(String(describing: feature.identifier ?? "")) Creating Route To This Destination", preferredStyle: .alert)
        
        let logoutAction = UIAlertAction(title: "NO", style: .cancel, handler: { alert -> Void in
          
        })
        let cancelAction = UIAlertAction(title: "YES", style: .destructive, handler: { (action : UIAlertAction!) -> Void in
          self.isNavigating = true
          self.onLocationChange(0.0, 0.0)
         // self.getShortestPath(Source: self.getSourceVertex()!, Destination: self.getDestinationVertex()!)
          alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion: {
          
        })
      }
    }
  }
  
  func showDistanceDialog() {
    if !mapView.isHidden && defaults.object(forKey: "SelectedGpx") != nil {
      DispatchQueue.main.async {
        let alertController = UIAlertController(title: "Location Alert", message: "You are too far from trail map please close app and open when you are closer", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { alert -> Void in
          
        })
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion: nil)
      }
    }
  }
}


