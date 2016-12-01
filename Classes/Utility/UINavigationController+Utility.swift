//
//  UINavigationController+Utility.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/23/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func popToRootViewControllerAndLoadViewController(_ vc: UIViewController) {
        DispatchQueue.main.async { () -> Void in
            self.setViewControllers([vc], animated: false)
        }
    }
}
