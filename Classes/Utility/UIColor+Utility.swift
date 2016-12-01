//
//  UIColor+Utility.swift
//  JAT
//
//  Created by Sharkey, Justin (ELS-CON) on 7/9/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit

extension UIColor {
    
    class func colorWithHexString (_ hex:String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    class func colorWithHexCSV(_ hexCSV: String?) -> UIColor? {
        if let color = hexCSV {
            let colorNoString = color.replacingOccurrences(of: " ", with: "")
            let colorArray = colorNoString.components(separatedBy: ",")
            if colorArray.count == 3 {
                let redString = colorArray[0]
                let greenString = colorArray[1]
                let blueString = colorArray[2]
                if let redInt = Int(redString), let greenInt = Int(greenString), let blueInt = Int(blueString) {
                    let redFloat = CGFloat(redInt)
                    let greenFloat = CGFloat(greenInt)
                    let blueFloat = CGFloat(blueInt)
                    return UIColor(red: redFloat/255, green: greenFloat/255, blue: blueFloat/255, alpha: 1.0)
                }
            }
        }
        return nil
    }
    
    class func GreatGreen() -> UIColor {
        return UIColor.colorWithHexString("3D9140")
    }
    
    class func blueGray() -> UIColor {
        return UIColor.colorWithHexString("98AFC7")
    }
    
    class func steelBlue() -> UIColor {
        return UIColor.colorWithHexString("4863A0")
    }
    
    class func gold() -> UIColor {
        return UIColor.colorWithHexString("FFD700")
    }
    
    class func lightGray() -> UIColor {
        return UIColor.colorWithHexString("D3D3D3")
    }
    
    class func veryLightGray() -> UIColor {
        return UIColor.colorWithHexString("E9E9E9")
    }
    
    class func darkGoldColor() -> UIColor {
        return UIColor.colorWithHexString("EEBC1D")
    }
    
    class func navyBlueColor() -> UIColor {
        return UIColor.colorWithHexString("000080")
    }

    class func dimGrayColor() -> UIColor {
        return UIColor.colorWithHexString("343434")
    }
    
    class func veryDarkBlue() -> UIColor {
        return UIColor.colorWithHexString("21436C")
    }
}
