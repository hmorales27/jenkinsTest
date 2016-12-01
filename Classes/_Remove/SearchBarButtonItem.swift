//
//  SearchBarButtonItem.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/13/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class SearchBarButtonItem: JBSMBarButtonItem {
    
    override init(target: UIViewController, action: Selector) {
        super.init(image: UIImage(named: "Search")!, target: target, action: action)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
