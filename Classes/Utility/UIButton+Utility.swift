//
//  UI.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/12/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

extension UIView {
    
    func link() -> String {
        if let link = self.layer.value(forKey: "link") as? String {
            return link
        } else {
            return ""
        }
    }
    
    func setLink(link _link: String?) {
        if let link = _link {
            self.layer.setValue(link, forKey: "link")
        } else {
            
        }
        
    }
}
