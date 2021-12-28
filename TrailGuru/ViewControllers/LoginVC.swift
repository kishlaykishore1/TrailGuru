//
//  LoginVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 17/02/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
class LoginVC: UIViewController {
  
  @IBOutlet weak var tfEmail: UITextField!
  @IBOutlet weak var tfPassword: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if !UserDefaults.standard.bool(forKey: "POLICYSCREEN") {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let policyScreen = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
      guard let getNav =  UIApplication.topViewController()?.navigationController else {
        return
      }
      let rootNavView = UINavigationController(rootViewController: policyScreen)
      
      if #available(iOS 13.0, *) {
        policyScreen.isModalInPresentation = true
        rootNavView.modalPresentationStyle = .fullScreen
      } else {
        // Fallback on earlier versions
      }
      getNav.present(rootNavView, animated: true, completion: nil)
    }
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.isNavigationBarHidden = true
  }
  
  // MARK: Button Login Action
  @IBAction func btnLogin_Action(_ sender: UIButton) {
    if Validation.isBlank(for: tfEmail.text ?? "") {
      Common.showAlertMessage(message: Messages.emptyEmail, alertType: .error)
      return
    } else if Validation.isBlank(for: tfPassword.text ?? "") {
      Common.showAlertMessage(message: Messages.emptyPassword, alertType: .error)
      return
    }
    apiUserLogin()
  }
  // MARK: Button Google Login Action
  @IBAction func btnGoogleLogin(_ sender: UIButton) {
    Global.showLoadingSpinner()
    GIDSignIn.sharedInstance()?.presentingViewController = self
    GIDSignIn.sharedInstance().signIn()
  }
  // MARK: Button Facebook Login Action
  @IBAction func btnFacebookLogin(_ sender: UIButton) {
    facebookLogin()
  }
  // MARK: Button Apple Login Action
  @IBAction func btnAppleLogin(_ sender: UIButton) {
    if #available(iOS 13.0, *) {
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    } else {
      let alert = UIAlertController(title: Messages.txtDeleteAlert, message: Messages.txtAppleSignInMes, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: Messages.txtDissmiss, style: .cancel, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
  // MARK: Button Register Action
  @IBAction func btnRegister(_ sender: UIButton) {
    let registerVC = StoryBoard.Main.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
    self.navigationController?.pushViewController(registerVC, animated: true)
  }
  // MARK: Button Forget Password Action
  @IBAction func btnForgetPassword(_ sender: UIButton) {
    let forgetPassVC = StoryBoard.Main.instantiateViewController(withIdentifier: "ForgetPasswordVC") as! ForgetPasswordVC
    self.navigationController?.pushViewController(forgetPassVC, animated: true)
  }
  
  func verifyPhoneNO(phoneNo:String) {
    PhoneAuthProvider.provider().verifyPhoneNumber("\(phoneNo)", uiDelegate: nil) { (verificationID, error) in
      if error != nil {
        Common.showAlertMessage(message: Messages.validPhoneNo, alertType: .error)
        return
      }
      let otpVc = StoryBoard.Main.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
      otpVc.verificationID = verificationID ?? ""
      otpVc.mobileNo = phoneNo
      otpVc.navString = "Login"
      self.navigationController?.pushViewController(otpVc, animated: true)
    }
    return
  }
}

// MARK: - API Calling
extension LoginVC {
  func apiUserLogin() {
    let param: [String : Any] = ["email": tfEmail.text!.trim(),"password": tfPassword.text!.trim(),"device_token": Constants.UDID]
    if let getRequest = API.LOGIN.request(method: .post, with: param, forJsonEncoding: true) {
      Global.showLoadingSpinner()
      getRequest.responseJSON { response in
        Global.dismissLoadingSpinner()
        API.LOGIN.validatedResponse(response, completionHandler: { (jsonObject, error) in
          guard error == nil else {
            return
          }
          guard let getData = jsonObject?["data"] as? [String: Any], let userData = getData["user"] as? [String: Any] else {
            return
          }
          Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
          UserDefaults.standard.set(getData["token"], forKey: "headerToken")
          guard (userData["is_mobile_verified"] as? Bool ?? false) else {
            self.verifyPhoneNO(phoneNo: userData["mobile"] as? String ?? "")
            return
          }
          MemberModel.storeMemberModel(value: userData)
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
  
  // MARK: Social Login Api Setup
  func apiSocialLogin(sID: String,Image: String,loginBy: String) {
    let param: [String : Any] = ["social_id":sID,"avatar":Image,"login_by": loginBy,"device_token": Constants.UDID]
    if let getRequest = API.SOCIALLOGIN.request(method: .post, with: param, forJsonEncoding: true) {
      Global.showLoadingSpinner()
      getRequest.responseJSON { response in
        Global.dismissLoadingSpinner()
        API.SOCIALLOGIN.validatedResponse(response, completionHandler: { (jsonObject, error) in
          guard error == nil else {
            return
          }
          guard let getData = jsonObject?["data"] as? [String: Any], let userData = getData["user"] as? [String: Any] else {
            return
          }
          Common.showAlertMessage(message: jsonObject?["message"] as? String ?? "", alertType: .success)
          UserDefaults.standard.set(getData["token"], forKey: "headerToken")
//          guard (userData["is_mobile_verified"] as? Bool ?? false) else {
//            self.verifyPhoneNO(phoneNo: userData["mobile"] as? String ?? "")
//            return
//          }
          MemberModel.storeMemberModel(value: userData)
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

// MARK: - Login With Google
extension LoginVC : GIDSignInDelegate {
  // MARK: Google sign In
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
    Global.dismissLoadingSpinner()
    if error != nil {
      return
    }
    let userId = user.userID ?? ""
    let givenName = user.profile.givenName ?? ""
    let familyName = user.profile.familyName ?? ""
    let email = user.profile.email ?? ""
    let url = "\(user.profile.imageURL(withDimension: 200)!)"
    print(userId)
    print(givenName)
    print(familyName)
    print(email)
    print(url)
    self.apiSocialLogin(sID: userId, Image: url, loginBy: "google")
    GIDSignIn.sharedInstance()?.signOut()
  }
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    
  }
}
// MARK: - Apple SignIn Delegate
extension LoginVC: ASAuthorizationControllerDelegate {
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      let userIdentifier = appleIDCredential.user
      let fullName = appleIDCredential.fullName
      let email = appleIDCredential.email
      print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
      self.apiSocialLogin(sID: userIdentifier, Image: "", loginBy: "apple")
    }
  }
  // Authorization Failed
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print(error.localizedDescription)
  }
}

// MARK: -  For present window Apple Sign In
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
  }
}
//MARK:- FaceBook Login
extension LoginVC {
  //Social login
  private func facebookLogin() {
    if let accessToken = AccessToken.current {
      print("Facebook User Access Token: \(accessToken)")
      self.getFBUserData()
    }
    if AccessToken.current == nil {
      LoginManager().logIn(permissions: ["email"], from: self) { (result, error) -> Void in
        if (error == nil) {
          let fbloginresult : LoginManagerLoginResult = result!
          // if user cancel the login
          if (result?.isCancelled) ?? false {
            print("Facebook User Cancelled")
            return
          }
          if(fbloginresult.grantedPermissions.contains("email")) {
            self.getFBUserData()
            print(AccessToken.current!.tokenString as Any)
          }
        }
      }
    }
  }
  private func getFBUserData() {
    if((AccessToken.current) != nil) {
      Global.showLoadingSpinner()
      GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, response, error) -> Void in
        Global.dismissLoadingSpinner()
        if (error == nil) {
          print(response as Any)
          if let result = response as? [String : Any] {
            print(result)
            let email = result["email"] as? String ?? ""
            let firstName = result["first_name"] as? String ?? ""
            let id = result["id"] as? String ?? ""
            let lastName = result["last_name"] as? String ?? ""
            let picture = result["picture"] as? [String: Any]
            let data = picture?["data"] as? [String: Any]
            let imageUrl = data?["url"] as? String ?? ""
            print(email)
            print(firstName)
            print(lastName)
            print(id)
            print(imageUrl)
            //Api call login
            self.apiSocialLogin(sID: id, Image: imageUrl, loginBy: "facebook")
            LoginManager().logOut()
          }
        }
      })
    }
  }
}
