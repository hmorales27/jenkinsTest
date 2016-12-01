//
//  EmailInfoProvider.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/18/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit


protocol EmailInfoDelegate: class {
    func emailBody() -> String
}


class EmailInfoProvider: NSObject {

    var delegate: EmailInfoDelegate?
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> AnyObject {
        
        return "" as AnyObject
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        guard let delegate = self.delegate, activityType == UIActivityType.mail.rawValue else {
            return nil
        }
        return delegate.emailBody() as AnyObject?
    }
}
