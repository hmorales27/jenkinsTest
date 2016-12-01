//
//  BackgroundManager.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 8/21/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

struct BackgroundManager {
    
    static fileprivate var _AppDelegate: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    static func StartBackgroundRequest() {
        _AppDelegate.backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            _AppDelegate.backgroundTask = UIBackgroundTaskInvalid
        })
    }
    
    static func StopBackgroundRequest() {
        _AppDelegate.backgroundTask = UIBackgroundTaskInvalid
    }
    
}
