//
//  JBSMActivityView.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 8/16/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import Cartography


class JBSMActivityView: UIActivityIndicatorView {
    
    let layoutConstraints = JBSMLayoutConstraints()
    
    fileprivate var width: CGFloat = 25
    
    func updateForAnimation() {
        
        if isAnimating {
            
            layoutConstraints.width?.constant = width
        }
        else {

            layoutConstraints.width?.constant = 0
        }
    }
}
