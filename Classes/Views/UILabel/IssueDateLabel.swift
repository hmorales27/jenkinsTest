//
//  IssueDateLabel.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/15/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class IssueDateLabel: UILabel {
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        numberOfLines = 0
        font = UIFont.systemFontOfSize(18, weight: SystemFontWeight.Bold)
    }
    
}
