//
//  SiteCatalyst.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class SiteCatalyst: AnalyticsProtocol {
    
    // MARK: - Properties -
    
    static let MainInstance = SiteCatalyst()
    
    fileprivate var mediaSettings: ADBMediaSettings?
    fileprivate var sharedPreferences: AnyObject?
    var globalContextMap: [AnyHashable: Any] = [:]
    
    // MARK: - Initializers -
    
    class func Create(bundleConfigData configData: [AnyHashable: Any]) {
        MainInstance.populateDefaultContextData(configBundle: configData)
    }
    
    // MARK: - Methods -
    
    func updateContextData(_ configData: [AnyHashable: Any]) {
        populateDefaultContextData(configBundle: configData)
    }
    
    func validateQueuedHitsAndSend() {
        if ADBMobile.trackingGetQueueSize() > 0 {
            ADBMobile.trackingSendQueuedHits()
            ADBMobile.trackingClearQueue()
        }
    }
    
    // MARK: - Screen -
    
    func tagScreen(_ pageName: String) {
        
        globalContextMap[AnalyticsConstant.TagPageDateTime] = formattedTime
        
        if let pageName = globalContextMap[AnalyticsConstant.TagPageName] as? String {
            globalContextMap[AnalyticsConstant.TagPagePrevious] = pageName
        }
        
        globalContextMap[AnalyticsConstant.TagPageName] = pageName
        ADBMobile.trackState(pageName, data: globalContextMap)
    }
    
    func tagScreen(_ pageName: String, contextData: [AnyHashable: Any]) {
        
        var mutableContextData: [AnyHashable: Any] = contextData
        
        globalContextMap[AnalyticsConstant.TagPageDateTime] = formattedTime
        if let pageName = globalContextMap[AnalyticsConstant.TagPageName] as? String {
            globalContextMap[AnalyticsConstant.TagPagePrevious] = pageName
        }
        globalContextMap[AnalyticsConstant.TagPageName] = pageName
        
        let globalContextMapCopy = globalContextMap
        for (key, value) in globalContextMapCopy {
            if mutableContextData[key] == nil {
                mutableContextData[key] = value
            } else {
                globalContextMap[key] = mutableContextData[key]
            }
        }
        ADBMobile.trackState(pageName, data: mutableContextData)
    }
    
    // MARK: - Action -
    
    func tagAction(_ actionName: String) {
        globalContextMap[AnalyticsConstant.TagPageDateTime] = formattedTime
        ADBMobile.trackAction(actionName, data: globalContextMap)
    }
    
    func tagAction(_ actionName: String, contextData: [AnyHashable: Any]) {
        
        var mutableContextData: [AnyHashable: Any] = [:]
        
        globalContextMap[AnalyticsConstant.TagPageDateTime] = formattedTime
        
        for (key, value) in globalContextMap {
            mutableContextData[key] = value
        }
        
        for (key, value) in contextData {
            mutableContextData[key] = value
        }
        
        ADBMobile.trackAction(actionName, data: mutableContextData)
    }
    
    // MARK: - Media -
    
    func configMediaTracking(mediaName: String?, mediaLength: Int?, playerName: String?, playerID: String?) {
        self.mediaSettings = ADBMobile.mediaCreateSettings(withName: mediaName, length: Double(mediaLength!), playerName: playerName, playerID: playerID)
        ADBMobile.mediaOpen(with: self.mediaSettings, callback: nil)
    }
    
    func startMediaTracking(mediaName: String?, mediaLengthStart: Int?) {
        ADBMobile.mediaPlay(mediaName, offset: Double(mediaLengthStart!))
    }
    
    func stopMediaTracking(mediaName: String?, mediaLengthPlayed: Int?) {
        ADBMobile.mediaStop(mediaName, offset: Double(mediaLengthPlayed!))
    }
    
    func closeMediaTracking(mediaName: String) {
        ADBMobile.mediaClose(mediaName)
    }
    
    func trackMedia(mediaName: String, mediaOptionsDetails: [String: AnyObject]) {
        ADBMobile.mediaTrack(mediaName, data: mediaOptionsDetails)
    }
    
    // MARK: - Context -
    
    func populateDefaultContextData(configBundle: [AnyHashable: Any]) {
        if let tagPageAppConnection = configBundle[AnalyticsConstant.TagPageAppConnection] {
            globalContextMap[AnalyticsConstant.TagPageAppConnection] = tagPageAppConnection
        }
        if let journalInfo = configBundle[AnalyticsConstant.TagJournalInfo] {
            globalContextMap[AnalyticsConstant.TagJournalInfo] = (journalInfo as AnyObject).lowercased
        }
        if let tagPageCMSName = configBundle[AnalyticsConstant.TagPageCMSName] {
            globalContextMap[AnalyticsConstant.TagPageCMSName] = tagPageCMSName
        }
        if let businessUnit = configBundle[AnalyticsConstant.TagPageBusinessUnit] {
            globalContextMap[AnalyticsConstant.TagPageBusinessUnit] = businessUnit
        }
        if let dateTime = configBundle[AnalyticsConstant.TagPageDateTime] {
            globalContextMap[AnalyticsConstant.TagPageDateTime] = dateTime
        }
        if let language = configBundle[AnalyticsConstant.TagPageLanguage] {
            globalContextMap[AnalyticsConstant.TagPageLanguage] = language
        }
        if let nextPage = configBundle[AnalyticsConstant.TagPageName] {
            globalContextMap[AnalyticsConstant.TagPageName] = nextPage
        }
        if let previousPage = configBundle[AnalyticsConstant.TagPagePrevious] {
            globalContextMap[AnalyticsConstant.TagPagePrevious] = previousPage
        }
        if let productName = configBundle[AnalyticsConstant.TagProductName] {
            globalContextMap[AnalyticsConstant.TagProductName] = productName
        }
        if let pageType = configBundle[AnalyticsConstant.TagPageType] {
            globalContextMap[AnalyticsConstant.TagPageType] = pageType
        }
        if let visitorAccessType = configBundle[AnalyticsConstant.TagVisitorAccessType] {
            globalContextMap[AnalyticsConstant.TagVisitorAccessType] = visitorAccessType
        }
        if let visitorUserId = configBundle[AnalyticsConstant.TagVisitorUserId] {
            globalContextMap[AnalyticsConstant.TagVisitorUserId] = visitorUserId
        }
        globalContextMap[AnalyticsConstant.TagPageDateTime] = formattedTime
        ADBMobile.setDebugLogging(true)
    }

    var formattedTime: String {
        
        let dateFormatter = DateFormatter(dateFormat: "h:mm a eeee")
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        dateFormatter.timeZone = TimeZone.current
        
        var dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        let minuteComponent = dateComponents.minute
        if minuteComponent! >= 0 && minuteComponent! < 30 {
            dateComponents.minute = 0
        } else if minuteComponent! >= 30 && minuteComponent! < 60 {
            dateComponents.minute = 30
        }
        
        let date = Calendar.current.date(from: dateComponents)
        let dateString = dateFormatter.string(from: date!)
        
        
        
        return dateString.lowercased()
    }
    

    
    // MARK: - Media
    

    
    // MARK: - Default Context Data -

    

}
