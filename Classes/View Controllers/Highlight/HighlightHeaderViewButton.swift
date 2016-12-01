
/**
 
 HighlightHeaderViewButton.swift
 
 Created by Sharkey, Justin (ELS-CON) on 12/7/15.
 Copyright © 2015 Elsevier, Inc. All rights reserved.

 */

import UIKit

class HighLightHeaderViewButton: UIButton {
    
    var _link: String?
    
    // MARK: Initializers
    
    convenience init(title: String, link: String) {
        
        self.init()
        self._link = link
        setTitle(title, for: UIControlState())
        setTitleColor(AppConfiguration.PrimaryColor, for: UIControlState())
        titleLabel?.font = AppConfiguration.DefaultBoldFont
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = NSTextAlignment.left
        contentHorizontalAlignment = .left
    }
    
    convenience init(image: UIImage, link: String) {
        self.init()
        self._link = link
        setImage(image, for: UIControlState())
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self._link = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Methods
    
    func create(_ title: String, link: String) {
        
    }
}
