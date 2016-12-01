//
//  CollapseButton.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/12/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

protocol SectionDataCollapseButtonDelegate: class {
    func sectionDataCollapseButtonDidToggle(collapse: Bool)
}

extension SectionsData {
    class CollapseButton: UIButton {
        
        weak var delegate: SectionDataCollapseButtonDelegate?
        
        var buttonSaysCollapseAll = true
        
        init() {
            super.init(frame: CGRect.zero)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup() {
            setTitleColor(UIColor.darkGray, for: UIControlState())
            titleLabel?.font = AppConfiguration.DefaultBoldFont
            layer.borderColor = UIColor.darkGray.cgColor
            layer.borderWidth = 1
            layer.cornerRadius = 4
            backgroundColor = UIColor.veryLightGray()
            setTitle("Collapse All", for: UIControlState())
            accessibilityLabel = "collapse all articles"
            addTarget(self, action: #selector(userDidSelectButton), for: .touchUpInside)
        }
        
        func updateButton(collapse: Bool) {
            if collapse == true {
                delegate?.sectionDataCollapseButtonDidToggle(collapse: true)
                setTitle("Expand All", for: UIControlState())
                accessibilityLabel = "expand all articles"
                buttonSaysCollapseAll = false
            } else {
                delegate?.sectionDataCollapseButtonDidToggle(collapse: false)
                setTitle("Collapse All", for: UIControlState())
                accessibilityLabel = "collapse all articles"
                buttonSaysCollapseAll = true
            }
        }
        
        func updateState(collapsed: Bool) {
            if collapsed == true {
                setTitle("Expand All", for: UIControlState())
                buttonSaysCollapseAll = false
            } else {
                setTitle("Collapse All", for: UIControlState())
                buttonSaysCollapseAll = true
            }
        }
        
        func userDidSelectButton() {
            if buttonSaysCollapseAll == true {
                updateButton(collapse: true)
            } else {
                updateButton(collapse: false)
            }
        }
        
    }
}
