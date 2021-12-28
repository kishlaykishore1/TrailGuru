
import UIKit

class Global {
    
    public class func showAlert(withMessage : String, sender : UIViewController? = UIApplication.topViewController(), handler: ((_ okPressed:Bool) -> Void)? = nil) {
        
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: withMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay".localized, style: .default) { (ok) in
            handler?(true)
        }
        alertController.addAction(okAction)
        sender?.present(alertController, animated: true, completion: nil)
    }
    
    public class func showAlert(message:String,okTitle:String,cancelTitle:String?,sender : UIViewController? = UIApplication.topViewController(),handler:@escaping (_ okPressed:Bool)->()){
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okTitle, style: .default) { (ok) in
            handler(true)
        }
        alertController.addAction(okAction)
        if let cancelTitle = cancelTitle{
            let cancelOption = UIAlertAction(title: cancelTitle, style: .default, handler: { (axn) in
                alertController.dismiss(animated: true, completion: nil)
                
            })
            alertController.addAction(cancelOption)
        }
        
        sender?.present(alertController, animated: true, completion: nil)
    }
    
    public class func getInt(for value : Any?) -> Int? {
        
        if let stateCode = value as? String {
            return Int(stateCode)
            
        }else if let stateCodeInt = value as? Int {
            return stateCodeInt
            
        }
        return nil
        
    }
    
    public class func stringifyJson(_ value: Any, prettyPrinted: Bool = true) -> String! {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : nil
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options!)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }  catch {
                return ""
            }
        }
        return ""
    }
    
    public class func makeCall(for number : String){
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    public class func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
    public class func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
        
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        
    }
    
    public class func getStringFrom(seconds: Int) -> String {
        
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    public class var currentLanguge : String {
        return Bundle.main.preferredLocalizations[0] as String
    }
}

extension Global {
    
    public static func openURL(_ url: String) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    public func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
        let age = calcAge.year
        return age!
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
