//
//  OA_UpdateWithCase.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/26/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension OA {
    
    func create(json: [String: AnyObject]) {
        setupDefaults()
        update(json: json)
    }
    
    func setupDefaults() {
        oaIdentifier = 0
    }
    
    func update(json: [String: AnyObject]) {
        
        if let oaDisplaySponsorName = json["oaDisplaySponsorName"] as? String {
            self.oaDisplaySponsorName = oaDisplaySponsorName != "" ? oaDisplaySponsorName : nil
        }
        
        if let oaDisplayLicense = json["oaDisplayLicense"] as? String {
            self.oaDisplayLicense = oaDisplayLicense != "" ? oaDisplayLicense : nil
        }
        
        if let oaIdentifier = json["oaIdentifier"] as? Int {
            self.oaIdentifier = oaIdentifier as NSNumber!
        }
        
        if let oaStatusArchive = json["oaStatusArchive"] as? String {
            if oaStatusArchive != "" {
                self.oaStatusArchive = oaStatusArchive
            }
        }
        
        if let oaStatusDisplay = json["oaStatusDisplay"] as? String {
            if oaStatusDisplay != "" {
                self.oaStatusDisplay = oaStatusDisplay
            }
        }
        
        if let oaInfoHTML = json["OA_Info_Html"] as? String {
            if oaInfoHTML != "" {
                self.oaInfoHTML = oaInfoHTML
            }
        }
    }
}
