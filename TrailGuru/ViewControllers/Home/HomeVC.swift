//
//  HomeVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 22/02/21.
//

import UIKit
import Mapbox
import CoreLocation
import XMLMapper
class HomeVC: UIViewController {
  
  
  @IBOutlet var menuView: UIView!
  @IBOutlet weak var mapView: MGLMapView!
  @IBOutlet weak var noDataView: UIView!
  @IBOutlet weak var viewCurrentTrail: UIView!
  @IBOutlet weak var lblCurrentTrailNo: UILabel!
  @IBOutlet weak var lblNextTrail: UILabel!
  @IBOutlet weak var lblCurrentDistance: UILabel!
  
  
  var progressView: UIProgressView!
  var locationManager = CLLocationManager()
  var gpxData: GpxData?
  var mapfunc = MapFunctions()
  var pickerView = UIPickerView()
  var toolBar = UIToolbar()
  var packageName = "My Offline Pack"
  var isPackageNameAlreadyDownloaded = false
  var isLastLocationonTrail = false
  var mapData = [MapListingModel]()
  let defaults = UserDefaults.standard
  var vertexList:[Node] = []
  var pathCoordinates = [CLLocationCoordinate2D]()
  var destinationLocation: CLLocation!
  var currentPosition = CLLocation()
  var previousPosition = CLLocation()
  var tempInteractionPoint = CLLocation()
  var nearestposition = CLLocation()
  var nearestPrevposition = CLLocation()
  var prevPosition = -1
  var currentTempPosition = -1
  var DIRECTION = 0
  var currentTrailInfo = ""
  var trkName = ""
  var nextTrkName = ""
  var isNavigating = false
  var isBlackContinue = false
  var nearestDistance:Double = 10000
  var isWrongAlertShowing = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard defaults.object(forKey: "SelectedGpx") != nil else {
      noDataView.isHidden = false
      return
    }
    lblNextTrail.isHidden = true
    lblCurrentDistance.isHidden = true
    lblCurrentTrailNo.text = "0"
    mapView.attributionButton.isHidden = true
    PickerViewConnection()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.requestWhenInUseAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.distanceFilter = 15
    if let location = locationManager.location {
      currentPosition = CLLocation(latitude: location.coordinate.latitude , longitude: location.coordinate.longitude)
        locationManager.startUpdatingLocation()
    }
    mapView.latitude = self.locationManager.location?.coordinate.latitude ?? 0.0
    mapView.longitude = self.locationManager.location?.coordinate.longitude ?? 0.0
    mapView.setCenter(CLLocationCoordinate2D(latitude: mapView.latitude, longitude: mapView.longitude),  zoomLevel: 13, animated: false)
    mapView.delegate = self
    mapView.showsUserLocation = true
    
