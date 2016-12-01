//
//  CancelBarButton.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/7/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography


protocol CancelBarButtonDelegate: class {
    
    func cancelBarButtonClicked(_ sender: JBSMButton)
}


class CancelBarButton: JBSMBarButtonItem, JBSMButtonDelegate {

    let button = JBSMButton()
    var delegate: CancelBarButtonDelegate?
    
    override init() {
        super.init()
        setup()
    }
    
    override func setup() {
        super.setup()
        setupButton()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        mainView.addSubview(button)
    }
    
    func setupButton() {
    
        button.setTitle("Cancel", for: UIControlState())
        button.delegate = self
    }
    
    override func setupAutoLayout() {
        super.setupAutoLayout()
        
        constrain(mainView, button) { (mainView, button) -> () in
            
            button.width == 65
            button.height == 44
            button.centerX == mainView.centerX
            button.centerY == mainView.centerY
        }
    }
    
    
    func jbsmButtonWasClicked(_ sender: JBSMButton) {

        //  Call cancelBarButtonDelegate
        delegate?.cancelBarButtonClicked(sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
