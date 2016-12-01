//
//  Logging.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/20/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

struct JBSMLog {
    func error(_ text:AnyObject?) {
        print(text)
    }
    func warning(_ text:AnyObject?) {
        print(text)
    }
    func debug(_ text:AnyObject?) {
        print(text)
    }
    func verbose(_ text:AnyObject?) {
        print(text)
    }
    func info(_ text:AnyObject?) {
        print(text)
    }
    
    func error(_ text:Any?) {
        print(text)
    }
    func warning(_ text:Any?) {
        print(text)
    }
    func debug(_ text:Any?) {
        print(text)
    }
    func verbose(_ text:Any?) {
        print(text)
    }
    func info(_ text:Any?) {
        print(text)
    }
}

let log = JBSMLog()
