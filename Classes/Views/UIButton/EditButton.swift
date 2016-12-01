//
//  EditButton.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/5/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class EditButton: JBSMButton {

    override init() {
        super.init()
        setTitle("Edit", for: UIControlState())
    }
    
    override func setup() {
        super.setup()
        setupAutoLayout()
    }
    
    
    func setupAutoLayout() {
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
