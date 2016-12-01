/*
 * Download Button
 */

import UIKit
import Cartography

protocol DownloadButtonDelegate: class {
    func downloadButtonWasClicked(_ sender: UIButton)
}

class DownloadButton: UIButton {
    
    var delegate: DownloadButtonDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        setImage(UIImage(named: "Download"), for: UIControlState())
        addTarget(self, action: #selector(downloadButtonWasClicked), for: .touchUpInside)
        setupAutoLayout()
    }
    
    func setupAutoLayout() {
        constrain(self) { (view) in
            view.width == Layout.DownloadButton.Width
            view.height == Layout.DownloadButton.Height
        }
    }
    
    func downloadButtonWasClicked() {
        delegate?.downloadButtonWasClicked(self)
    }
    
}
