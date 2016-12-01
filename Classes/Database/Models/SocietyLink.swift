//
//  SocietyLink.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(SocietyLink)
open class SocietyLink: NSManagedObject {
    
    @NSManaged open var title: String?
    @NSManaged open var url: String?
    
    @NSManaged open var app: Publisher?

    func create(_ metadata:[String: AnyObject]) {
        self.update(metadata)
    }
    
    func update(_ metadata:[String: AnyObject]) {
        if let title = metadata["title"] as? String {
            self.title = title
        }
        if let url = metadata["url"] as? String {
            self.url = url
        }
    }

}
