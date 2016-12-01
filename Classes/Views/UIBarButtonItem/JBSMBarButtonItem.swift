//
//  JBSMBarButtonItem.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/13/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class JBSMBarButtonItem: UIBarButtonItem {
    
    let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    let imageView = UIImageView()
    
    override init() {
        super.init()
        setup()
    }
    
    init(target: UIViewController, action: Selector) {
        super.init()
        self.target = target
        self.action = action
        setup()
    }
    
    init(image: UIImage, target: UIViewController, action: Selector) {
        super.init()
        self.target = target
        self.action = action
        imageView.image = image
        setup()
    }

    func setup() {
        setupSubviews()
        setupAutoLayout()
        self.customView = mainView
    }
    
    func setupSubviews() {
        mainView.addSubview(imageView)
    }
    
    func setupAutoLayout() {
        constrain(mainView, imageView) { (mainView, imageView) -> () in
            imageView.width == 24
            imageView.height == 24
            imageView.centerX == mainView.centerX
            imageView.centerY == mainView.centerY
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
