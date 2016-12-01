//
//  FeedbackTextField.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/1/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let labelWidth: CGFloat = 60
private let labelPadding: CGFloat = 10

class FeedbackTextField: UITextField {
    
    let leftTextLabel = UILabel()
    fileprivate var textFieldAdded = false
    
    func rectForBounds(_ bounds: CGRect) -> CGRect {
        return CGRect(x: labelPadding + labelWidth, y: bounds.origin.y, width: bounds.width - (labelWidth + (labelPadding * 2)), height: bounds.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }
    
    func updateLeftTextLabel(_ text: String) {
        if textFieldAdded == false {
            addSubview(leftTextLabel)
            constrain(leftTextLabel, block: { (label) in
                guard let superview = label.superview else {
                    return
                }
                label.top == superview.top
                label.bottom == superview.bottom
                label.left == superview.left + labelPadding
                label.width == labelWidth
            })
            textFieldAdded = true
            leftTextLabel.textColor = UIColor.gray
        }
        leftTextLabel.text = text
    }
}
