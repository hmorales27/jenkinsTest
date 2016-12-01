//
//  References.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Reference)
open class Reference: NSManagedObject {
    
    @NSManaged open var isThisSubSection: NSNumber?
    @NSManaged open var lastModified: Date?
    @NSManaged open var referenceId: NSNumber?
    @NSManaged open var sectionId: String?
    @NSManaged open var sectionTitle: String?
    
    @NSManaged open var article: Article?

    func create(metadata: [String: AnyObject]) {
        self.update(metadata: metadata)
    }
    
    func update(metadata: [String: AnyObject]) {
        
        if let referenceId = metadata["referenceId"] as? Int {
            self.referenceId = referenceId as NSNumber
        }
        
        if let sectionId = metadata["sectionId"] as? String {
            self.sectionId = sectionId
        }
        
        if let sectionTitle = metadata["sectionTitle"] as? String {
            self.sectionTitle = sectionTitle
        }
        
        if let isThisSubSection = metadata["isSubSection"] as? Bool {
            self.isThisSubSection = isThisSubSection as NSNumber
        }
        
        if let lastModified = metadata["lastModified"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            if let date = formatter.date(from: lastModified) {
                self.lastModified = date
            }
        }
    }

}
