//
//  UIAlertController+Utility.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/21/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func ErrorMessage(_ title: String, message: String) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return controller
    }
}
