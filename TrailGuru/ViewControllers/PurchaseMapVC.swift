//
//  PurchaseMapVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 19/02/21.
//

import UIKit
import Alamofire
import AlamofireImage
class PurchaseMapVC: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  var mapData = [MapListingModel]()
  let defaults = UserDefaults.standard
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Purchase Map"
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Inter-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
    self.apiMapdata()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.isNavigationBarHidden = false
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.03137254902, green: 0.6980392157, blue: 0.7333333333, alpha: 1)
  }
  
  // MARK: Back button Action
  @IBAction func btnBack_Action(_ sender: UIBarButtonItem) {
    self.navigationController?.popViewController(animated: true)
  }
  // MARK: Button Buy Map Action
  @IBAction func btnBuy_Action(_ sender: UIButton) {
          if  mapData[sender.tag].downladedFilePath != "" {
            defaults.setValue(self.mapData[sender.tag].downladedFilePath, forKey: "SelectedGpx")
            defaults.setValue(self.mapData[sender.tag].id, forKey: "SelectedMapId")
            if #available(iOS 13.0, *) {
              let scene = UIApplication.shared.connectedScenes.first
              if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sd.isUserLogin(true)
              }
            } else {
              let appDelegate = UIApplication.shared.delegate as! AppDelegate
              appDelegate.isUserLogin(true)
            }
          } else {
    downloadFile(url: URL(string: mapData[sender.tag].gpx)!) { (filepath) in
      self.mapData[sender.tag].downladedFilePath = filepath
      let encoder = JSONEncoder()
      if let encoded = try? encoder.encode(self.mapData) {
        self.defaults.set(encoded, forKey: "SavedGpxData")
      }
      self.tableView.reloadData()
      
      self.defaults.setValue(self.mapData[sender.tag].downladedFilePath, forKey: "SelectedGpx")
      self.defaults.setValue(self.mapData[sender.tag].id, forKey: "SelectedMapId")
      if #available(iOS 13.0, *) {
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
          sd.isUserLogin(true)
        }
      } else {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.isUserLogin(true)
      }
    }
  }
    
  }
}
// MARK: - TableView DataSource
extension PurchaseMapVC: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return mapData.count
    
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PurchasedMapCell", for: indexPath) as! PurchasedMapCell
    cell.btnBuy.tag = indexPath.row
    if let url = URL(string: mapData[indexPath.row].image ) {
      cell.imgMap.af.setImage(withURL: url)
    }
    cell.lblMapName.text = mapData[indexPath.row].name
    cell.lblMapPrice.text = "$ \(mapData[indexPath.row].amount )"
    if  mapData[indexPath.row].downladedFilePath != "" {
      cell.btnBuy.setTitle("View", for: .normal)
    } else {
      cell.btnBuy.setTitle("Buy", for: .normal)
    }
    return cell
  }
}
// MARK: - TableView delegate
extension PurchaseMapVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //code
  }
  
}

// MARK: - TableView cell class
class PurchasedMapCell: UITableViewCell {
  @IBOutlet weak var imgMap: UIImageView!
  @IBOutlet weak var lblMapName: UILabel!
  @IBOutlet weak var btnBuy: UIButton!
  @IBOutlet weak var lblMapPrice: UILabel!
}

extension PurchaseMapVC {
  // MARK: Api for Map Purchase/Map Data
  func apiMapdata() {
    if let getRequest = API.MAPLISTING.request(method: .get, with: nil, forJsonEncoding: true) {
      Global.showLoadingSpinner()
      getRequest.responseJSON { response in
        Global.dismissLoadingSpinner()
        API.MAPLISTING.validatedResponse(response, completionHandler: { (jsonObject, error) in
          guard error == nil else {
            return
          }
          guard let getData = jsonObject?["data"] as? [[String: Any]] else {
            return
          }
          do {
            let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
            let decoder = JSONDecoder()
            self.mapData = try decoder.decode([MapListingModel].self, from: jsonData)
            
            if let SavedGpxData = self.defaults.object(forKey: "SavedGpxData") as? Data {
              let decoder = JSONDecoder()
              if let loadedGpxData = try? decoder.decode([MapListingModel].self, from: SavedGpxData) {
                for (_ , item) in loadedGpxData.enumerated() {
                  for (i, mapdata) in self.mapData.enumerated() {
                    if item.id == mapdata.id {
                      if item.downladedFilePath != "" {
                        self.mapData[i].downladedFilePath = item.downladedFilePath
                      }
                    }
                  }
                }
              }
            }
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.mapData) {
              self.defaults.set(encoded, forKey: "SavedGpxData")
            }
            self.tableView.reloadData()
          } catch let err {
            print("Err", err)
          }
          // Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
        })
      }
    }
  }
  
  // MARK: - Function to download File
  func downloadFile(url: URL, completion: @escaping (String) -> Void) {
    Global.showLoadingSpinner()
    let destination: DownloadRequest.Destination = { _, _ in
      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let fileURL = documentsURL.appendingPathComponent(url.lastPathComponent)
      
      return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    AF.download(url, to: destination).response { response in
      debugPrint(response)
      Global.dismissLoadingSpinner()
      if response.error == nil, let filePath = response.fileURL?.path {
        let theFileName = (filePath as NSString).lastPathComponent
        completion(theFileName)
      }
    }
  }
  
}
