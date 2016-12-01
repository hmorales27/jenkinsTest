//
//  NSJSONSerializer+Utility.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/9/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation

extension JSONSerialization {
    
    class func JSONDictionary(_ jsonData:Data?) -> [String: AnyObject]? {
        guard let data = jsonData else {
            return nil
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                return json
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
            return nil
        }
        return nil
    }
}
