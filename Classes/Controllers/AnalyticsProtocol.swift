//
//  AnalyticsProtocol.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

protocol AnalyticsProtocol {
    var globalContextMap: [AnyHashable: Any] { get set }
    
    func tagScreen(_ pageName: String)
    func tagScreen(_ pageName: String, contextData: [AnyHashable: Any])
    func tagAction(_ actionName: String)
    func tagAction(_ actionName: String, contextData: [AnyHashable: Any])
}
