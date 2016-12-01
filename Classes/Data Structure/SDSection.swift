//
//  Section.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/12/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension SectionsData {
    class Section {
        
        let name: String
        var collapsed = true
        
        var color: UIColor?
        
        init(name: String) {
            self.name = name
        }
    }
}
