/**
 * Media File Name Label
 */

import UIKit
import Cartography

private let WidthAndHeight = CGFloat(24)

class MediaFileNameLabel: UILabel {
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        font = UIFont.boldSystemFont(ofSize: 20)
        textColor = UIColor.white
        //adjustsFontSizeToFitWidth = true
        //minimumScaleFactor = (16/20)
    }
    
    func setupAutoLayout() {
        constrain(self) { (view) in
            view.height == WidthAndHeight
            view.width == WidthAndHeight
        }
    }
    
}
