//
//  NSLayoutConstraing+Utility.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/19/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    class func EasyConstructor(subView:UIView, superView:UIView, attribute:NSLayoutAttribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item       : subView,
            attribute  : attribute,
            relatedBy  : .equal,
            toItem     : superView,
            attribute  : attribute,
            multiplier : 1.0,
            constant   : 0.0
        )
    }
}
