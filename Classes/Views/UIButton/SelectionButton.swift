//
//  SelectionButton.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/6/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class SelectionButton: JBSMButton {

    override init() {
        super.init()
        
        setup()
    }
    
    override func setup() {
        
        let unselectedImg = UIImage.init(named: "RadioButton_Unselected")
        let selectedImg = UIImage.init(named: "RadioButton_Selected")
        setImage(unselectedImg, for: UIControlState())
        setImage(selectedImg, for: UIControlState.selected)
        adjustsImageWhenHighlighted = false
        setupAutoLayout()
    }
    
    func setupAutoLayout() {
        constrain(self) { (view) in
            view.width == 35
            view.height == 35
        }
    }
    
    //  MARK: - Action -
    
    override func buttonWasClicked(_ sender: JBSMButton) {
        super.buttonWasClicked(sender)
//        selected = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
