//
//  EditBarButton.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/5/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography


protocol EditBarButtonDelegate {
    func barButtonWasClicked(_ sender: JBSMButton)
}


class EditBarButton: UIBarButtonItem, JBSMButtonDelegate {

    let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    let button = EditButton()
    var delegate: EditBarButtonDelegate?
    
    override init() {
        super.init()
        setup()
    }
    
    func setup() {
        mainView.addSubview(button)
        self.customView = mainView
        setupButton()
    }
    
    func setupButton() {
        setupAutoLayout()
        button.delegate = self
        button.setTitle("Delete", for: UIControlState.selected)
    }
    
    func setupAutoLayout() {
        
        constrain(mainView, button) { (mainView, button) -> () in
            button.width == 70
            button.height == 44
            button.centerX == mainView.centerX
            button.centerY == mainView.centerY
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - Delegate -
    
    func jbsmButtonWasClicked(_ sender: JBSMButton) {
        
        delegate?.barButtonWasClicked(sender)
    }
}
