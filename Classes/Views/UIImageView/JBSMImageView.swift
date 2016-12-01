//
//  JBSMImageView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/14/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class JBSMImageView: UIImageView {
    let layoutConstraints = JBSMLayoutConstraints()
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func removeAllConstraints() {
        removeConstraints(layoutConstraints.activeConstraints)
    }
}
