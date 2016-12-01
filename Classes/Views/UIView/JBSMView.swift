//
//  JBSMView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/13/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class JBSMLayoutConstraints {
    
    weak var top: NSLayoutConstraint?
    weak var right: NSLayoutConstraint?
    weak var bottom: NSLayoutConstraint?
    weak var left: NSLayoutConstraint?
    
    weak var height: NSLayoutConstraint?
    weak var width: NSLayoutConstraint?
    
    weak var centerX: NSLayoutConstraint?
    weak var centerY: NSLayoutConstraint?
    
    var activeConstraints: [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if let _top = top {
            constraints.append(_top)
        }
        if let _right = right {
            constraints.append(_right)
        }
        if let _bottom = bottom {
            constraints.append(_bottom)
        }
        if let _left = left {
            constraints.append(_left)
        }
        if let _height = height {
            constraints.append(_height)
        }
        if let _width = width {
            constraints.append(_width)
        }
        return constraints
    }
}


class JBSMView: UIView {
    
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
