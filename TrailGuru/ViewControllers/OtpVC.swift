//
//  OtpVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 22/02/21.
//

import UIKit
import Firebase
import FirebaseAuth

protocol BackspaceTextFieldDelegate: class {
  func textFieldDidEnterBackspace(_ textField: BackspaceTextField)
}
class OtpVC: UIViewController {
  // MARK: - Properties
  var verificationID: String = ""
  var mobileNo = ""
  var registrationParam:[String:Any]?
  var user_id:Int?
  var navString: String?
 
  
  
  // MARK: - Outlets
  @IBOutlet weak var txtOtp1: BackspaceTextField!
  @IBOutlet weak var txtOtp2: BackspaceTextField!
  @IBOutlet weak var txtOtp3: BackspaceTextField!
  @IBOutlet weak var txtOtp4: BackspaceTextField!
  @IBOutlet weak var txtOtp5: BackspaceTextField!
  @IBOutlet weak var txtOtp6: BackspaceTextField!
  
  var textFields: [BackspaceTextField] {
    return [txtOtp1,txtOtp2,txtOtp3,txtOtp4,txtOtp5,txtOtp6]
  }
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "OTP Verification"
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Inter-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
    txtOtp1.delegate = self
    txtOtp2.delegate = self
    txtOtp3.delegate = self
    txtOtp4.delegate = self
    txtOtp5.delegate = self
    txtOtp6.delegate = self
    textFields.forEach { $0.backspaceTextFieldDelegate = self }
    txtOtp1.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.isNavigationBarHidden = false
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.03137254902, green: 0.6980392157, blue: 0.7333333333, alpha: 1)
  }
  
  // MARK: Confirm Button Action
  @IBAction func action_Submit(_ sender: UIButton) {
    let otpNumber: String = "\(txtOtp1.text!)\(txtOtp2.text!)\(txtOtp3.text!)\(txtOtp4.text!)\(txtOtp5.text!)\(txtOtp6.text!)"
    Global.showLoadingSpinner()
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID , verificationCode: otpNumber)
    Auth.auth().signIn(with: credential) { (authData, error) in
      Global.dismissLoadingSpinner()
      guard error == nil else {
        Common.showAlertMessage(message: Messages.validCode, alertType: .error)
        return
      }
      if self.navString == "ForgetPass" {
        let vc = StoryBoard.Main.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
           vc.user_id = self.user_id
        self.navigationController?.pushViewController(vc, animated: true)
      } else if self.navString == "Register" {
        self.apiRegistration()
      } else {
        self.apiMobileVerified(true)
      }
    }
  }
  // MARK: Button Resend Pressed
  @IBAction func btnResendPressed(_ sender: UIButton) {
    Global.showLoadingSpinner()
    PhoneAuthProvider.provider().verifyPhoneNumber(mobileNo, uiDelegate: nil) { (verificationID, error) in
      Global.dismissLoadingSpinner()
      if let error = error {
        print(error)
        return
      }
      Common.showAlertMessage(message: Messages.txtOtpVCCodeResent, alertType: .success)
      self.verificationID = verificationID ?? ""
    }
  }
  // MARK: Button Back Action
  @IBAction func btnBack_Action(_ sender: UIBarButtonItem) {
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - TextField Delegate
extension OtpVC: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if ((textField.text?.count)! < 1) && (string.count > 0) {
      
      if textField == txtOtp1 {
        txtOtp2.becomeFirstResponder()
      }
      if textField == txtOtp2 {
        txtOtp3.becomeFirstResponder()
      }
      if textField == txtOtp3 {
        txtOtp4.becomeFirstResponder()
      }
      if textField == txtOtp4 {
        txtOtp5.becomeFirstResponder()
      }
      if textField == txtOtp5 {
        txtOtp6.becomeFirstResponder()
      }
      if textField == txtOtp6 {
        txtOtp6.resignFirstResponder()
      }
      
      textField.text = string
      return false
      
    } else if ((textField.text?.count)! >= 1) && (string.count == 0)  {
      
      if textField == txtOtp2 {
        txtOtp1.becomeFirstResponder()
      }
      if textField == txtOtp3 {
        txtOtp2.becomeFirstResponder()
      }
      if textField == txtOtp4 {
        txtOtp3.becomeFirstResponder()
      }
      if textField == txtOtp5 {
        txtOtp4.becomeFirstResponder()
      }
      if textField == txtOtp6 {
        txtOtp5.becomeFirstResponder()
      }
      if textField == txtOtp1 {
        txtOtp1.resignFirstResponder()
      }
      
      textField.text = ""
      return false
      
    } else if ((textField.text?.count)! >= 1) {
      
      textField.text = string
      return false
    }
    
    return true
  }
}
// MARK: - Backspace Tracing Delegate
extension OtpVC: BackspaceTextFieldDelegate {
  func textFieldDidEnterBackspace(_ textField: BackspaceTextField) {
    guard let index = textFields.firstIndex(of: textField) else {
      return
    }
    
    if index > 0 {
      textFields[index - 1].becomeFirstResponder()
    } else {
      view.endEditing(true)
    }
  }
}

class BackspaceTextField: UITextField {
  weak var backspaceTextFieldDelegate: BackspaceTextFieldDelegate?
  
  override func deleteBackward() {
    if text?.isEmpty ?? false {
      backspaceTextFieldDelegate?.textFieldDidEnterBackspace(self)
    }
    
    super.deleteBackward()
  }
}

extension OtpVC {
// MARK: API Function To verify User Mobile Number
func apiMobileVerified(_ verified:Bool) {
    let param: [String: Any] = ["is_mobile_verified": verified]
    if let getRequest = API.MOBILEVERIFIED.request(method: .post, with: param, forJsonEncoding: true) {
      Global.showLoadingSpinner()
      getRequest.responseJSON { response in
        Global.dismissLoadingSpinner()
        API.MOBILEVERIFIED.validatedResponse(response, completionHandler: { (jsonObject, error) in
          guard error == nil else {
            return
          }
          guard let getData = jsonObject?["data"] as? [String: Any] else {
            return
          }
          print(getData)
          MemberModel.storeMemberModel(value: getData)
          Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
          if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
              sd.isUserLogin(true)
            }
          } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.isUserLogin(true)
          }
        })
      }
    }
  }
  // MARK: APi Registration
  func apiRegistration() {
      Global.showLoadingSpinner()
      if let getRequest = API.SIGNUP.request(method: .post, with: registrationParam, forJsonEncoding: true) {
        Global.showLoadingSpinner()
        getRequest.responseJSON { response in
            Global.dismissLoadingSpinner()
            API.SIGNUP.validatedResponse(response, completionHandler: { (jsonObject, error) in
                guard error == nil else {
                    return
                }
                guard let getData = jsonObject?["data"] as? [String: Any], let userData = getData["user"] as? [String: Any] else {
                    return
                }
                Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
                UserDefaults.standard.set(getData["token"], forKey: "headerToken")
                guard userData["is_mobile_verified"] as? Bool == true else {
                  self.apiMobileVerified(true)
                 return
                }
                if #available(iOS 13.0, *) {
                    let scene = UIApplication.shared.connectedScenes.first
                    if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                        sd.isUserLogin(true)
                    }
                } else {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.isUserLogin(true)
                }
            })
        }
    }
  }
}




