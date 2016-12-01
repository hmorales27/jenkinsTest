//
//  EmailInfoProvider.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/18/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit


protocol EmailInfoDelegate: class {
    func emailBodyForFigure() -> String
}


class EmailInfoProvider: NSObject {
    
    var delegate: EmailInfoDelegate?
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        
        return ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        
        //  Need delegate method to call to construct email body. No access to
        
        
        return activityType == UIActivityTypeMail ? delegate?.emailBodyForFigure() : ""
    }
}
