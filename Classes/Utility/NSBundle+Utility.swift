//
//  NSBundle+Utility.swift
//  JAT
//
//  Created by Sharkey, Justin (ELS-CON) on 7/27/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit

extension Bundle {

    class func apiDictionary() -> [String: AnyObject] {
        let resource = Bundle.main.path(forResource: "api", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: resource!)
        return dictionary as! [String: AnyObject]
    }
    
    class func appIcon() -> UIImage? {
        let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? NSDictionary
        let primaryIconsDictionary = iconsDictionary?["CFBundlePrimaryIcon"] as? NSDictionary
        let iconFiles = primaryIconsDictionary?["CFBundleIconFiles"] as? NSArray
        let lastIcon = iconFiles?.lastObject as! NSString
        return UIImage(named: lastIcon as String)
    }
    
    class func appName() -> String?{
        return Bundle.main.infoDictionary?["CFBundleName"] as? String
    }
}
