//
//  ViewsHelper.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 7/21/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class ViewsHelper {
    
    class func HighlightSeparatorGradient() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        
        let topColor = UIColor.colorWithHexString("F2F2F2")
        //let bottomColor = UIColor.colorWithHexString("CBCACB")
        let bottomColor = UIColor.black
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        
        return gradientLayer
    }
    
    class func HighlightSeparatorViewBackground() -> UIView {
        let view = UIView()
        
        let gradientLayer = CAGradientLayer()
        
        let topColor = UIColor.colorWithHexString("F2F2F2")
        //let bottomColor = UIColor.colorWithHexString("CBCACB")
        let bottomColor = UIColor.black
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        
        view.layer.addSublayer(gradientLayer)
        
        return view
    }
    
}

