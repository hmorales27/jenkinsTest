//
//  CIResponse.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/22/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

struct CIResponse {
    
    let articlePii: String
    let widgetFeatureMessage: String
    let widgetFeatureMessageDisplayTime: Int
    let contentInnovationTitle: String
    let accessibilityTitle: String
    let articleCIIconName: String
    let widgetModel: [CIWidget]
    
    init(metadata: [String: AnyObject]) {
        
        if let articlePii = metadata["articlePii"] as? String {
            self.articlePii = articlePii
        } else {
            self.articlePii = ""
        }
        
        if let widgetFeatureMessage = metadata["widgetFeatureMessage"] as? String {
            self.widgetFeatureMessage = widgetFeatureMessage
        } else {
            self.widgetFeatureMessage = ""
        }
        
        if let widgetFeatureMessageDisplayTime = metadata["widgetFeatureMessageDisplayTime"] as? String {
            self.widgetFeatureMessageDisplayTime = Int(widgetFeatureMessageDisplayTime)!
        } else if let widgetFeatureMessageDisplayTime = metadata["widgetFeatureMessageDisplayTime"] as? Int {
            self.widgetFeatureMessageDisplayTime = widgetFeatureMessageDisplayTime
        } else {
            self.widgetFeatureMessageDisplayTime = 5000
        }
        
        if let contentInnovationTitle = metadata["contentInnovationTitle"] as? String {
            self.contentInnovationTitle = contentInnovationTitle
        } else {
            self.contentInnovationTitle = ""
        }
        
        if let accessibilityTitle = metadata["accessibilityTitle"] as? String {
            self.accessibilityTitle = accessibilityTitle
        } else {
            self.accessibilityTitle = ""
        }
        
        if let widgetIconName = metadata["articleCiIconName"] as? String {
            self.articleCIIconName = widgetIconName
        } else {
            self.articleCIIconName = ""
        }
        
        var items: [CIWidget] = []
        if let widgetModel = metadata["widgetModel"] as? [[String: AnyObject]] {
            for model in widgetModel {
                items.append(CIWidget(json: model))
            }
        }
        self.widgetModel = items
    }
    
}

struct CIWidget {
    let widgetName: String
    let widgetActionMessage: String
    let widgetIconName: String
    let widgetImageUrl: String
    let widgetSrcUrl: String
    
    init(json: [String: AnyObject]) {
        if let widgetName = json["widgetName"] as? String {
            self.widgetName = widgetName
        } else {
            self.widgetName = ""
        }
        
        if let widgetActionMessage = json["widgetActionMessage"] as? String {
            self.widgetActionMessage = widgetActionMessage
        } else {
            self.widgetActionMessage = ""
        }
        
        if let widgetIconName = json["widgetIconName"] as? String {
            self.widgetIconName = widgetIconName
        } else {
            self.widgetIconName = ""
        }
        
        if let widgetImageUrl = json["widgetImageUrl"] as? String {
            self.widgetImageUrl = widgetImageUrl
        } else {
            self.widgetImageUrl = ""
        }
        
        if let widgetSrcUrl = json["widgetSrcUrl"] as? String {
            self.widgetSrcUrl = widgetSrcUrl
        } else {
            self.widgetSrcUrl = ""
        }
    }
}

