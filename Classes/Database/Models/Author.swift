//
//  Author.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Author)
open class Author: NSManagedObject {
    
    @NSManaged open var desc: String?
    @NSManaged open var identifier: NSNumber?
    @NSManaged open var lastModified: Date?
    @NSManaged open var name: String?
    
    @NSManaged open var article: Article?
    
}

extension Author {
    
    func create(_ metadata:[String:AnyObject], article:Article) {
        update(metadata)
    }

    func create(_ metadata:[String: AnyObject]) {
        update(metadata)
    }
    
    func update(_ metadata:[String: AnyObject]) {
        desc = metadata["author_description"] as? String
        identifier = (metadata["author_id"] as? String)?.int() as NSNumber?
        name = metadata["author_name"] as? String
        lastModified = Date.JBSMLongDateFromString(metadata["last_modified"] as? String)
    }
}
