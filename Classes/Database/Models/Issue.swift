//
//  Issue.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Issue)
open class Issue: NSManagedObject {
    
    static let EntityName = "Issue"
    static let entityName = "Issue"
    
    // MARK: PROPERTIES (REQUIRED)
    
    @NSManaged var coverImageDownload     : NSNumber!
    @NSManaged var issueId                : NSNumber!
    @NSManaged var issuePii               : String!
    @NSManaged var purchased              : NSNumber!
    @NSManaged var isFreeIssue            : NSNumber!
    
    // MARK: PROPERTIES (OPTIONAL)
    
    @NSManaged var allArticlesDownloaded  : NSNumber?
    @NSManaged var coverImage             : String?
    @NSManaged var dateOfRelease          : Date?
    @NSManaged var editors                : String?
    @NSManaged var issueArticlesPath      : String?
    @NSManaged var issueLabelDisplay      : String?
    @NSManaged var issueName              : String?
    @NSManaged var issueNumber            : String?
    @NSManaged var issuePath              : String?
    @NSManaged var issueTitle             : String?
    @NSManaged var issueTypeDisplay       : String?
    @NSManaged var lastModified           : Date?
    @NSManaged var pageRange              : String?
    @NSManaged var price                  : String?
    @NSManaged var productId              : String?
    @NSManaged var releaseDateAbbrDisplay : String?
    @NSManaged var releaseDateDisplay     : String?
    @NSManaged var sequence               : String?
    @NSManaged var specialEditors         : String?
    @NSManaged var isSpecialIssue         : Bool
    @NSManaged var volume                 : String?

    // MARK: RELATIONSHIPS (SINGLE)
    
    @NSManaged var journal: Journal!
    @NSManaged var openAccess: OA!
    
    // MARK: RELATIONSHIPS (MANY)
    
    @NSManaged fileprivate var articles: NSSet?
}

extension Issue {
    
    static func new(context: NSManagedObjectContext) -> Issue {
        return NSEntityDescription.insertNewObject(forEntityName: Issue.entityName, into: context) as! Issue
    }
    
}
