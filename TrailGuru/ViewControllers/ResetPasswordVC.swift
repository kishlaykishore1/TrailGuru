//
//  ResetPasswordVC.swift
//  TrailGuru
//
//  Created by kishlay kishore on 03/03/21.
//

import UIKit

class ResetPasswordVC: UIViewController {

  @IBOutlet weak var tfConfirmPass: UITextField!
  @IBOutlet weak var tfPassword: UITextField!
  
  var user_id:Int?
  
  override func viewDidLoad() {
      super.viewDidLoad()
      self.title = "Reset Password"
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
  // MARK: Reset button Action
  @IBAction func btnReset_Action(_ sender: UIButton) {
    if !Validation.isPasswordMatched(for: tfPassword.text ?? "", for: tfConfirmPass.text ?? "") {
        Common.showAlertMessage(message: Messages.passwordNotMatched, alertType: .error)
        return
    }
    self.apiResetPassword()
  }
}

extension ResetPasswordVC {
  // MARK: API Function To Reset Password
  func apiResetPassword() {
    let param: [String: Any] = ["user_id": user_id ?? 0,"password":tfPassword.text!.trim(),"confirm_password":tfConfirmPass.text!.trim()]
      if let getRequest = API.RESETPASS.request(method: .post, with: param, forJsonEncoding: true) {
        Global.showLoadingSpinner()
        getRequest.responseJSON { response in
          Global.dismissLoadingSpinner()
          API.RESETPASS.validatedResponse(response, completionHandler: { (jsonObject, error) in
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
}
