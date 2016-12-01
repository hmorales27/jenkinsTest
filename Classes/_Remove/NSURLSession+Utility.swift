//
//  NSURLSession+Utility.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/11/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension NSURLSession {
    
    class func DefaultSession() -> NSURLSession {
        return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }
    
}
