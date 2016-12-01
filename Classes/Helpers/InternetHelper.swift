//
//  InternetHelper.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/9/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class InternetHelper {
    
    static let sharedInstance = InternetHelper()
    let reachability = Reachability.forInternetConnection()
    
    var available: Bool {
        get {
            return reachability!.isReachable()
        }
    }
    
    init() {
        
    }
}
