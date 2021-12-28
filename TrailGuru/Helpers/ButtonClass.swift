import UIKit

//
//MARK: LEFT BUTTON CORNER RADIUS
//
class LeftButton : UIButton {

    override public func layoutSubviews() {
        super.layoutSubviews()
        roundCorners([.topLeft, .topRight, .bottomRight], radius: 15.0)
    }
}

//
//MARK: RIGHT BUTTON CORNER RADIUS
//
class RightButton : UIButton {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        roundCorners([.topLeft, .topRight, .bottomLeft], radius: 15.0)
    }
}

//
//MARK: RIGHT BUTTON CORNER RADIUS
//
class LeftRightButton : UIButton {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        roundCorners([.bottomLeft, .bottomRight], radius: 10.0)
    }
}

//
//MARK: LEFT BOTTOM LABEL CORNER RADIUS
//
class LeftBottomLabel : UILabel{
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        roundCorners([.bottomLeft], radius: 10.0)
    }
}

//
//MARK: LEFT BOTTOM LABEL CORNER RADIUS
//
class LeftBottomTopRightRadius : UILabel{
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        roundCorners([.topRight,.bottomLeft], radius: 10.0)
    }
}

//
//MARK: UnderlineText of Button Title
//
class UnderlineTextButton: UIButton {
   let fontStyle = UIFont.init(name: "GothamRounded-Medium", size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
   let textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: .normal)
        self.setAttributedTitle(self.attributedString(), for: .normal)
    }
    private func attributedString() -> NSAttributedString? {
        let attributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font :fontStyle,
            NSAttributedString.Key.foregroundColor : textColor,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue
        ]
        let attributedString = NSAttributedString(string: self.currentTitle!, attributes: attributes)
        return attributedString
    }
}

class ButtonWithRightImage: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: (bounds.width - 32), bottom: 0, right: 16)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)! + 24)
            imageView?.contentMode = .scaleAspectFit
        }
    }
}

open class CustomSlider : UISlider {
    @IBInspectable open var trackWidth:CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }

    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
}
