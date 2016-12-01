/*
 * C: MediaDurationLabel
 */

import UIKit
import Cartography

class MediaDurationLabel: UILabel {
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        setupView()
        setupAutoLayout()
    }
    
    func setupView() {
        font = UIFont.boldSystemFont(ofSize: 20)
        textColor = UIColor.white
    }
    
    func setupAutoLayout() {
        constrain(self) { (view) in
            view.height == Layout.MediaFileNameLabel.Height
        }
    }
}
