//
//  Home+LocationManagerExtension.swift
//  TrailGuru
//
//  Created by kishlay kishore on 05/03/21.
//

import UIKit
import Mapbox
import CoreLocation
import XMLMapper

extension HomeVC: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last
    mapView.userTrackingMode = .follow
    let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    //mapView.setCenter(center, zoomLevel: 17, animated: true)
    self.currentPosition = CLLocation(latitude: center.latitude, longitude: center.longitude)
    if destinationLocation != nil {
      onLocationChange(center.latitude, center.longitude)
    }
    
  }
  
   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      if status == .authorizedWhenInUse || status == .authorizedAlways {
          locationManager.startUpdatingLocation()
      }
  }
  
  private func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
  {
    print ("Errors:" + error.localizedDescription)
  }
}

