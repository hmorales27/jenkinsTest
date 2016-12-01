//: Playground - noun: a place where people can play

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
}

let issn: String = "S0140-6736(15)00806-5"
let s = issn.jbsmClean()
