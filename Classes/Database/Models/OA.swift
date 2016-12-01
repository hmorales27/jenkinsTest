//
//  OpenAccess.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/1/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(OA)
open class OA: NSManagedObject {
    
    // MARK: PROPERTIES
    
    @NSManaged var oaDisplaySponsorName : String?
    @NSManaged var oaDisplayLicense     : String?
    @NSManaged var oaIdentifier         : NSNumber!
    @NSManaged var oaModifiedDate       : Date?
    @NSManaged var oaSinceDate          : Date?
    @NSManaged var oaStatusArchive      : String?
    @NSManaged var oaStatusDisplay      : String?
    @NSManaged var oaInfoHTML           : String?
    
    // MARK: PLACEHOLDERS
    
    @NSManaged var articleInfoId        : String?
    @NSManaged var issuePii             : String?
    
    // MARK: RELATIONSHIPS
    
    @NSManaged var article              : Article?
    @NSManaged var issue                : Issue?
    @NSManaged var journal              : Journal?
    
    // MARK: FROM ARTICLE
    
    var type: OAIdentifier {
        get {
            guard let oa = OAIdentifier(rawValue: oaIdentifier.intValue) else {
                return OAIdentifier.noIdentifier
            }
            return oa
        }
    }
}
