//
//  TopArticle.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 10/21/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData


@objc(TopArticle)
open class TopArticle: NSManagedObject {
    
    static let Identifier = "TopArticle"
    
    static func FetchRequest() -> NSFetchRequest<TopArticle> {
        return NSFetchRequest<TopArticle>(entityName: TopArticle.Identifier)
    }
    
    @NSManaged var sequence: NSNumber?
    
    @NSManaged var article: Article!
}
