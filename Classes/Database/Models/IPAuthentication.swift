//
//  IPAuthentication.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/16/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(IPAuthentication)
open class IPAuthentication: NSManagedObject {

    @NSManaged var session: String?
    @NSManaged var primaryUsageInfo: String?
    @NSManaged var titleId: String?
    @NSManaged var authToken: String?
    @NSManaged var ipAddress: String?
    @NSManaged var organizationName: String?
    @NSManaged var bannerText: String?
    
    func setup(_ json: [String: AnyObject]) {
        session = json["session"] as? String
        primaryUsageInfo = json["primaryUsageInfo"] as? String
        titleId = json["titleId"] as? String
        authToken = json["authToken"] as? String
        ipAddress = json["ipAddress"] as? String
        organizationName = json["organizationName"] as? String
        bannerText = json["bannerText"] as? String
    }
    
    func setup(_ ipAuth: IPAuthenticationResponse) {
        session = ipAuth.session
        primaryUsageInfo = ipAuth.authUsageInfo
        titleId = ipAuth.titleId
        authToken = ipAuth.authToken
        ipAddress = ipAuth.ipAddress
        organizationName = ipAuth.organizationName
        bannerText = ipAuth.bannerText
    }

}
