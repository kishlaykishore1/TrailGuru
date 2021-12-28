//
//  UITextfield.swift
//

import UIKit.UITextField
private var __maxLengths = [UITextField: Int]()
extension UITextField {
    
    /// set icon of 20x20 with left padding of 8px
    func setLeftMargin(_ icon: UIImage? = nil, padding: Int = 8) {

        let size = 0
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        if let icon = icon {
         let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: 50, height: 30))
         iconView.image = icon
         outerView.addSubview(iconView)
        }
        leftView = outerView
        leftViewMode = .always
    }
    
    //MARK:- Perfect text field Left image 
    func addLeftImageTo(txtField: UITextField, andImage img: UIImage){
        let leftImageView = UIImageView(frame: CGRect(x: 5, y: 1, width: img.size.width, height: img.size.height))
        leftImageView.image = img
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 0, y: 0, width: 30, height: 30))
        // iconContainerView.backgroundColor = UIColor(rgb: 0xCD5C5C)
        iconContainerView.addSubview(leftImageView)
        txtField.leftView = iconContainerView
        txtField.leftViewMode = .always
    }
    
    //MARK:- Perfect text field Left And Right image
       func addImageTo(txtField: UITextField, andImage img: UIImage, isLeft: Bool = true) {
           if isLeft {
               let leftImageView = UIImageView(frame: CGRect(x: 5, y: 3, width: img.size.width, height: img.size.height))
               leftImageView.image = img
               let iconContainerView: UIView = UIView(frame:
                   CGRect(x: 0 , y: 0, width: 30, height: 28))
               iconContainerView.addSubview(leftImageView)
               txtField.leftView = iconContainerView
               txtField.leftViewMode = .always
           } else {
               let leftImageView = UIImageView(frame: CGRect(x: 5, y: 14, width: img.size.width, height: img.size.height))
               leftImageView.image = img
               let iconContainerView: UIView = UIView(frame:
                   CGRect(x: 0, y: 0, width: 30, height: 30))
               iconContainerView.addSubview(leftImageView)
               txtField.rightView = iconContainerView
               txtField.rightViewMode = .always
           }
       }
    
}

extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
}

extension String
{
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}

//textfield padding

extension UITextField
{
    func setPadding(left: CGFloat? = nil){
        if let left = left {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
    }
}
