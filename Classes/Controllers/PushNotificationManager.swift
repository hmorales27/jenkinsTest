//
//  PushNotificationManager.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/9/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class PushNotificationManager: NSObject, UAPushNotificationDelegate {
    
    static let shared = PushNotificationManager()
    
    func receivedBackgroundNotification(_ notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        parseNotification(notification, fetchCompletionHandler: completionHandler, background: true)
    }
    
    func receivedForegroundNotification(_ notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        parseNotification(notification, fetchCompletionHandler: completionHandler, background: false)
    }
    
    func parseNotification(_ notification: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void, background: Bool) {
        
        if let alert = notification["alert"] as? String {
            presentAlert(alert: alert)
        }
        
        guard let info = notification["info"] as? [String: Any] else {
            return
        }
        
        guard let contentType = info["contentType"] else {
            return
        }
        
        if let _contentType = contentType as? String {
            print("string")
        }
        if let _contentType = contentType as? Int {
            print("int")
        }
        
        
        print(notification)
    }
    
    @discardableResult func presentAlert(alert: String?) -> Bool {
        return false
    }
    
}
