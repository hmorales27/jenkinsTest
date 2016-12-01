//
//  JBSMButton.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/13/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

protocol JBSMButtonDelegate: class {
    func jbsmButtonWasClicked(_ sender: JBSMButton)
}

class JBSMButton: UIButton {
    
    var linkURL: String?
    var delegate: JBSMButtonDelegate?
    let layoutConstraints = JBSMLayoutConstraints()
    
    init() {
        super.init(frame: CGRect.zero)
        addTarget(self, action: #selector(buttonWasClicked(_:)), for: .touchUpInside)
        //setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //setup()
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func buttonWasClicked(_ sender: JBSMButton) {
        delegate?.jbsmButtonWasClicked(sender)
    }
}
