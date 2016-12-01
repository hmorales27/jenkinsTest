//
//  AnalyticsHelper.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class AnalyticsHelper {
    
    // MARK: - Data Sources -
    
    enum ContentAction {
        case download
        case saveArticleToList
        case removeArticleFromList
        case turnAway
        case share
        case addNote
        case emailNote
        case next
        case previous
        case ciClick
        case login
        case loginSuccess
        case font
        case submitFeedback
        case deleteIssue
        case deleteAIP
        case deleteOaArticle
        case play
    }
    
    enum SearchAction {
        case resultClick
        case save
    }
    
    // MARK: - Properties -
    
    static let MainInstance = AnalyticsHelper()
    
    static let PageViewMultipleCallTime = "page_view_multiple_call_time"
    
    var isMultiJournal: Bool = false
    
    fileprivate var articleDetailsContextInfo: [String: AnyObject] = [:]
    
    // MARK: - Initializers -
    
    class func Create(analyticsType type: AnalyticsType) {
        AnalyticsManager.Create(analyticsType: type, bundleConfigData: AnalyticsHelper.MainInstance.createConfig(analyticsType: type) as [NSObject : AnyObject])
    }
    
    // MARK: - Methods -
    
    func saveIsAppMultiJournal(_ isMultiJournal: Bool) {
        self.isMultiJournal = isMultiJournal
    }
    
    func isAppMultiJournal() -> Bool {
        return isMultiJournal
    }
    
    // MARK: - Tracking -
    
    func tracking() {
        
    }
    
    // MARK: - Update Defaults -
    
    func updateDefaultConfiguration(_ bundleConfig: [AnyHashable: Any]) {
        AnalyticsManager.MainInstance.updateConfiguration(bundleConfig)
    }
    
    // MARK: - Update Log In Defaults -
    
    func updateLoginInDefaultConfiguration(_ accessType: String, uniqueUserId: String) {
        var bundleAnalyticsConfig: [AnyHashable: Any] = [:]
        
        var _accessType: String
        if accessType == "login" {
            _accessType = "sso"
        } else {
            _accessType = "tps"
        }
                
        bundleAnalyticsConfig[AnalyticsConstant.TagVisitorAccessType] = "jb:jb-style-b:\(_accessType)-0:jb-othr"
        bundleAnalyticsConfig[AnalyticsConstant.TagVisitorUserId] = "jb:\(uniqueUserId)"
        updateDefaultConfiguration(bundleAnalyticsConfig)
    }
    
    // MARK: - Screen -
    
    func analyticsTagScreen(pageName: String, pageType: String) {
        var stateContentData: [String: AnyObject] = [:]
        stateContentData[AnalyticsConstant.TagPageType] = pageType as AnyObject?
        trackState(pageName, stateContentData: stateContentData)
    }
    
    // MARK: - State -
    
    func trackState(_ pageName: String, stateContentData: [AnyHashable: Any]) {
        var _temp = stateContentData
        _temp[AnalyticsConstant.TagPageAppConnection] = getNetworkInfoValueForAnalytics()
        AnalyticsManager.MainInstance.trackState(pageName, contextData: _temp)
    }
    
    // MARK: - Action -
    
    func trackAction(_ actionName: String, actionContentData: [AnyHashable: Any]) {
        var _temp = actionContentData
        _temp[AnalyticsConstant.TagPageAppConnection] = getNetworkInfoValueForAnalytics()
        AnalyticsManager.MainInstance.tagAction(actionName, contextData: _temp)
    }
    
    // MARK: - Offline -
    
    func validateOfflineHitsAndSend() {
        AnalyticsManager.MainInstance.validateOfflineHitsAndSend()
    }
    
    // MARK: - Timestamp -
    
    func saveLastPageViewTimeStampInArticle() {
        // Save Timestamp for Calls
    }
    
    func isLastPageViewTimeStampInArticleAllowed() -> Bool {
        return true
    }
    
    // MARK: - Multimedia -
    
    func configureMultimedia(mediaName: String?, mediaTotalLength: Int?, mediaPlayerName: String?, mediaPlayerID: String?) {
        AnalyticsManager.MainInstance.configMultimedia(mediaName, mediaTotalLength: mediaTotalLength, mediaPlayerName: mediaPlayerName, mediaPlayerID: mediaPlayerID)
    }
    
    func startMultimediaTracking(playPause: Bool, mediaName: String?, mediaOffset: Int?) {
        AnalyticsManager.MainInstance.startMultimediaTracking(playPause, mediaName: mediaName, mediaOffset: mediaOffset)
    }
    
    func releaseMultimediaTracking(mediaName: String) {
        AnalyticsManager.MainInstance.releaseMultimediaTracking(mediaName)
    }
    
    // MARK: - Tag Action -
    
    func analyticsTagAction(_ contentAction: ContentAction, additionalInfo: String) {
        var contentData: [AnyHashable: Any] = [:]
        var action: String = ""
        
        switch contentAction {
        case .addNote:
            action = Constants.Action.ContentAddNoteToArticle
            contentData[Constants.Events.ProductInfo] = "\(additionalInfo)"
            contentData[Constants.Events.Name] = action
        case .emailNote:
            action = Constants.Action.ContentEmailNoteToArticle
            contentData[Constants.Events.ProductInfo] = "\(additionalInfo)"
            contentData[Constants.Events.Name] = action
        case .next:
            action = "navigate to article:\(Constants.Action.Next)"
            contentData[Constants.Events.ProductInfo] = "\(additionalInfo)"
            contentData[Constants.Events.Name] = action
        case .previous:
            action = "navigate to article:\(Constants.Action.Previous)"
            contentData[Constants.Events.ProductInfo] = "\(additionalInfo)"
            contentData[Constants.Events.Name] = action
        case .share:
            action = Constants.Action.ContentShare
            contentData[Constants.Events.ProductInfo] = "\(additionalInfo)"
            contentData[Constants.Events.ContentShare] = "1"
            contentData[Constants.Events.Name] = action
        case .turnAway:
            action = Constants.Action.ContentTurnAway
            contentData[Constants.Events.ProductInfo] = "\(additionalInfo)"
            contentData[Constants.Events.ContentTurnAway] = "1"
            contentData[Constants.Events.Name] = action
        case .login:
            action = Constants.Action.ContentLogin
            contentData[Constants.Events.ContentLogin] = "1"
            contentData[Constants.Events.Name] = action
        case .loginSuccess:
            action = Constants.Action.ContentLoginSuccess
            contentData[Constants.Events.LoginSuccessful] = "1"
        case .font:
            action = Constants.Action.ContentChangeFontSize
            contentData[Constants.Events.Name] = action
        case .submitFeedback:
            action = Constants.Action.ContentSubmitFeedback
            contentData[Constants.Events.Name] = action
        case .deleteAIP:
            action = Constants.Action.ContentDeleteAIP
            contentData[Constants.Events.Name] = action
        case .deleteIssue:
            action = Constants.Action.ContentDeleteIssue
            contentData[Constants.Events.Name] = action
        default:
            break
        }
        
        trackAction(action, actionContentData: contentData)
    }
    
    func contentInnovationAnalyticsTagAction(_ productInfo: String, widgetName: String) {
        let contentData = [
            Analytics.EventProductInfo            : Analytics.ActionProductInfo(productInfo),
            Analytics.EventContentInnovationName  : "\(widgetName)",
            "event.innovationClick"               : "1",
            Analytics.EventName                   : Analytics.ActionContentInnovationClick
        ]
        let action = Analytics.ActionContentInnovationClick
        trackAction(action, actionContentData: contentData)
    }
    
    func contentDownloadAnalytics(_ productInfo: String, contentInfo: [AnyHashable: Any]) {
        var contentData: [AnyHashable: Any] = [:]
        for (key, value) in contentInfo {
            contentData[key] = value
        }
        let action: String = Constants.Action.ContentDownload
        contentData[Constants.Events.ProductInfo]     = "\(productInfo)"
        contentData[Constants.Events.ContentDownload] = "1"
        contentData[Constants.Events.Name]            = action
        trackAction(action, actionContentData: contentData)
    }
    
    func contentPDFView(_ productInfo: String, contentInfo: [AnyHashable: Any]) {
        var contentData: [AnyHashable: Any] = [:]
        for (key, value) in contentInfo {
            contentData[key] = value
        }
        let action: String = Constants.Action.ViewPDF
        contentData[Constants.Events.ProductInfo] = "{\(productInfo)}"
        contentData[Constants.Events.PDFView]     = "1"
        contentData[Constants.Events.Name]        = action
        trackAction(action, actionContentData: contentData)
    }
    
    func contentAddRemoveToReadingList(_ addRemove: Bool, productInfo: String, contentInfo: [AnyHashable: Any]) {
        var action: String
        var contentData: [AnyHashable: Any] = [:]
        for (key, value) in contentInfo {
            contentData[key] = value
        }
        contentData[Constants.Events.ProductInfo] = productInfo
        if addRemove == true {
            action = Constants.Action.ContentAddArticleToList
            contentData[Constants.Events.Name] = action
            contentData[Constants.Events.ContentSaveToList] = "1"
        } else {
            action = Constants.Action.ContentRemoveArticleFromList
            contentData[Constants.Events.Name] = action
            contentData[Constants.Events.ContentRemoveFromList] = "1"
        }
        trackAction(action, actionContentData: contentData)
    }
    
    func searchAnalyticsTagAction(_ searchAction: SearchAction, criteria: String, clickPosition: Int) {
        var action: String = Constants.Action.SearchResults
        var contentData: [AnyHashable: Any] = [:]
        switch searchAction {
        case .resultClick:
            contentData[Constants.Events.SearchResultClick] = "1"
            contentData[Constants.Search.ClickPosition] = "\(clickPosition)"
            action = Constants.Action.SearchResultsClick
        case .save:
            break
        }
        contentData[Constants.Search.Criteria] = "\(criteria)"
        trackAction(action, actionContentData: contentData)
    }
    
    func searchAnalyticsTagScreen(_ clickPosition: Int, criteria: String, currentResults: Int, totalResults: Int, isNewSearch: Bool) {
        var contentData: [AnyHashable: Any] = [:]
        if isNewSearch == true {
            contentData[Constants.Search.NewSearch]      = "1"
        }
        contentData[Constants.Search.TotalResults]   = "\(totalResults)"
        contentData[Constants.Search.CurrentResults] = "\(currentResults)"
        contentData[Constants.Search.Criteria]       = "\(criteria.lowercased())"
        contentData[Constants.Search.Type]           = Constants.Content.ValueSearchType
        //contentData[Constants.Search.ClickPosition]  = "\(clickPosition)"
        contentData[AnalyticsConstant.TagPageType]   = Constants.Page.Type.sp_st
        trackState(Constants.Page.Name.SearchResults, stateContentData: contentData)
    }
    
    func getNetworkInfoValueForAnalytics() -> String {
        return Constants.Page.ConnectionType.Online
    }
    
    // MARK: - Create -
    
    func createJournalInfo(societyname journalName: String, speciality: String?, section: String?, journalISSN: String?, issueNo: String?, volumeNo: String?) -> String {
        var journalInfo = ""
        journalInfo += journalName
        journalInfo += "|"
        journalInfo += speciality  != .none ? speciality!  : Constants.Default.No.Speciality
        journalInfo += "|"
        journalInfo += section     != .none ? section!     : Constants.Default.No.Section
        journalInfo += "|"
        journalInfo += journalISSN != .none ? journalISSN! : Constants.Default.No.ISSN
        journalInfo += "|"
        journalInfo += issueNo     != .none ? issueNo!     : Constants.Default.No.IssueNumber
        journalInfo += "|"
        journalInfo += volumeNo    != .none ? volumeNo!    : Constants.Default.No.VolumeNumber
        return journalInfo
    }
    
    @available(*, deprecated: 0.2) func createMapForContentUsage(_ contentAccessType: String?, contentID: String?, bibliographic: [String]?, contentFormat: String?, contentInnovationName: String?, contentStatus: String?, contentTitle: String?, contentType: String?, contentViewState: String?) -> [AnyHashable: Any] {
        var contentUsage: [AnyHashable: Any] = [:]
        if let _contentAccessType = contentAccessType {
            contentUsage[Constants.Content.AccessType] = "article:\(_contentAccessType.lowercased()):standard"
        }
        if let _contentID = contentID {
            contentUsage[Constants.Content.ID] = "jb:pii:\(_contentID)"
        }
        if let _bibliographic = bibliographic {
            if _bibliographic.count > 2 {
                contentUsage[Constants.Content.BibliographicInfo] = "none^none^none^none^\(_bibliographic[0])^\(_bibliographic[1])^none^none"
            }
        }
        if let _contentFormat = contentFormat {
            contentUsage[Constants.Content.Format] = _contentFormat
        }
        if let _contentInnovationName = contentInnovationName {
            contentUsage[Constants.Content.InnovationName] = _contentInnovationName
        }
        if let _contentStatus = contentStatus {
            contentUsage[Constants.Content.Status] = _contentStatus
        }
        if let _contentTitle = contentTitle {
            contentUsage[Constants.Content.Title] = _contentTitle.lowercased()
        }
        if let _contentType = contentType {
            contentUsage[Constants.Content.Type] = _contentType
        }
        if let _contentViewState = contentViewState {
            contentUsage[Constants.Content.ViewState] = _contentViewState
        }
        return contentUsage
    }
    
    func createMapForContentUsage(_ contentAccessType: String?, contentID: String?, bibliographic: String?, contentFormat: String?, contentInnovationName: String?, contentStatus: String?, contentTitle: String?, contentType: String?, contentViewState: String?) -> [String: AnyObject] {
        var contentUsage: [String: AnyObject] = [:]
        if let _contentAccessType = contentAccessType {
            contentUsage[Constants.Content.AccessType] = "article:\(_contentAccessType.lowercased()):standard" as AnyObject?
        }
        if let _contentID = contentID {
            contentUsage[Constants.Content.ID] = "jb:pii:\(_contentID)" as AnyObject?
        }
        if let _bibliographic = bibliographic {
            contentUsage[Constants.Content.BibliographicInfo] = _bibliographic as AnyObject?
        }
        if let _contentFormat = contentFormat {
            contentUsage[Constants.Content.Format] = _contentFormat as AnyObject?
        }
        if let _contentInnovationName = contentInnovationName {
            contentUsage[Constants.Content.InnovationName] = _contentInnovationName as AnyObject?
        }
        if let _contentStatus = contentStatus {
            contentUsage[Constants.Content.Status] = _contentStatus as AnyObject?
        }
        if let _contentTitle = contentTitle {
            contentUsage[Constants.Content.Title] = _contentTitle.lowercased() as AnyObject?
        }
        if let _contentType = contentType {
            contentUsage[Constants.Content.Type] = _contentType as AnyObject?
        }
        if let _contentViewState = contentViewState {
            contentUsage[Constants.Content.ViewState] = _contentViewState as AnyObject?
        }
        return contentUsage
    }
    
    // MARK: - Bibliography -
    
    @available(*, deprecated: 0.2) func createBibliographicInfo(_ bibliographic: [String]) -> [String: AnyObject] {
        var hashMap: [String: AnyObject] = [:]
        hashMap[Constants.Content.BibliographicInfo] = "none^none^none^none^\(bibliographic[0])^\(bibliographic[1])^none^none" as AnyObject?
        return hashMap
    }
    
    func createBibliographicInfo(_ volume: String?, issue: String?) -> String {
        var response = "none^none^none^none^"
        if let _volume = volume {
            response += _volume + "^"
        } else {
            response += "none^"
        }
        
        if let _issue = issue {
            response += _issue + "^"
        } else {
            response += "none^"
        }
        
        response += "none^none"
        
        return response
    }
    
    // MARK: - Content Id -
    
    @available(*, deprecated: 0.2) func createContentIDInfo(_ contentID: String) -> [String: AnyObject] {
        var hashMap: [String: AnyObject] = [:]
        hashMap[Constants.Content.ID] = "jb:pii:\(contentID)" as AnyObject?
        return hashMap
    }
    
    func contentIdInfo(_ contentId: String) -> String {
        return "jb:pii:\(contentId)"
    }
    
    // MARK: - Product Info -
    
    /*@available(*, deprecated=0.2) func createProductInforForEventAction(articleInfoId: String?, fileFormat: String?, contentType: String?, bibliographicInfo: [String]?, articleStatus: String?, articleTitle: String?, accessType: String?) -> String {
        var returnString = ""
        if let _articleInfoId = articleInfoId {
            returnString += Constants.Events.ProductVariableProductid + _articleInfoId + ";;;;"
        }
        if let _fileFormat = fileFormat {
            returnString += Constants.Events.ProductVariableFileFormat + _fileFormat + "|"
        }
        if let _contentType = contentType {
            returnString += Constants.Events.ProductVariableContentType + _contentType + "|"
        }
        if let _bibliographicInfo = bibliographicInfo {
            if _bibliographicInfo.count == 2 {
                let volumeNo = _bibliographicInfo[0] == "" ? "none" : _bibliographicInfo[0]
                let issueNo = _bibliographicInfo[1]  == "" ? "none" : _bibliographicInfo[1]
                returnString += "none^none^none^none^\(volumeNo)^\(issueNo)^none^none" + "|"
            }
        }
        if let _articleStatus = articleStatus {
            returnString += Constants.Events.ProductVariableArticleStatus + _articleStatus + "|"
        }
        if let _articleTitle = articleTitle {
            returnString += Constants.Events.ProductVariableArticleTitle + _articleTitle + "|"
        }
        if let _accessType = accessType {
            returnString += Constants.Events.ProductVariableAccessType + "article:\(_accessType):standard"
        }
        return returnString
    }*/
    
    func createProductInforForEventAction(_ articleInfoId: String?, fileFormat: String?, contentType: String?, bibliographicInfo: String?, articleStatus: String?, articleTitle: String?, accessType: String?) -> String {
        var returnString = ""
        if let _articleInfoId = articleInfoId {
            returnString += Constants.Events.ProductVariableProductid + _articleInfoId + ";;;;"
        }
        if let _fileFormat = fileFormat {
            returnString += Constants.Events.ProductVariableFileFormat + _fileFormat + "|"
        }
        if let _contentType = contentType {
            returnString += Constants.Events.ProductVariableContentType + _contentType + "|"
        }
        if let _bibliographicInfo = bibliographicInfo {
            returnString += Constants.Events.ProductVariableBibliographic + _bibliographicInfo + "|"
        }
        if let _articleStatus = articleStatus {
            returnString += Constants.Events.ProductVariableArticleStatus + _articleStatus + "|"
        }
        if let _articleTitle = articleTitle {
            returnString += Constants.Events.ProductVariableArticleTitle + _articleTitle + "|"
        }
        if let _accessType = accessType {
            returnString += Constants.Events.ProductVariableAccessType + "article:\(_accessType):standard"
        }
        return returnString.lowercased()
    }
    
    // MARK: - Article -
    
    func setArticleDetailsContextInfo(_ articleDetailsContextInfo: [String: AnyObject]) {
        self.articleDetailsContextInfo = articleDetailsContextInfo
    }
    
    func getArticleDetailsContextInfo() -> [String: AnyObject] {
        return articleDetailsContextInfo
    }
    
    // MARK: - Config -
    
    fileprivate func createConfig(analyticsType type: AnalyticsType) -> [AnyHashable: Any] {
        var bundleAnalyticsConfig: [AnyHashable: Any] = [:]
        bundleAnalyticsConfig[AnalyticsConstant.ExtraConfigEnv]      = AnalyticsConstant.AppMode
        bundleAnalyticsConfig[AnalyticsConstant.ExtraConfigKey]      = readConfigurationJSONFromAssets()
        bundleAnalyticsConfig[AnalyticsConstant.TagPageBusinessUnit] = Constants.Default.Page.BusinessUnit
        bundleAnalyticsConfig[AnalyticsConstant.TagPageLanguage]     = Constants.Default.Page.Language
        bundleAnalyticsConfig[AnalyticsConstant.TagProductName]      = Constants.Default.Page.ProductName
        return bundleAnalyticsConfig
    }
    
    fileprivate func readConfigurationJSONFromAssets() -> String {
        let path = Bundle.main.path(forResource: "ADBMobileConfig", ofType: ".json")!
        return try! NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
    }

    /*
    func trackState(pageName: String) {
        AnalyticsManager.MainInstance.trackState(pageName)
    }

    func trackAction(actionName: String) {
        AnalyticsManager.MainInstance.tagAction(actionName)
    }

    func createJournalInfo(societyname societyName: String?, speciality: String?, section: String?, journalISSN: String?, issueNo: String?, volumeNo: String?) -> String {
        var journalInfo = ""
        
        if let _societyName = societyName {
            journalInfo += _societyName.lowercaseString
        } else {
            journalInfo += ""
        }
        
        journalInfo += "|"
        
        if let _speciality = speciality {
            journalInfo += _speciality
        } else {
            journalInfo += Constants.Default.No.Speciality
        }
        
        journalInfo += "|"
        
        if let _section = section {
            journalInfo += _section
        } else {
            journalInfo += Constants.Default.No.Section
        }
        
        journalInfo += "|"
        
        if let _journalISSN = journalISSN {
            journalInfo += _journalISSN
        } else {
            journalInfo += Constants.Default.No.ISSN
        }
        
        journalInfo += "|"
        
        if let _issueNo = issueNo {
            journalInfo += _issueNo
        } else{
            journalInfo += Constants.Default.No.IssueNumber
        }
        
        journalInfo += "|"
        
        if let _volumeNo = volumeNo {
            journalInfo += _volumeNo
        } else {
            journalInfo += Constants.Default.No.VolumeNumber
        }
        
        return journalInfo
    }

    func createMapForContentUsage(contentAccessType: String?, contentId: String?, bibliographic: [String]?, contentFormat: String?, contentInnovationName: String?, contentStatus: String?, contentTitle: String?, contentType: String?, contentViewState: String?) -> [NSObject: AnyObject] {
        var hashMapContentUsage: [NSObject: AnyObject] = [:]
        if let _contentAccessType = contentAccessType {
            hashMapContentUsage[Constants.Content.AccessType] = "article:{\(_contentAccessType)}:standard"
        }
        if let _contentId = contentId {
            hashMapContentUsage[Constants.Content.ID] = "jb:pii:{\(_contentId)}"
        }
        if let _bibliographic = bibliographic {
            if _bibliographic.count == 2 {
                hashMapContentUsage[Constants.Content.BibliographicInfo] = "none^none^none^none^\(_bibliographic[0])^\(_bibliographic[1])^none^none"
            }
        }
        if let _contentFormat = contentFormat {
            hashMapContentUsage[Constants.Content.Format] = _contentFormat
        }
        if let _contentInnovationName = contentInnovationName {
            hashMapContentUsage[Constants.Content.InnovationName] = _contentInnovationName
        }
        if let _contentStatus = contentStatus {
            hashMapContentUsage[Constants.Content.Status] = _contentStatus
        }
        if let _contentTitle = contentTitle {
            hashMapContentUsage[Constants.Content.Title] = _contentTitle
        }
        if let _contentType = contentType {
            hashMapContentUsage[Constants.Content.Type] = _contentType
        }
        if let _contentViewState = contentViewState {
            hashMapContentUsage[Constants.Content.ViewState] = _contentViewState
        }
        return hashMapContentUsage
    }
    
    func createBibliographicInfo(bibliographic: [String]) -> [NSObject: AnyObject] {
        var hashMap: [NSObject: AnyObject] = [:]
        if bibliographic.count == 2 {
            hashMap[Constants.Content.BibliographicInfo] = "none^none^none^none^\(bibliographic[0])^\(bibliographic[1])^none^none"
        }
        return hashMap
    }

    func createContentIdInfo(contentId: String) -> [NSObject: AnyObject] {
        let hashMap: [NSObject: AnyObject] = [
            Constants.Content.ID : "jb:pii:\(contentId)"
        ]
        return hashMap
    }

    func mediaContentAnalyticsTagAction(productInfo: String, additionalInfo: String, mediaType: Int) {
        var type = ""
        if mediaType == 1 {
            type = Analytics.MediaTypeAudio
        } else {
            type = Analytics.MediaTypeVideo
        }
        let contentData = [
            Analytics.EventProductInfo : Analytics.ActionProductInfo(productInfo),
            Analytics.EventContentPlay : "1",
            Analytics.EventName        : Analytics.ActionContentPlay(additionalInfo),
            Analytics.ContentMediaType : type
        ]
        let action = Analytics.ActionContentPlay(additionalInfo)
        trackAction(action, actionContentData: contentData)
    }
    */

}
