//
//  BrowserInformation.swift
//  JSBM
//
//  Created by Sharkey, Justin (ELS-CON) on 8/13/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import Foundation

open class BrowserInformation {
    
    var htmlString: String?
    var htmlRequest: Foundation.URLRequest?
    var title: String?
    
    init(htmlString: String?, htmlRequest: Foundation.URLRequest?, title: String?) {
        if let item = htmlString {
            self.htmlString = item
        }
        if let item = htmlRequest {
            self.htmlRequest = item
        }
        if let item = title {
            self.title = item
        }
    }
    
}
