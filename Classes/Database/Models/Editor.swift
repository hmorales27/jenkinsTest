//
//  Editor.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/24/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Editor)
open class Editor: NSManagedObject {
    
    @NSManaged var htmlText: String?
    
    @NSManaged var journal: Journal?
}


extension Editor {



}
