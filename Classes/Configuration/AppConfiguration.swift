//
//  App Configuration.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/7/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class AppConfiguration {
    
    @available(*, deprecated: 0.2, message: "Use Config.Padding") static let DefaultPadding: CGFloat = 8
    @available(*, deprecated: 0.2, message: "Use Config.Padding") static let LargePadding: CGFloat   = 16
    @available(*, deprecated: 0.2, message: "Use Config.Padding") static let SmallPadding: CGFloat   = 4
    
    static let DefaultFont = UIFont.systemFontOfSize(16, weight: .Light)
    static let DefaultTitleFont = UIFont.systemFontOfSize(18, weight: .Regular)
    static let DefaultBoldTitleFont = UIFont.systemFontOfSize(18, weight: .Semibold)
    static let DefaultBoldFont = UIFont.systemFontOfSize(16, weight: .Semibold)
    static let DefaultSmallFont = UIFont.systemFontOfSize(14, weight: .Light)
    static let DefaultItalicSmallFont = UIFont.italicSystemFontOfSize(14, weight: .Regular)
        
    static let DefaultColor           = UIColor.black
    static let PrimaryColor           = UIColor.veryDarkBlue()
    static let GrayColor              = UIColor.gray
    static let OpenAccessColor        = UIColor.orange
    static let NavigationBarColor     = UIColor.colorWithHexString("3D3D3D")
    static let NavigationItemColor    = UIColor.white
    static let BackgroundColor        = UIColor.veryLightGray()
    static let WindowBackgroundColor  = UIColor.colorWithHexString("dadada")
    static let ToolbarItemTintColor   = UIColor.colorWithHexString("2F4F4F")
    static let HeaderBackgroundColor  = UIColor.colorWithHexString("686868")
    
    class func UpdateAppearance() {    
        UINavigationBar.appearance().isTranslucent         = false
        UINavigationBar.appearance().tintColor           = AppConfiguration.NavigationItemColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : AppConfiguration.NavigationItemColor]
        UINavigationBar.appearance().barTintColor        = UIColor.colorWithHexString("272727")
        
        UIToolbar.appearance().tintColor                 = UIColor.black
        UIToolbar.appearance().isTranslucent               = false
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
}

struct Config {
    
    struct Padding {
        static let Double  : CGFloat   = 16
        static let Default : CGFloat   = 8
        static let Small   : CGFloat   = 4
    }
    
    struct Colors {
        static let TableViewSeparatorColor : UIColor = UIColor.colorWithHexString("BCBBC1")
        static let SlideOutHighlightColor  : UIColor = UIColor.colorWithHexString("3E8CFF")
        static let ArticleNavigationBarBackgroundColor : UIColor = UIColor.colorWithHexString("DDE8F8")
        static let ArticleNavigationArrowColor : UIColor = UIColor.colorWithHexString("27357D")
        
        static let SingleJournalBackgroundColor : UIColor = USE_NEW_UI ? UIColor.groupTableViewBackground : UIColor.white
    }
}
