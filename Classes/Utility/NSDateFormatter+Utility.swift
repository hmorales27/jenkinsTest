//
//  NSDateFormatter+Utility.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/11/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.timeZone = TimeZone(identifier: "UTC")
        self.dateFormat = dateFormat
    }
}
