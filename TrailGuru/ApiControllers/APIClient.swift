import UIKit
import Alamofire
import SystemConfiguration


//MARK: Reachability

open class Reachability {
  
  class func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
        SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
      }
    }
    var flags: SCNetworkReachabilityFlags = []
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
      return false
    }
    let isReachable     = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection) ? true : false
  }
}

enum API: String {
  var baseURL: String {
    return Constants.apiMainURL
  }
  
  var apiURL: String {
    return "\(baseURL)/"
  }
  
  /**
   When Update Api Version Please Update.
   - 'API_VERSION' on 'Constants.swift'
   */
  
  var encoding: ParameterEncoding {
    switch self {
    case .STATIC:
      return JSONEncoding.default
    default:
      return URLEncoding.default
    }
  }
  
  var method: Alamofire.HTTPMethod {
    switch self {
    case .STATIC:
      return .get
    default:
      return .post
    }
  }
  
  case STATIC                             = ""
  case UPDATEPROFILE                      = "api/update-profile"
  case SOCIALLOGIN                        = "api/social_login"
  case SIGNUP                             = "api/register"
  case LOGIN                              = "api/login"
  case MYPROFILE                          = "api/profile"
  case LOGOUT                             = "api/logout"
  case MOBILEVERIFIED                     = "api/mobile_verified"
  case FORGETPASS                         = "api/forgot"
  case RESETPASS                          = "api/reset_password"
  case MAPUPDATE                          = "api/map_update_status"
  case MAPLISTING                         = "api/map_list"
  
  
  static let alamofireManager: Session = {
    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.timeoutIntervalForRequest = 1000
    return Session(configuration: sessionConfiguration, startRequestsImmediately: true)
  }()
  
  func request(method: Alamofire.HTTPMethod = .post, with parameters: [String : Any]?, forJsonEncoding: Bool = false) -> Alamofire.DataRequest! {
    if !Reachability.isConnectedToNetwork() {
      Global.showAlert(withMessage:ConstantsMessages.kConnectionFailed)
      return nil
    } else {
      return API.alamofireManager.request(apiURL + self.rawValue, method: method, parameters: parameters, headers: ApiHeaders.defaultHeaders())
    }
  }
  
  
  func requestUpload(with parameters: [String: Any]? = nil, files: [String: Any]? = nil , completionHandler:((_ jsonObject: [String: Any]?, _ error: Error?) -> Void)?) {
    AF.upload(multipartFormData: { multipartFormData in
      if let files = files {
        for (key, value) in files {
          if let getImage = value as? UIImage {
            let imageData = getImage.jpegData(compressionQuality: 0.5)
            multipartFormData.append(imageData!, withName: key, fileName: "\(key).jpg", mimeType: "image/jpg")
            print("\(key).jpg")
          } else if let getAudioUrl = value as? Data {
            multipartFormData.append(getAudioUrl, withName: key, fileName: "\(key).m4a", mimeType: "audio/m4a")
          }
        }
      }
      for (key, value) in parameters ?? [:]  {
        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
      }
    }, to: apiURL + self.rawValue , method: .post , headers: ApiHeaders.defaultHeaders()).responseJSON { (responseJSON) in
      switch responseJSON.result {
      case.success(let json) :
        print(json)
        if let res = json as? [String: Any] {
          completionHandler!(res,nil)
        }
      case.failure(let error) :
        print(error)
        completionHandler!(nil,error)
      }
    }
  }
  
  func validatedResponse(_ response: AFDataResponse<Any>, completionHandler:((_ jsonObject: [String:Any]?, _ error:Error?) ->Void)?) {
    if let data = response.data {
      _ = String.init(data: data, encoding: String.Encoding.utf8)
    }
    switch response.result {
    case .success(let JSON):
      print("API NAME ********* \(self.rawValue)")
      print("Success with JSON: \(JSON)")
      let response = JSON as! [String: Any]
      //let status = Global.getInt(for: response["status"] ?? 0)
      //  let status = Global.getInt(for: response["success"] ?? 0)
      let status = response["success"] as? Bool ?? false
      let getMessage = response["message"] as? String ?? ""
      // Successfully recieve response from server
      switch self {
      case .STATIC:
        completionHandler!(response, nil)
        
      default:
        
        if status { /*------- Success -----------*/
          completionHandler!(response, nil)
        } else {
          completionHandler!(nil, NSError(domain: Constants.kAppDisplayName, code: 402, userInfo:nil))
          Common.showAlertMessage(message: getMessage, alertType: .error)
        }
      }
      
    case .failure(let error):
      
      print("Request failed with error: \(error)")
      
      // recieve response from server
      switch self {
      case .STATIC:
        Global.showAlert(withMessage:ConstantsMessages.kSomethingWrong)
        completionHandler!(nil, error as NSError?)
      default:
        if let data = response.data {
          Common.showAlertMessage(message: ConstantsMessages.kNetworkFailure, alertType: .error)
          
          let responceData = String(data: data, encoding:String.Encoding.utf8)!
          print("**** SerializationFailed\n\(responceData) \n ****")
          completionHandler!(nil, error as NSError?)
        } else {
          Common.showAlertMessage(message: ConstantsMessages.kNetworkFailure, alertType: .error)
          completionHandler!(nil, error as NSError?)
        }
      }
    }
  }
}