    let longsingleTap = UILongPressGestureRecognizer(target: self, action: #selector(handleMapTap(sender:)))
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(handelAnnotationTap(sender:)))
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleViewTap(_:)))
    viewCurrentTrail.addGestureRecognizer(tap)
    viewCurrentTrail.isUserInteractionEnabled = true
    
    for recognizer in mapView.gestureRecognizers! where recognizer is UILongPressGestureRecognizer {
      longsingleTap.require(toFail: recognizer)
    }
    for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
     singleTap.require(toFail: recognizer)
    }
    mapView.addGestureRecognizer(longsingleTap)
    mapView.addGestureRecognizer(singleTap)
 
    NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgessDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
    
    DispatchQueue.main.async {
      self.viewCurrentTrail.cornerRadius = self.viewCurrentTrail.frame.height / 2
    }
    guard let selectedGpxID = defaults.object(forKey: "SelectedMapId") as? Int, selectedGpxID != 0 else {
      return
    }
    DispatchQueue.global(qos: .background).sync {
      self.checkMapUpdate(mapId: selectedGpxID)
    }
   // checkMapUpdate(mapId: selectedGpxID)
  }
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    // When leaving this view controller, suspend offline downloads.
    guard let packs = MGLOfflineStorage.shared.packs else { return }
    for pack in packs {
      if let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
        print("Suspending download of offline pack: “\(userInfo["name"] ?? "unknown")”")
      }
      pack.suspend()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.isNavigationBarHidden = true
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: Present the Menu Sheet
  @IBAction func btnMenu_Action(_ sender: UIButton) {
    openMenuList()
  }
  
  // MARK: Dismiss the Menu Sheet
  @IBAction func btmDismiss_action(_ sender: UIButton) {
    closeMenuList()
  }
  
  // MARK: Menu List Actions
  @IBAction func btnMenuItems_Action(_ sender: UIButton) {
    closeMenuList()
    switch (sender.tag) {
    case 1:
      let chooseMap = StoryBoard.Main.instantiateViewController(withIdentifier: "ChooseMapVC") as! ChooseMapVC
      self.navigationController?.pushViewController(chooseMap, animated: true)
      break
    case 2:
      let customAlert = StoryBoard.Main.instantiateViewController(withIdentifier: "MapLegendVC") as! MapLegendVC
      customAlert.providesPresentationContextTransitionStyle = true
      customAlert.definesPresentationContext = true
      customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
      customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
      customAlert.delegate = self
      self.present(customAlert, animated: true, completion: nil)
      break
    case 3:
      let purchaseMap = StoryBoard.Main.instantiateViewController(withIdentifier: "PurchaseMapVC") as! PurchaseMapVC
      self.navigationController?.pushViewController(purchaseMap, animated: true)
      break
    case 4:
      DispatchQueue.main.async {
        let alertController = UIAlertController(title: "Current Location", message: "Latitude: \(self.locationManager.location?.coordinate.latitude ?? 0.0) \n Longitude: \(self.locationManager.location?.coordinate.longitude ?? 0.0)", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Share", style: .default, handler: { alert -> Void in
          alertController.dismiss(animated: true) {
            let items = ["My Current Location Is,Latitude: \(self.locationManager.location?.coordinate.latitude ?? 0.0),Longitude: \(self.locationManager.location?.coordinate.longitude ?? 0.0) "]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(ac, animated: true)
          }
        })
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true, completion: nil)
      }
      break
    case 5:
      let support = StoryBoard.Main.instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
      self.navigationController?.pushViewController(support, animated: true)
      break
    case 6:
      let aboutus = StoryBoard.Main.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
      self.navigationController?.pushViewController(aboutus, animated: true)
      break
    case 7:
      let profilevc = StoryBoard.Main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
      self.navigationController?.pushViewController(profilevc, animated: true)
      break
    case 8:
      self.apiLogout()
      break
    default:
      break
    }
  }
  
  // MARK: Button Buy On Empty Screen Action
  @IBAction func btnBuy_Action(_ sender: UIButton) {
    let purchaseMap = StoryBoard.Main.instantiateViewController(withIdentifier: "PurchaseMapVC") as! PurchaseMapVC
    self.navigationController?.pushViewController(purchaseMap, animated: true)
  }
  
  // MARK: Button Buy On Empty Screen Action
  @IBAction func btnDisplayedMarker_list(_ sender: UIButton) {
    self.view.addSubview(pickerView)
    self.view.addSubview(toolBar)
  }
  
  // MARK: Button Current location Action
  @IBAction func btnCurrentLocation(_ sender: UIButton) {
    let camera = MGLMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: self.locationManager.location?.coordinate.latitude ?? 0.0, longitude: self.locationManager.location?.coordinate.longitude ?? 0.0), acrossDistance: 4500, pitch: 15, heading: 180)
    mapView.fly(to: camera, withDuration: 1,
    peakAltitude: 3000, completionHandler: nil)
  }
  
  // function which is triggered when handleTap is called
  @objc func handleViewTap(_ sender: UITapGestureRecognizer) {
    if currentTrailInfo != "" {
      Common.showAlertMessage(message: self.currentTrailInfo, alertType: .success)
    }
  }
  
}
//MARK:- Function for Menu Sheet
extension HomeVC {
  // MARK: Open Menu List
  func openMenuList() {
    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    let screen = UIScreen.main.bounds.size
    self.menuView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.menuView.height)
    window?.addSubview(self.menuView)
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
      self.menuView.frame = CGRect(x: 0, y: 0, width: screen.width, height: self.menuView.height)
    }, completion: nil)
  }
  
  // MARK: Close Menu List
  func closeMenuList() {
    UIView.animate(withDuration: 1.5, delay: 1.5,usingSpringWithDamping: 1.0,initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
    }) { _ in
      self.menuView.removeFromSuperview()
    }
  }
  
  // MARK:  Gpx File Data Extraction To Class
  func extractGpxFile() {
    guard let fileName = UserDefaults.standard.object(forKey: "SelectedGpx") else {
      return
    }
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let url = URL(fileURLWithPath: path)
    let filePath = url.appendingPathComponent(fileName as! String).path
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath)  {
      do {
        let stringData = try String(contentsOfFile: filePath , encoding: .utf8)
        let data = stringData.data(using: .utf8)
        do {
          let xmlDictionary = try XMLSerialization.xmlObject(with: data!) as? [String: Any]
          gpxData = XMLMapper<GpxData>().map(XMLObject: xmlDictionary)
          
          for (i ,trk) in (gpxData?.trk ?? [Trk]()).enumerated() {
            addPolyline(to: mapView.style!, trk: trk, i: i)
          }
          DispatchQueue.main.async {
            self.addMarker()
          }
        } catch {
          print("Serialization error occurred: \(error.localizedDescription)")
        }
      } catch {
        print(error)
      }
    } else {
      Common.showAlertMessage(message: "No File Found ", alertType: .warning)
    }
  }
}
// MARK: - Map legend Controller Delegate Assigning
extension HomeVC: NotiPermissionAlertViewDelegate {
  func actionNotiAuthorize() {}
  func actionNotiCloseBtn() {}
}

