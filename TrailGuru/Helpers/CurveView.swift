
import UIKit

class TopView: UIView {
    
   @IBInspectable public var curveColor: UIColor = .white
    
    override func draw(_ rect: CGRect) {
        
        let y:CGFloat = 20
        let curveTo:CGFloat = 100
        self.backgroundColor = .white
        let shadowOffset = CGSize.init(width: 0, height: -3.3)
        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x: 0, y: y))
        myBezier.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: curveTo))
        myBezier.addLine(to: CGPoint(x: rect.width, y: rect.height))
        myBezier.addLine(to: CGPoint(x: 0, y: rect.height))
        
        myBezier.close()
        let context = UIGraphicsGetCurrentContext()
        let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        context!.setShadow(offset: shadowOffset, blur: 25, color: shadowColor.cgColor)
        context!.setLineWidth(50.0)
        curveColor.setFill()
        myBezier.fill()
        let degrees : Double = 180;
        self.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/180))
        self.clipsToBounds = true
        self.backgroundColor = .clear
        self.layoutIfNeeded()
    }
}


class BottomView: UIView {
    
    @IBInspectable public var curveColor: UIColor = .white
    
    override func draw(_ rect: CGRect) {
        
        let y:CGFloat = 20
        let curveTo:CGFloat = 100
        self.backgroundColor = .white

        let shadowOffset = CGSize.init(width: 0, height: -3.3)
        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x: 0, y: y))
        myBezier.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: curveTo))
        myBezier.addLine(to: CGPoint(x: rect.width, y: rect.height))
        myBezier.addLine(to: CGPoint(x: 0, y: rect.height))
        
        myBezier.close()
        let context = UIGraphicsGetCurrentContext()
        let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        context!.setShadow(offset: shadowOffset, blur: 25, color: shadowColor.cgColor)
        context!.setLineWidth(50.0)
        curveColor.setFill()
        myBezier.fill()
        self.clipsToBounds = true
        self.backgroundColor = .clear
        self.layoutIfNeeded()
    }
}
