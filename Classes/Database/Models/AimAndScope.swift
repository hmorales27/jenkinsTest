//
//  AimAndScope.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/24/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(AimAndScope)
open class AimAndScope: NSManagedObject {
    
    @NSManaged var homeTxt: String?
    @NSManaged var htmlTxt: String?
    
    @NSManaged var journal: Journal?
    
}

extension AimAndScope {



}
