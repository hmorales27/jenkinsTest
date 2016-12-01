//
//  Announcement.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Announcement)
class Announcement: NSManagedObject {
    
    @NSManaged var announcementDate: Date?
    @NSManaged var announcementId: NSNumber?
    @NSManaged var announcementText: String?
    @NSManaged var announcementTitle: String?
    @NSManaged var opened: NSNumber!
    @NSManaged var announcementDeleted: NSNumber!
    @NSManaged var appId: NSNumber?
    @NSManaged var userDeleted: NSNumber!
    @NSManaged var userRead: NSNumber!
    
    @NSManaged var app: Publisher?

    static let key = String(describing: Announcement.self)
    
    func setup() {

    }

    func create(_ metadata: [String: AnyObject]) {
        setup()
        opened = false
        announcementDeleted = false
        userDeleted = false
        userRead = false
        update(metadata)
    }
    
    func update(_ metadata: [String: AnyObject]) {
        
        if let announcementDate = metadata[Metadata.Announcement.announcementDate] as? String {
            let dateFormatter = DateFormatter(dateFormat: Metadata.Announcement.announcementDate_format)
            self.announcementDate = dateFormatter.date(from: announcementDate)
        } else {
            self.announcementDate = Date()
        }
        
        if let announcementId = metadata[Metadata.Announcement.announcementId] as? NSString {
            self.announcementId = announcementId.integerValue as NSNumber?
        } else if let announcementId = metadata[Metadata.Announcement.announcementId] as? Int {
            self.announcementId = announcementId as NSNumber?
        }
        
        if let announcementText = metadata[Metadata.Announcement.announcementText] as? String {
            self.announcementText = announcementText
        }
        
        if let announcementTitle = metadata[Metadata.Announcement.announcementTitle] as? String {
            self.announcementTitle = announcementTitle
        }
        
        if let isDeleted = metadata["IsDeleted"] as? String {
            self.announcementDeleted = Int(isDeleted) as NSNumber!
        } else if let isDeleted = metadata["IsDeleted"] as? Int {
            self.announcementDeleted = isDeleted as NSNumber!
        }
    }
}
