
import Foundation
import CoreLocation

open class KLocation: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    var currentLocation: CLLocation?
    var address : String = ""

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.distanceFilter = 2
        //locationManager.requestAlwaysAuthorization()
        if let location = locationManager.location {
            currentLocation = location
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            //self.getLocation(location)
            locationManager.startUpdatingLocation()
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            //getLocation(location)
            //updateLocationOnServer(location: location)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getLocation(_ location: CLLocation) {
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if (error != nil) {
                print("Error in reverseGeocode")
            }
            
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count > 0 {
                let placemark = placemarks![0]
                
                var addressString : String = ""
                if placemark.subLocality != nil {
                    addressString = addressString + placemark.subLocality! + ", "
                }
                if placemark.thoroughfare != nil {
                    addressString = addressString + placemark.thoroughfare! + ", "
                }
                if placemark.locality != nil {
                    addressString = addressString + placemark.locality! + ", "
                }
                if placemark.country != nil {
                    addressString = addressString + placemark.country! + ", "
                }
                if placemark.postalCode != nil {
                    addressString = addressString + placemark.postalCode! + " "
                }
                self.address = addressString
            }
        })
    }
    
//    func updateLocationOnServer(location: CLLocation) {
//        guard let userData = UserModel.getUserModel() else {return}
//
//        let param: [String: Any] = ["user_id": userData.id!, "lat": location.coordinate.latitude, "lng": location.coordinate.longitude]
//        if let getRequest = API.UPDATELATLNG.request(method: .post, with: param, forJsonEncoding: true) {
//            getRequest.responseJSON { response in
//                API.UPDATELATLNG.validatedResponse(response, completionHandler: { jsonObject, error in
//                    guard error == nil else {
//                        return
//                    }
//                    userData.lat = "\(location.coordinate.latitude)"
//                    userData.lng = "\(location.coordinate.longitude)"
//                    userData.updateUserModel()
//                })
//            }
//        }
//    }
}
