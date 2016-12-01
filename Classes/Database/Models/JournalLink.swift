//
//  JournalLink.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/24/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(JournalLink)
open class JournalLink: NSManagedObject {
    @NSManaged var journalTitle: String?
    @NSManaged var journalURL: String?
    @NSManaged var journal: Journal?
}

extension JournalLink {
    
    
    
}
