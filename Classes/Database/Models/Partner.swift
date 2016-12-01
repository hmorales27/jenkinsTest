//
//  Partner.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/24/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Partner)
open class Partner: NSManagedObject {
    
    static let entityName = "Partner"

    @NSManaged var forgotPasswordURL: String?
    @NSManaged var forgotPasswordService: String?
    @NSManaged var helpText: String?
    @NSManaged var partnerId: NSNumber?
    @NSManaged var partnerName: String?
    
    @NSManaged var journal: Journal?
    
    static func new(context: NSManagedObjectContext) -> Partner {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Partner
    }
    
    @discardableResult
    static func create(json: [String: Any], journal: Journal, context: NSManagedObjectContext) -> Partner {
        let partner = Partner.new(context: context)
        partner.update(json: json)
        partner.journal = journal
        return partner
    }
    
    func update(json: [String: Any]) {
        self.helpText = json["helptext"] as? String
        if let partnerId = json["id"] as? Int {
            self.partnerId = partnerId as NSNumber
        }
        self.partnerName = json["name"] as? String
    }
}
