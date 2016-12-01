//
//  Note.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/10/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Note)
class Note: NSManagedObject {
    
    static let entityName = "Note"
    
    @NSManaged var highlightId: String!
    @NSManaged var selectedText: String!
    @NSManaged var noteText: String!
    @NSManaged var savedDate: Date!
    
    @NSManaged var article: Article!
    
    static func getFetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: entityName)
    }
    
    static func new(context: NSManagedObjectContext) -> Note {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Note
    }

    func create(_ article: Article, selectedText: String, noteText: String, highlightId: String) {
        self.article = article
        
        self.selectedText = selectedText
        self.noteText = noteText
        self.highlightId = highlightId
        
        self.savedDate = Date()
    }
    
    func update(_ noteText: String) {
        self.noteText = noteText
    }

}
