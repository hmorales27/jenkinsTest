//
//  UIImage+Utility.swift
//  JAT
//
//  Created by Sharkey, Justin (ELS-CON) on 7/10/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit

extension UIImage {
    
    func changeToColor(_ hexCode:String) -> UIImage {
        let rect =  CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.clip(to: rect, mask: self.cgImage!)
        context!.setFillColor(UIColor.colorWithHexString(hexCode).cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let coloredImage = UIImage(cgImage: img!.cgImage!, scale: 1.0, orientation: UIImageOrientation.downMirrored)
        return coloredImage
    }
    
    func heightForWidth(_ width: CGFloat) -> CGFloat {
        let aspectRatio = size.height / size.width
        return (width * aspectRatio)
    }
    
    func aspectRatio() -> CGFloat {
        return size.height / size.width
    }
}
