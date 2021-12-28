//
//  ProfileVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 19/02/21.
//

import UIKit
import AlamofireImage
class ProfileVC: UIViewController {
  
  @IBOutlet weak var viewProfileImg: UIControl!
  @IBOutlet weak var imgProfilePic: UIImageView!
  @IBOutlet weak var tfName: UITextField!
  @IBOutlet weak var tfEmail: UITextField!
  @IBOutlet weak var tfMobileNumber: UITextField!
  @IBOutlet weak var btnSave: UIButton!
  
  var isEditable = false
  var datasource:ProfileDataModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    apiProfile()
    tfMobileNumber.isUserInteractionEnabled = false
    editField(option: false)
    self.title = "My Profile"
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Inter-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
    DispatchQueue.main.async {
      self.viewProfileImg.cornerRadius = self.viewProfileImg.frame.height / 2
      self.imgProfilePic.cornerRadius = self.imgProfilePic.frame.height / 2
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.isNavigationBarHidden = false
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.03137254902, green: 0.6980392157, blue: 0.7333333333, alpha: 1)
  }
  
  func editField(option:Bool) {
    viewProfileImg.isUserInteractionEnabled = option
    tfName.isUserInteractionEnabled = option
    tfEmail.isUserInteractionEnabled = option
    if option {
      btnSave.setTitle("Save", for: .normal)
    } else {
      btnSave.setTitle("Edit", for: .normal)
    }
    
  }
  
  @IBAction func selectImg_action(_ sender: UIControl) {
    showImagePickerView()
  }
  
  // MARK: Back button Action
  @IBAction func btnBack_Action(_ sender: UIBarButtonItem) {
    self.navigationController?.popViewController(animated: true)
  }
  // MARK: Button Save Action
  @IBAction func btnSave_Action(_ sender: UIButton) {
    if !isEditable {
      editField(option: true)
      isEditable = true
    } else {
      apiUpdateProfile()
    }
  }
}
//MARK: UIImagePickerController Config
extension ProfileVC {
  func openCamera() {
    
    if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = UIImagePickerController.SourceType.camera
      //imagePicker.allowsEditing = true
      imagePicker.delegate = self
      self.present(imagePicker, animated: true, completion: nil)
    } else {
      Common.showAlertMessage(message: Messages.cameraNotFound, alertType: .warning)
    }
  }
  
  func openGallary() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    imagePicker.allowsEditing = true
    imagePicker.delegate = self
    self.present(imagePicker, animated: true, completion: nil)
  }
  
  func showImagePickerView() {
    
    let alert = UIAlertController(title: Messages.photoMassage, message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title:  Messages.txtCamera, style: .default, handler: { _ in
      self.openCamera()
    }))
    
    alert.addAction(UIAlertAction(title: Messages.txtGallery, style: .default, handler: { _ in
      self.openGallary()
    }))
    
    alert.addAction(UIAlertAction.init(title: Messages.txtCancel, style: .cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
}

//MARK: UIImagePickerControllerDelegate
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let  pickedImage = info[.editedImage] as? UIImage {
      imgProfilePic.contentMode = .scaleAspectFill
      imgProfilePic.image = pickedImage
      
    } else if let pickedImage = info[.originalImage] as? UIImage {
      imgProfilePic.contentMode = .scaleAspectFill
      imgProfilePic.image = pickedImage
    }
    picker.dismiss(animated: true, completion: nil)
  }
}

extension ProfileVC {
  // MARK: Api For Getting Profile Data
  func apiProfile() {
    if let getRequest = API.MYPROFILE.request(method: .post, with: nil, forJsonEncoding: true) {
      Global.showLoadingSpinner()
      getRequest.responseJSON { response in
        Global.dismissLoadingSpinner()
        API.MYPROFILE.validatedResponse(response, completionHandler: { (jsonObject, error) in
          guard error == nil else {
            return
          }
          guard let getData = jsonObject?["data"] as? [String: Any] else {
            return
          }
          do {
              let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
              let decoder = JSONDecoder()
              self.datasource = try decoder.decode(ProfileDataModel.self, from: jsonData)
              self.dataSet()
          } catch let err {
              print("Err", err)
          }
         // Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
        })
      }
    }
  }
  // MARK: Data Setting On text Field
  func dataSet() {
      tfName.text = datasource?.username
      tfEmail.text = datasource?.email
      tfMobileNumber.text = datasource?.mobile
      if let url = URL(string: datasource?.image ?? "") {
        imgProfilePic.af.setImage(withURL: url)
      }
  }
  
  // MARK: Update Profile
  func apiUpdateProfile() {
    let param: [String: Any] = ["username": tfName.text!.trim(),"email":tfEmail.text!.trim()]
    API.UPDATEPROFILE.requestUpload( with: param, files: ["image": imgProfilePic.image ?? ""]) { (jsonObject, error) in
        Global.dismissLoadingSpinner()
        guard error == nil, (jsonObject?["success"] as! Bool ) else {
            Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .error)
            return
        }
      self.editField(option: false)
      self.isEditing = false
        Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
      self.apiProfile()
        }
    }
  
}
