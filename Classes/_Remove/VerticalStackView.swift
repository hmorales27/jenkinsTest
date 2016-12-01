//
//  VerticalStackView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/15/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class VerticalStackView: UIStackView {
    
    init() {
        super.init(frame: CGRectZero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        axis = .Vertical
    }
    
}
