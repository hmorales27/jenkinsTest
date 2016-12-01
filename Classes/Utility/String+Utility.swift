//
//  String.swift
//  JAT
//
//  Created by Sharkey, Justin (ELS-CON) on 7/28/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit

extension String {

    func jbsmClean() -> String {
        let clean = self.characters.filter { (char) -> Bool in
            guard
                char != "-",
                char != "(",
                char != ")"
                else {
                    return false
            }
            return true
        }
        return String(clean)
    }
    
    func insert(_ string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
    func stringBetweenSubstrings(beginningSubstring: String? = nil, endingSubstring: String? = nil) -> String {
        let startIndex = beginningSubstring != nil ? self.range(of: beginningSubstring!)?.upperBound : self.startIndex
        let endIndex = endingSubstring != nil ? self.range(of: endingSubstring!)?.lowerBound : self.endIndex
        if startIndex == nil || endIndex == nil {
            return self
        }
        return self.substring(with: startIndex!..<endIndex!)
    }
}
