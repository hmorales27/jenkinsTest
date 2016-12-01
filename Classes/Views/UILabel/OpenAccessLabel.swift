//
//  OpenAccessLabel.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/13/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class OpenAccessLabel: JBSMLabel {
    
    var _font : UIFont {
        
        get {
            let fontSize = USE_NEW_UI ? CGFloat(18) : CGFloat(15)
            
            return UIFont(name: "Elsevier WordmarkRegular", size: fontSize)!
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    override func setup() {
        super.setup()
        
        textColor = UIColor.orange
        font = _font
        isHidden = true
    }
    
    func update(_ labelText: String?) {
        
        if let text = labelText {
            
            let oaString = NSString(string: text)
            let range = oaString.range(of: "Supports")
            
            let attributes = [
                NSForegroundColorAttributeName: UIColor.orange,
                NSFontAttributeName: _font
            ]
            
            let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
            attributedString.setAttributes([NSForegroundColorAttributeName: UIColor.gray], range: range)
            attributedText = attributedString
            
            setActive(true)
            
        } else {
            setActive(false)
        }
    }

    func setActive(_ active: Bool) {
        if active {
            isHidden = false
            constraint.top?.constant = Config.Padding.Default
        } else {
            isHidden = true
            constraint.top?.constant = 0
        }
    }
    
    func reset() {
        text = nil
        isHidden = true
    }
}
