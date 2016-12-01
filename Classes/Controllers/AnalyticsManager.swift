//
//  AnalyticsManager.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class AnalyticsManager {
    
    class func Create(analyticsType type: AnalyticsType, bundleConfigData configData: [AnyHashable: Any]) {
        AnalyticsManager.MainInstance.analyticsType = type
        
        switch type {
        case .all:
            break
        case .siteCatalyst:
            SiteCatalyst.Create(bundleConfigData: configData as [NSObject : AnyObject])
        }
    }
    
    static let MainInstance = AnalyticsManager()
    
    fileprivate var analyticsType: AnalyticsType = .all
    
    // MARK: - Configuration -
    
    func updateConfiguration(_ config: [AnyHashable: Any]) {
        SiteCatalyst.MainInstance.updateContextData(config)
    }
    
    // MARK: - Defaults -
    
    func updateDefaultMapValues(mapValues values: [AnyHashable: Any]) {
        SiteCatalyst.MainInstance.updateContextData(values)
    }
    
    // MARK: - State -
    
    func trackState(_ pageName: String) {
        switch analyticsType {
        case .all:
            break
        case .siteCatalyst:
            SiteCatalyst.MainInstance.tagScreen(pageName)
        }
    }
    
    func trackState(_ pageName: String, contextData: [AnyHashable: Any]) {
        switch analyticsType {
        case .all:
            break
        case .siteCatalyst:
            SiteCatalyst.MainInstance.tagScreen(pageName, contextData: contextData)
        }
    }
    
    // MARK: - Action -
    
    func tagAction(_ actionName: String) {
        switch analyticsType {
        case .all:
            break
        case .siteCatalyst:
            SiteCatalyst.MainInstance.tagAction(actionName)
        }
    }
    
    func tagAction(_ actionName: String, contextData: [AnyHashable: Any]) {
        switch analyticsType {
        case .all:
            break
        case .siteCatalyst:
            SiteCatalyst.MainInstance.tagAction(actionName, contextData: contextData)
        }
    }
    
    // MARK: - Offline -
    
    func validateOfflineHitsAndSend() {
        switch analyticsType {
        case .all:
            break
        case .siteCatalyst:
            SiteCatalyst.MainInstance.validateQueuedHitsAndSend()
        }
    }
    
    // MARK: - Multimedia -
    
    func configMultimedia(_ mediaName: String?, mediaTotalLength: Int?, mediaPlayerName: String?, mediaPlayerID: String?) {
        switch analyticsType {
        case .all:
            break
        case .siteCatalyst:
            SiteCatalyst.MainInstance.configMediaTracking(mediaName: mediaName, mediaLength: mediaTotalLength, playerName: mediaPlayerName, playerID: mediaPlayerID)
        }
    }
    
    func startMultimediaTracking(_ playPause: Bool, mediaName: String?, mediaOffset: Int?) {
        switch analyticsType {
        case .all:
            break
        case .siteCatalyst:
            if playPause == true {
                SiteCatalyst.MainInstance.startMediaTracking(mediaName: mediaName, mediaLengthStart: mediaOffset)
            } else {
                SiteCatalyst.MainInstance.stopMediaTracking(mediaName: mediaName, mediaLengthPlayed: mediaOffset)
            }
        }
    }
    
    func releaseMultimediaTracking(_ mediaName: String) {
        switch analyticsType {
        case .all:
            break
        case .siteCatalyst:
            SiteCatalyst.MainInstance.closeMediaTracking(mediaName: mediaName)
        }
    }
}
