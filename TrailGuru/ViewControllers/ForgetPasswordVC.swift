//
//  ForgetPasswordVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 17/02/21.
//

import UIKit
import FirebaseAuth
import Firebase
class ForgetPasswordVC: UIViewController {
    
    @IBOutlet weak var tfMobileNumber: UITextField!
    
    var forgetPassData:ForgetPassModel?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Forget Password"
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
    
    // MARK: Next button Action
    @IBAction func btnNext_Action(_ sender: UIButton) {
      if Validation.isBlank(for: tfMobileNumber.text ?? "") {
          Common.showAlertMessage(message: Messages.emptyPhone, alertType: .error)
          return
      }
      apiForgetPass()
        let purchasemapvc = StoryBoard.Main.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
        self.navigationController?.pushViewController(purchasemapvc, animated: true)
    }

}
extension ForgetPasswordVC {
  // MARK: APi for Forget Pass
  func apiForgetPass() {
    let param: [String: Any] = ["mobile": tfMobileNumber.text!.trim()]
      if let getRequest = API.FORGETPASS.request(method: .post, with: param, forJsonEncoding: true) {
        Global.showLoadingSpinner()
        getRequest.responseJSON { response in
          Global.dismissLoadingSpinner()
          API.FORGETPASS.validatedResponse(response, completionHandler: { (jsonObject, error) in
            guard error == nil else {
              return
            }
            guard let getData = jsonObject?["data"] as? [String: Any] else {
              return
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: getData, options: .prettyPrinted)
                let decoder = JSONDecoder()
                self.forgetPassData = try decoder.decode(ForgetPassModel.self, from: jsonData)
            } catch let err {
                print("Err", err)
            }
            Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
            self.verifyPhoneNO()
          })
        }
      }
    }
  
  // MARK: Function Verify Phone
  func verifyPhoneNO() {
    PhoneAuthProvider.provider().verifyPhoneNumber("+1\(tfMobileNumber.text!.trim())", uiDelegate: nil) { (verificationID, error) in
          if error != nil {
              Common.showAlertMessage(message: Messages.validPhoneNo, alertType: .error)
              return
          }
      let otpVc = StoryBoard.Main.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
      otpVc.verificationID = verificationID ?? ""
      otpVc.user_id = self.forgetPassData?.userID
      otpVc.navString = "ForgetPass"
      self.navigationController?.pushViewController(otpVc, animated: true)
      }
      return
  }
}
