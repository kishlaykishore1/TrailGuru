import UIKit

class Constants {
    
    static let kAppDelegate          = UIApplication.shared.delegate as! AppDelegate
    static let kScreenWidth          = UIScreen.main.bounds.width
    static let kScreenHeight         = UIScreen.main.bounds.height
    static let kAppDisplayName       = UIApplication.appName
    static let kUserDefaults         = UserDefaults.standard
    static var kTest                 = 1
    static var optionColor           = "#EEFEEF7"
    static var UDID                  = UIDevice.current.identifierForVendor?.uuidString ?? ""
    static var KBundleID             = Bundle.main.bundleIdentifier
    static var apiMainURL            = "http://trailguru.jdcomp1.com"
     //"http://trailguru.jdcomp1.com/trail_demo"
    //http://trailguru.jdcomp1.com/api/
}

// MARK: - Failed Errors
public struct ConstantsErrors {
    
    static let kNoInternetConnection = NSError(domain: Constants.kAppDisplayName, code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: ConstantsMessages.kConnectionFailed])
    
    static let kSomethingWrong = NSError(domain: Constants.kAppDisplayName, code: 1000002, userInfo: [NSLocalizedDescriptionKey : Messages.somethingWentWrong])
}

public struct ConstantsMessages {
    
    static let kConnectionFailed = NSLocalizedString(Messages.ProblemWithInternet, comment : Messages.NetworkError)
    static let kNetworkFailure = NSLocalizedString(Messages.seemsNetworkError, comment : Messages.NetworkError)
    static let kSomethingWrong = NSLocalizedString(Messages.somethingWentWrong, comment : Messages.NetworkError)
}
public func getLanguage() -> String {
    switch Locale.current.languageCode {
    case "fr":
        return "fr"
    case "de":
        return "de"
    case "es":
        return "es"
    default:
        return "en"
    }
}
public func convertDateFormater(_ date: String, _ formatFrom: String = "", _ format: String = "dd-MM-yyyy") -> String {
    let dateFormatter = DateFormatter()
    if formatFrom == "" {
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
    } else {
        dateFormatter.dateFormat = formatFrom
    }
    dateFormatter.locale = Locale(identifier: getLanguage())
    let date = dateFormatter.date(from: date)
    dateFormatter.dateFormat = format
    return  dateFormatter.string(from: date!)
}
