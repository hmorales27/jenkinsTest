//
//  NSURL+Utility.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/18/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation

extension URL {
    
    init(basePath: String, parameters: [String: String]) {
        var url = basePath
        if parameters.count > 0 {
            url += "?"
        }
        var i = 0
        for (key, value) in parameters {
            if i > 0 {
                url += "&"
            }
            url += "\(key)=\(value)"
            i += 1
        }
        self.init(string: url)!
    }
    
    func fileName() -> String? {
        if let file = pathComponents.last {
            return file
        }
        return nil
    }
    
    func parameters() -> [String: String] {
        
        var parametersDictionary:[String: String] = [:]
        
        guard let query = self.query else {
            return [:]
        }
        
        let parameters = query.components(separatedBy: "&")
        if parameters.count > 0 {
            for parameter in parameters {
                let keyValue = parameter.components(separatedBy: "=")
                if keyValue.count > 0 {
                    parametersDictionary[keyValue[0]] = keyValue[1]
                }
                
            }
        }
        
        return parametersDictionary
    }
    
    var isTelephoneNumber: Bool {
        get {
            if absoluteString.hasPrefix("tel:") { return true }
            return false
        }
    }
    
    var isEmailAddress: Bool {
        get {
            if absoluteString.hasPrefix("mailto:") { return true }
            return false
        }
    }
    
}