// MARK: - Picker View Setup
extension HomeVC {
  func PickerViewConnection() {
    pickerView = UIPickerView.init()
    pickerView.delegate = self
    pickerView.dataSource = self
    pickerView.backgroundColor = UIColor.white
    pickerView.setValue(UIColor.black, forKey: "textColor")
    pickerView.autoresizingMask = .flexibleWidth
    pickerView.contentMode = .center
    pickerView.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
      
      toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
      toolBar.barStyle = .black
      toolBar.isTranslucent = true
      let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onDoneButtonTapped))
      let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(onCancelButtonTapped))
      let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      toolBar.setItems([cancel, flexibleSpace, done], animated: false)
  }
  
  // MARK: The Function For the Picker Done button
  @objc func onDoneButtonTapped() {
      
      toolBar.removeFromSuperview()
      pickerView.removeFromSuperview()
  }
  // MARK: The Function For the Picker Cancel button
  @objc func onCancelButtonTapped() {
      toolBar.removeFromSuperview()
      pickerView.removeFromSuperview()
  }
}

//MARK:- UIPickerView Datasource Methods
extension HomeVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return gpxData?.wpt?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return gpxData?.wpt?[row].name?.text
    }
    
}
//MARK:- UIViewPicker Datasource Methods
extension HomeVC: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      let lat: Double = Double(gpxData?.wpt?[row].lat ?? "") ?? 0.0
      let long: Double = Double(gpxData?.wpt?[row].lon ?? "") ?? 0.0
      self.destinationLocation = CLLocation(latitude: lat, longitude: long)
      for vertex in self.vertexList {
        for edge in vertex.edges {
          edge.to.visited = false
          edge.from.visited = false
        }
        vertex.visited = false
      }
      self.isNavigating = true
      self.onLocationChange(0.0, 0.0)
    }
}
