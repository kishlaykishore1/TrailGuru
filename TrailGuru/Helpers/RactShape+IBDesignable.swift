
import UIKit

@IBDesignable
class ShapeBgView: UIView {
    var path: UIBezierPath!
    @IBInspectable public var gradFirstColor: UIColor = #colorLiteral(red: 0.1803921569, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
    @IBInspectable public var gradSecondColor: UIColor = #colorLiteral(red: 0.462745098, green: 0.2352941176, blue: 0.9333333333, alpha: 1)
    override func draw(_ rect: CGRect) {
        self.createRectShape()
        let gradient = getGradientLayer(withColours: [gradFirstColor, gradSecondColor], gradientOrientation: .topLeftBottomRight)
        gradient.frame = path.bounds
        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath
        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)
        
    }
    func createRectShape() {
        // Initialize the path.
        path = UIBezierPath()
        
        // Specify the point that the path should start get drawn.
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        
        // Create a line between the starting point and the bottom-left side of the view.
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height/2.3))
        
        // Create the bottom line (bottom-left to bottom-right).
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height/2.9))
        
        // Create the vertical line from the bottom-right to the top-right side.
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))
        
        // Close the path. This will create the last line automatically.
        path.close()
    }
}
