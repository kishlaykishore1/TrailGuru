

import Foundation
import UIKit

class Validation {
    
    static func isBlank(for text: String?) -> Bool {
        return text?.trim().count == 0
    }
    
    static func isValidSiretNo(for no: String) -> Bool {
        return no.trim().replacingOccurrences(of: " ", with: "").count >= 14
    }
    
    static func isValidNumber(for no: String) -> Bool {
        let pattern = "^[A-Z]{2}[ -][0-9]{1,2}(?: [A-Z])?(?: [A-Z]*)? [0-9]{4}$"
        let noTest = NSPredicate(format:"SELF MATCHES %@", pattern)
        return noTest.evaluate(with: no.trim())
    }
    
    static func isValidEmail(for email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email.trim())
    }
    
    static func isValidPassword(for password: String) -> Bool {
        return password.trim().count > 7
    }
    
    static func isPasswordMatched(for password: String, for rePassword: String) -> Bool {
        return password.trim() == rePassword.trim()
    }
    
    static func isValidDate(dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.locale = Locale(identifier: "fr")
        if let _ = dateFormatter.date(from: dateString) {
            return true
        } else {
            return false
        }
    }
    
   static func isValidMobileNumber(value: String) -> Bool {
    let PHONE_REGEX = "^[0-9]{6,14}$"
    let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
    let result =  phoneTest.evaluate(with: value.trim())
    return result
    }
}
