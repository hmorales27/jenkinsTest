//
//  Link.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Link)
open class Link: NSManagedObject {
    
    @NSManaged open var title: String!
    @NSManaged open var url: String!
    @NSManaged open var app: Publisher?
    @NSManaged open var journal: Journal?
    
    func create(_ metadata:[String:AnyObject], withJournal journal:Journal) {
        self.journal = journal
        if let title = metadata["Journal_Link_Title"] as? String {
            self.title = title
        } else {
            self.title = ""
        }
        if let url = metadata["Journal_Link_URL"] as? String {
            self.url = url
        } else {
            self.url = ""
        }
    }
    
    func create(_ metadata:[String:AnyObject], withPublisher publisher:Publisher) {
        self.app = publisher
        if let title = metadata["Society_Link_Title"] as? String {
            self.title = title
        } else {
            self.title = ""
        }
        if let url = metadata["Society_Link_URL"] as? String {
            self.url = url
        } else {
            self.url = ""
        }
    }
}
