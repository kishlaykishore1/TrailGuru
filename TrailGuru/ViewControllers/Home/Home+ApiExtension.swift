//
//  Home+ApiExtension.swift
//  TrailGuru
//
//  Created by kishlay kishore on 05/03/21.
//

import UIKit
import Mapbox
import CoreLocation
import XMLMapper

extension HomeVC {
  // MARK: APi Logout
  func apiLogout() {
    if let getRequest = API.LOGOUT.request(method: .post, with: nil, forJsonEncoding: true) {
      Global.showLoadingSpinner()
      getRequest.responseJSON { response in
        Global.dismissLoadingSpinner()
        API.LOGOUT.validatedResponse(response, completionHandler: { (jsonObject, error) in
          guard error == nil else {
            return
          }
          Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
          if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
              sd.isUserLogin(false)
            }
          } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.isUserLogin(false)
          }
        })
      }
    }
  }
  
  // MARK: Map Update Checkup
  func checkMapUpdate(mapId:Int) {
    let param: [String: Any] = ["map_id": mapId]
    if let getRequest = API.MAPUPDATE.request(method: .post, with: param, forJsonEncoding: true) {
     // Global.showLoadingSpinner()
      getRequest.responseJSON { response in
      //  Global.dismissLoadingSpinner()
        API.MAPUPDATE.validatedResponse(response, completionHandler: { (jsonObject, error) in
          guard error == nil else {
            return
          }
          guard let getData = jsonObject?["data"] as? String else {
            return
          }
          if let SavedGpxData = self.defaults.object(forKey: "SavedGpxData") as? Data {
              let decoder = JSONDecoder()
            do {
              self.mapData = try decoder.decode([MapListingModel].self, from: SavedGpxData)
              
              for (_, item) in self.mapData.enumerated() {
                if item.id == mapId {
                  if getData != item.updatedAt {
                    DispatchQueue.main.async {
                      let alertController = UIAlertController(title: "Update Avilable", message: "There Is an Update for \(item.name)", preferredStyle: .alert)
                      
                      let updateAction = UIAlertAction(title: "UPDATE", style: .default, handler: { alert -> Void in
                        let purchaseMap = StoryBoard.Main.instantiateViewController(withIdentifier: "PurchaseMapVC") as! PurchaseMapVC
                        self.navigationController?.pushViewController(purchaseMap, animated: true)
                      })
                      let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action : UIAlertAction!) -> Void in
                        
                      })
                      alertController.addAction(updateAction)
                      alertController.addAction(cancelAction)
                      self.navigationController?.present(alertController, animated: true, completion: nil)
                    }
                  }
                }
              }
              
            } catch {
              print("No Data Found")
            }
          }
          
      //    Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
        
        })
      }
    }
  }
}

