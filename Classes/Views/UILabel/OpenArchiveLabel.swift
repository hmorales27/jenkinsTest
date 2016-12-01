//
//  OpenAccessLabel.swift
//  JBSM
/*
 Created by Sharkey, Justin (ELS-CON) on 12/13/15.
 Copyright © 2015 Elsevier, Inc. All rights reserved.
*/

import UIKit

class OpenArchiveLabel: JBSMLabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    override func setup() {
        super.setup()
        
        numberOfLines = 1
        adjustsFontSizeToFitWidth = true
        isHidden = true
    }
    
    func update(_ labelText: String?) {
        if let text = labelText {
            self.text = text
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
