//
//  StarredDateLabel.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/6/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class StarredDateLabel: JBSMLabel {
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        font = AppConfiguration.DefaultItalicSmallFont
        textColor = AppConfiguration.GrayColor
    }
    
    func update(_ date: Date?) {
        if let date = date {
            let dateFormatter = DateFormatter(dateFormat: "MMM dd, YYYY")
            let dateString = dateFormatter.string(from: date)
            text = "Saved On \(dateString)"
            setActive(true)
        } else {
            setActive(false)
        }
    }
    
    func setActive(_ active: Bool) {
        if active {
            isHidden = false
        } else {
            isHidden = true
        }
    }
    
    func reset() {
        text = nil
        setActive(false)
    }
}
