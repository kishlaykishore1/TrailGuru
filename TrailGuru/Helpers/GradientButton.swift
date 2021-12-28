
import UIKit

@IBDesignable
class GradientTextButton: UIButton {
    @IBInspectable
    open var gradientfirst: UIColor? {
        didSet {
            updateGradientTextColor()
        }
    }
    @IBInspectable
    open var gradientSecond: UIColor? {
        didSet {
            updateGradientTextColor()
        }
    }
    
    func updateGradientTextColor() {
        guard
            let c1 = gradientfirst,
            let c2 = gradientSecond else { return }
        
        // Create size of intrinsic size for the label with current text.
        // Otherwise the gradient textColor will repeat when text is changed.
        let size = CGSize(width: intrinsicContentSize.width, height: 1)
        
        // Begin image context
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        // Always remember to close the image context when leaving
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Create the gradient
        let colors = [c1.cgColor, c2.cgColor]
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: nil
            ) else { return }
        
        // Draw the gradient in image context
        context.drawLinearGradient(
            gradient,
            start: CGPoint.zero,
            end: CGPoint(x: size.width, y: 0), // Horizontal gradient
            options: []
        )
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            // Set the textColor to the new created gradient color
            
            self.setTitleColor(UIColor(patternImage: image), for: .normal)
            // self.titleLabel?.textColor =
        }
        
    }
}
