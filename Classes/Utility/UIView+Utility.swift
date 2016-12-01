//
//  UIView+Utility.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/1/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
    
    /**
     This function will add a layer with corners and shadow to the UIView at index 0. It will set the background color as clear.
     Fill color of the layer is white by default.
     
     - Parameter toLayer: Layer you want to apply style.
     - Parameter fillColor: The background color to apply to layer.
     - Parameter radius: The radius of corners.
     - Paramater shadowColor: The color of the shadow.
     - Parameter shadowOffset: The offset of the shadow.
     - Parameter shadowOpacity: The opacity of the shadow.
     - Parameter shadowRadius: The radius of the shadow.
     */
    func addCornerWithShadow(toLayer layer:CAShapeLayer, fillColor:UIColor, radius:CGFloat, shadowColor:UIColor, shadowOffset:CGSize, shadowOpacity:Float, shadowRadius:CGFloat){
        backgroundColor = UIColor.clear
        layer.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.fillColor = fillColor.cgColor
        
        layer.shadowColor = shadowColor.cgColor
        layer.shadowPath = layer.path
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    /**
     This class function will return the main window.
     
     - returns: Main window.
     */
    class func getMainWindow() -> UIWindow? {
        if let window = UIApplication.shared.delegate?.window {
            return window
        }
        return nil
    }
    
    func matchConstraints(superView: UIView, autoResizingMask: Bool = false, horizontalPadding: CGFloat = 0, verticalPadding: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = autoResizingMask
        self.topAnchor.constraint(equalTo: superView.topAnchor, constant: verticalPadding).isActive = true
        self.leftAnchor.constraint(equalTo: superView.leftAnchor, constant: horizontalPadding).isActive = true
        self.rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -horizontalPadding).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -verticalPadding).isActive = true
    }
    func addSubViewWithMatchingConstraints(subView: UIView, autoResizingMask: Bool = false, horizontalPadding: CGFloat = 0, verticalPadding: CGFloat = 0) {
        self.addSubview(subView)
        subView.matchConstraints(superView: self, autoResizingMask: autoResizingMask, horizontalPadding: horizontalPadding, verticalPadding: verticalPadding)
    }
}
