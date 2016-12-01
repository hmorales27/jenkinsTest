//
//  TableViewSection.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

open class TableViewSection {
    let title: String
    var items: [Issue] = []
    
    init(title: String) {
        self.title = title
    }
}
