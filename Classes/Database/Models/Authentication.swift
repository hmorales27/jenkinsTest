//
//  Authentication.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/24/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Authentication)
open class Authentication: NSManagedObject {
    
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var sessionId: String?
    @NSManaged var loginId: String?
    @NSManaged var password: String?
    @NSManaged var userId: String?
    @NSManaged var emailId: String?
    @NSManaged var rememberMe: NSNumber?
    @NSManaged var societyType: String?
    @NSManaged var idp: String?
    
    @NSManaged var partner: Partner?
    @NSManaged var journal: Journal?

}
