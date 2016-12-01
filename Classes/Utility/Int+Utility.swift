//
//  Int+Utility.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/6/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation

extension Int {
    
    func convertToFileSize() -> String {
        
        if self == 0 {
            return "0.00 KB"
        }
        
        var convertedValue = Float(self)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return "\(String(format: "%0.2f", convertedValue)) \(tokens[multiplyFactor])"
    }
}
