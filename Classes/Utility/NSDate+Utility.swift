//
//  NSDate+Utility.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/23/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension Date {
    
    static func JBSMShortDateFromString(_ date: String?) -> Date? {
        guard let date = date else {
            return nil
        }
        let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd")
        return dateFormatter.date(from: date)
    }
    
    static func JBSMLongDateFromString(_ date: String?) -> Date? {
        guard let date = date else {
            return nil
        }
        let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
        return dateFormatter.date(from: date)
    }
}
