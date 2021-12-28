
import UIKit

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case bottomLeftTopRight
    case bottomRightTopLeft
    case horizontal
    case vertical
    case right
    case left
    case top
    case bottom
    
    var startPoint : CGPoint {
        return points.startPoint
    }
    
    var endPoint : CGPoint {
        return points.endPoint
    }
    
    var points : GradientPoints {
        get {
            switch(self) {
            case .topRightBottomLeft:
                return (CGPoint(x: 1.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
            case .topLeftBottomRight:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 1.0,y: 1.0))
            case .bottomLeftTopRight:
                return (CGPoint(x: 0.0,y: 1.0), CGPoint(x: 1.0,y: 0.0))
            case .bottomRightTopLeft:
                return (CGPoint(x: 1.0,y: 1.0), CGPoint(x: 0.0,y: 0.0))
            case .horizontal:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            case .vertical:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
            case .top:
                return (CGPoint(x: 0.5,y: 1.0), CGPoint(x: 0.5,y: 0.0))
            case .left:
                return (CGPoint(x: 1.0,y: 0.5), CGPoint(x: 0.0,y: 0.5))
            case .bottom:
                return (CGPoint(x: 0.5,y: 0.0), CGPoint(x: 0.5,y: 1.0))
            case .right:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            }
            
        }
    }
}

extension UIView {
    
    func applyGradient(withColours colours: [UIColor], locations: [NSNumber]? = nil) -> Void {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func getGradientLayer(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        return gradient
    }
    
    func applyGradient(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) -> Void {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    func applyGradientWithShadow(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation, shadowColor: UIColor, radius: CGFloat, opacity: Float, offset: CGSize, shadowRadius: CGFloat) -> Void {
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        
        // Shadow
        gradient.shadowOffset = offset
        gradient.shadowColor = shadowColor.cgColor
        gradient.shadowOpacity = opacity
        gradient.shadowRadius = 10
        
        // Radius
        gradient.cornerRadius = radius
        
        self.layer.insertSublayer(gradient, at: 0)
    }
}



