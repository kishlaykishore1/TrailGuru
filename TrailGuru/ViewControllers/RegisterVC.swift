//
//  RegisterVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 17/02/21.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfMobileNumber: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Inter-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        
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
    
    // MARK: Button Signup Action
    @IBAction func btnSignup_Action(_ sender: UIButton) {
      if Validation.isBlank(for: tfName.text ?? "") {
          Common.showAlertMessage(message: Messages.emptyName, alertType: .error)
          return
      } else if !Validation.isValidEmail(for: tfEmail.text ?? "") {
          Common.showAlertMessage(message: Messages.emptyEmail, alertType: .error)
          return
      } else if !Validation.isValidMobileNumber(value: tfMobileNumber.text ?? "") {
          Common.showAlertMessage(message: Messages.emptyPhone, alertType: .error)
          return
      } else if !Validation.isPasswordMatched(for: tfPassword.text ?? "", for: tfConfirmPassword.text ?? "") {
          Common.showAlertMessage(message: Messages.passwordNotMatched, alertType: .error)
          return
      }
      verifyPhoneNO()
    }
    // MARK: Button Login Action
    @IBAction func btnLogin_Action(_ sender: UIButton) {
        let loginVC = StoryBoard.Main.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}

extension RegisterVC {
  // MARK: Function Verify Phone
  func verifyPhoneNO() {
    let param: [String: Any] = ["username": tfName.text!.trim(),"mobile": tfMobileNumber.text!.trim(),"email":tfEmail.text!.trim(),"password":tfPassword.text!.trim(),"confirm_password":tfConfirmPassword.text!.trim(),"device_token":Constants.UDID]
    PhoneAuthProvider.provider().verifyPhoneNumber("+1\(tfMobileNumber.text!.trim())", uiDelegate: nil) { (verificationID, error) in
          if error != nil {
              Common.showAlertMessage(message: Messages.validPhoneNo, alertType: .error)
              return
          }
      let otpVc = StoryBoard.Main.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
      otpVc.verificationID = verificationID ?? ""
      otpVc.mobileNo = "+1\(self.tfMobileNumber.text!.trim())"
      otpVc.navString = "Register"
      otpVc.registrationParam = param
      self.navigationController?.pushViewController(otpVc, animated: true)
      }
      return
  }
}


