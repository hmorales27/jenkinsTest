//
//  ArticleAuthorLabel.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/13/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class ArticleAuthorLabel: JBSMLabel {
    
    private let newUiFont = UIFont.systemFontOfSize(16, weight: .Semibold)
        
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        
        numberOfLines = 0
        font = USE_NEW_UI ? newUiFont : AppConfiguration.DefaultSmallFont
    }
    
    func update(_ authors: String?) {
        if let text = authors {
            self.text = text
            setActive(true)
        } else {
            self.text = ""
            setActive(false)
        }
    }
    
    func reset() {
        text = nil
        setActive(false)
        numberOfLines = 0
    }
    
    // MARK: Other
    
    func setActive(_ active: Bool) {
        if active {
            constraint.top?.constant = Config.Padding.Small
            isHidden = false
        } else {
            constraint.top?.constant = 0
            isHidden = true
        }
    }
}
