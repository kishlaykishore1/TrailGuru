//
//  ChooseMapVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 19/02/21.
//

import UIKit

class ChooseMapVC: UIViewController {

@IBOutlet weak var tableView: UITableView!
  
    var mapData = [MapListingModel]()
    let defaults = UserDefaults.standard
    var foundItems:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Choose Map"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Inter-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.03137254902, green: 0.6980392157, blue: 0.7333333333, alpha: 1)
      
      if let SavedGpxData = self.defaults.object(forKey: "SavedGpxData") as? Data {
          let decoder = JSONDecoder()
        do {
          mapData = try decoder.decode([MapListingModel].self, from: SavedGpxData)
          foundItems = mapData.filter {$0.downladedFilePath != ""}.count
          tableView.reloadData()
        } catch {
          print("No Data Found")
        }
      }
      
    }
    
    // MARK: Back button Action
    @IBAction func btnBack_Action(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: Button View Map Action
    @IBAction func btnView_Action(_ sender: UIButton) {
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
    }
    
}
// MARK: - TableView DataSource
extension ChooseMapVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return foundItems
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableMapCell", for: indexPath) as! AvailableMapCell
        cell.btnView.tag = indexPath.row
        if let url = URL(string: mapData[indexPath.row].image) {
          cell.imgMap.af.setImage(withURL: url)
        }
        cell.lblMapName.text = mapData[indexPath.row].name
        return cell
    }
}
// MARK: - TableView delegate
extension ChooseMapVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code
    }
    
}

// MARK: - TableView cell class
class AvailableMapCell: UITableViewCell {
    
    @IBOutlet weak var imgMap: UIImageView!
    @IBOutlet weak var lblMapName: UILabel!
    @IBOutlet weak var btnView: UIButton!
    
}
