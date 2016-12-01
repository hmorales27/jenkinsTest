//
//  SectionTitleLabel.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/14/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class SectionTitleLabel: JBSMLabel {
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        font = AppConfiguration.DefaultBoldTitleFont
    }
}
