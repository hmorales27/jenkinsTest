//
//  TableHeaderView.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/12/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import Cartography

extension SectionsData {
    class TableHeaderView: UITableViewHeaderFooterView {
        
        let view = View()
        
        init() {
            super.init(reuseIdentifier: nil)
            setup()
        }
        
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        func setup() {
            addSubview(view)
            constrain(view) { (view) in
                guard let superview = view.superview else {
                    return
                }
                view.top == superview.top
                view.right == superview.right
                view.bottom == superview.bottom
                view.left == superview.left
            }
        }
        
        override func prepareForReuse() {
            view.reset()
        }
    }
}
