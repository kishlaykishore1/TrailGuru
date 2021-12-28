
import UIKit

class DashedBorderView: UIControl {
    
    let _border = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    func setup() {
        _border.strokeColor = #colorLiteral(red: 0.5058823529, green: 0.462745098, blue: 0.1411764706, alpha: 1)
        _border.fillColor = nil
        _border.lineDashPattern = [4, 4]
        self.layer.addSublayer(_border)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _border.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 6).cgPath
        _border.frame = self.bounds
    }
}
