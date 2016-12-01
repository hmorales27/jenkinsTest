//
//  Section.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/24/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Section)
open class Section: NSManagedObject {
    
    @NSManaged var referenceId: NSNumber?
    @NSManaged var sectionId: String?
    @NSManaged var sectionTitle: String?
    @NSManaged var isThisSubSection: NSNumber?
    @NSManaged var lastModified: Date?
    
    @NSManaged var article: Article?
    
}


extension Section {

    func setup(_ json: [String: String]) {
        if let referenceId      = json["reference_id"]        { self.referenceId = Int(referenceId) as NSNumber? }
        self.sectionId          = json["section_id"]
        self.sectionTitle       = json["section_title"]
        if let isThisSubSection = json["is_this_sub_section"] { self.isThisSubSection = Int(isThisSubSection) as NSNumber? }
        if let lastModified     = json["last_modified"]       { self.lastModified = Date.JBSMLongDateFromString(lastModified) }
    }

}
