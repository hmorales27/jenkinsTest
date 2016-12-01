//
//  CustomBarButtonItemView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/13/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class CustomBarButtonItemView: UIView {
    
    init(image: UIImage) {
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let imageView = UIImageView(image: image)
        addSubview(imageView)
        
        constrain(imageView) { (imageView) -> () in
            guard let superview = imageView.superview else {
                return
            }
            
            imageView.width == 24
            imageView.height == 24
            imageView.centerY == superview.centerY
            imageView.centerX == superview.centerX
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
