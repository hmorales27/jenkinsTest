//
//  PageNumberLabel.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/14/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class PageNumberLabel: JBSMLabel {
    
    private let newUiFont = UIFont.italicSystemFontOfSize(16, weight: .Regular)
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        font = USE_NEW_UI ? newUiFont : AppConfiguration.DefaultSmallFont
        textColor = AppConfiguration.GrayColor
    }
    
    func update(_ pageNumber: String?) {
        if let pageNumber = pageNumber {
            let initialText = USE_NEW_UI ? "Pgs. " : "p. "
            
            text = initialText + pageNumber
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
        setActive(false)
    }
}
