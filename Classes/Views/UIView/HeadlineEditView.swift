//
//  HeadlineEditView.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/6/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography


//  ****Define 'HLEditViewDelegate' protocol here.****

protocol HLEditViewDelegate: class {
    
    func selectAllButtonWasClicked(_ sender: JBSMButton)
}


class HeadlineEditView: JBSMView {

    var selectButton: SelectionButton?
    let label = UILabel()
    var delegate: HLEditViewDelegate?
    
    fileprivate var height: CGFloat = 44
    
    fileprivate var _showing = false
    var showing: Bool {
        
        get {
            return _showing
        }
        set(_bool) {
            
            _showing = _bool
            isHidden = !_showing
            updateForState(_showing)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init() {
        super.init()
        setup()
    }
    
    override func setup() {
        selectButton = SelectionButton()

        self.backgroundColor = UIColor.groupTableViewBackground
        label.text = "Select All"
        label.isAccessibilityElement = false
        
        setupSubviews()
        setupAutoLayout()
        
        selectButton?.isHidden = true
        selectButton?.accessibilityLabel = "Select all articles"
        label.isHidden = true
        
        selectButton?.delegate = self
    }
    
    func setupSubviews() {
        
        guard let selectButton = selectButton else {
            
            return
        }
        
        self.addSubview(selectButton)
        self.addSubview(label)
    }
    
    func setupAutoLayout() {
        
        guard let selectButton = selectButton else {
            
            return
        }
        
        let subviews = [
            selectButton,
            label
        ]
        
        constrain(subviews) { (views) in
            
            let selectB = views[0]
            let label   = views[1]
            
            guard let superview = selectB.superview else {
                
                return
            }
            
            selectB.left == superview.left + Config.Padding.Double
            selectB.centerY == superview.centerY
            
            label.left == selectB.right + Config.Padding.Small
            label.centerY == superview.centerY
            label.width == 81
            label.height == superview.height
        }
    }
    
    fileprivate func updateForState(_ visible: Bool) {
        
        selectButton?.isHidden = !visible
        
        if selectButton?.isHidden == true {
            accessibilityLabel = "Select all articles"
        }
        
        label.isHidden = !visible
        layoutConstraints.height?.constant = visible == true ? height : 0
    }
}


extension HeadlineEditView : JBSMButtonDelegate {
    
    func jbsmButtonWasClicked(_ sender: JBSMButton) {
        
        sender.isSelected = !sender.isSelected
        delegate?.selectAllButtonWasClicked(sender)
        
        sender.accessibilityLabel = sender.isSelected == false ? "Select all articles" : "Deselect all articles"
    }
}

