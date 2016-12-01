//
//  AnalyticsConstants.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/2/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class AnalyticsConstant {
    static let AppMode              = "DEV"
    static let FileName             = "ADBMobileConfig"
    
    static let ExtraConfigEnv       = "extra_config_env"
    static let ExtraConfigKey       = "extra_config_key"
    static let DateFormat           = "HH:mm aa EEEE"
    static let TagTimeStart         = "TimeUntilFirstProductView"
    static let TagJournalInfo       = "journal.info"
    static let TagPageCMSName       = "page.cmsName"
    static let TagPageBusinessUnit  = "page.businessUnit"
    static let TagPageDateTime      = "page.dateTime"
    static let TagPageLanguage      = "page.language"
    static let TagPageName          = "page.name"
    static let TagPagePrevious      = "page.previous"
    static let TagProductName       = "page.productName"
    static let TagPageType          = "page.type"
    static let TagPageAppConnection = "page.appConnection"
    static let TagVisitorAccessType = "visitor.accessType"
    static let TagVisitorUserId     = "visitor.userId"
}

struct Constants {
    
    struct ScreenType {
        static let Figures = "figure"
        static let Notes = "notes"
        static let Videos = "videos"
        static let Audios = "audios"
        static let Others = "others"
        static let Citation = "citation"
        static let Tables = "tables"
        static let FullText = "fulltext"
        static let Abstract = "abstract"
        static let Outline = "outline"
    }
    
    struct Default {
        struct Page {
            static let CMSName      = "squiz"
            static let BusinessUnit = "els:rp:jbs"
            static let Language     = "en"
            static let ProductName  = "jb"
        }
        struct Visitor {
            static let UserId       = "ae:278394f8c2c2449fd97b9452fa0563"
            static let AccessType   = "jb:jb-style-b:%1$s-0:jb-othr"
        }
        struct No {
            static let Speciality   = "no speciality"
            static let Section      = "no section"
            static let ISSN         = "no issn"
            static let IssueNumber  = "no issue #"
            static let VolumeNumber = "no volume #"
        }
    }
    struct Page {
        struct ConnectionType {
            static let Offline      = "offline"
            static let Online       = "online"
        }
        struct Name {
            static let Splash = "jb:splash"
            static let Home = "jb:home"
            static let Abstract = "jb:abstract"
            static let Fulltext = "jb:fulltext"
            static let FulltextCitation = "jb:fulltext:citation"
            static let FulltextOutline = "jb:fulltext:outline"
            static let FulltextAudio = "jb:fulltext:audio"
            static let FulltextAudioPlay = "jb:fulltext:audio:play"
            static let FulltextVideo = "jb:fulltext:video"
            static let FulltextViewPlay = "jb:fulltext:video:play"
            static let FulltextTable = "jb:fulltext:table"
            static let FulltextFigures = "jb:fulltext:figures"
            static let AIP = "jb:inpress"
            static let AimsScope = "jb:aimscope"
            static let EditorialBoard = "jb:editorsboard"
            static let ForgotPassword = "jb:personal:changepw"
            static let Info = "jb:info"
            static let InfoFAQ = "jb:info:faq"
            static let InfoSupport = "jb:info:support"
            static let InfoFeedback = "jb:info:feedback"
            static let InfoTC = "jb:info:termsconditions"
            static let Settings = "jb:settings"
            static let SettingsPush = "jb:settings:pushnotifications"
            static let SettingsUsage = "jb:settings:usage"
            static let PushLaunch = "jb:pushnotifications:launch"
            static let Issue = "jb:issue"
            static let AllIssues = "jb:issues"
            static let ReadingList = "jb:readinglist"
            static let ReadingListEdit = "jb:readinglist:edit"
            static let ReadingEmpty = "jb:readinglist:empty"
            static let Login = "jb:login"
            static let Notes = "jb:notes"
            static let Preview = "jb:current"
            static let SearchResults = "jb:search:results"
            static let IssueAccessOptions = "jb:ecommerce:appaccessoptions"
            static let topArticles = "jb:mostreadarticles"
        }
        struct `Type` {
            static let np_gp = "np-gp"
            static let np_hp = "np-hp"
            static let pu_ci = "pu-ci"
            static let pu_pi = "pu-pi"
            static let ap_up = "ap-up"
            static let ap_lp = "ap-lp"
            static let ap_my = "ap-my"
            static let sp_st = "sp-st"
            static let cp_ci = "cp-ci"
            static let cp_ca = "cp-ca"
            static let ec_ss = "ec-ss"
        }
    }
    struct Content {
        static let AccessType = "content.accessType"
        static let BibliographicInfo = "content.bibliographicInfo"
        static let Format = "content.format"
        static let ID = "content.id"
        static let InnovationName = "content.innovationName"
        static let Status = "content.status"
        static let Title = "content.title"
        static let `Type` = "content.type"
        static let ViewState = "content.viewState"
        static let MediaType = "content.mediaType"
        static let ValueViewStateLogin = "login"
        static let ValueViewStateUpsell = "upsell"
        static let ValueType = "xocs:scope-%1$s"
        static let ValueTypeAbstract = "xocs:scope-abstract"
        static let ValueTypeFull = "xocs:scope-full"
        static let ValueTypeStreaming = "streaming"
        static let ValueTypeDownload = "downloaded"
        static let ValueFormatHTML = "mime-html"
        static let ValueFormatPDF = "mime-pdf"
        static let ValueId = "jb:pii:$1$s"
        static let ValueAccessType = "article:%1$s:standard"
        static let ValueBibliographicInfo = "none^none^none^none^%1$s^%2$s^none^none"
        static let ValueSearchType = "jb:keyword:explicit:general search"
    }
    struct Events {
        static let ContentDownload = "event.contentDownload"
        static let ContentPlay = "event.contentPlay"
        static let Name = "event.name"
        static let ContentInnovationName = "content.innovationName"
        static let ContentInnovationClick = "content.innovationClick"
        static let ContentTurnAway = "event.contentTurnaway"
        static let ContentShare = "event.contentShare"
        static let ContentLogin = "event.loginView"
        static let ProductInfo = "&&products"
        static let ProductVariableProductid = ";jb:pii:"
        static let ProductVariableFileFormat = "eVar17="
        static let ProductVariableContentType = "eVar20="
        static let ProductVariableBibliographic = "eVar28="
        static let ProductVariableArticleStatus = "eVar73="
        static let ProductVariableArticleTitle = "evar75="
        static let ProductVariableAccessType = "eVar80="
        static let SearchResultClick = "event.searchResultClick"
        static let SearchSave = "event.saveSearch"
        static let LoginSuccessful = "event.loginSuccess"
        static let AbstractView = "event.abstractView"
        static let FullView = "event.fullView"
        static let ContentView = "event.contentView"
        static let HTMLView = "event.htmlView"
        static let ContentPDFView = "event.pdfView"
        static let ContentSaveToList = "event.saveToList"
        static let ContentRemoveFromList = "event.removeFromList"
        static let ContentUpsell = "event.upsellView"
        static let PDFView = "event.pdfView"
    }
    struct Search {
        static let Criteria = "search.criteria"
        static let CurrentResults = "search.currentResults"
        static let NewSearch = "event.newSearch"
        static let TotalResults = "search.totalResults"
        static let `Type` = "search.type"
        static let ClickPosition = "search.clickPosition"
    }
    struct Action {
        static let ProductInfo = "{%1$s}"
        static let ContentDownload = "content download"
        static let ContentPlay = "content play %1$s"
        static let ContentAddNoteToArticle = "add note to article"
        static let ContentNavigateToNextPrevious = "navigate to article:{%1$s}"
        static let ContentEmailNoteToArticle = "add note to article"
        static let ContentInnovationClick = "content innovation click"
        static let ContentRemoveArticleFromList = "remove from list"
        static let ContentAddArticleToList = "save to list"
        static let ContentShare = "content share"
        static let ContentTurnAway = "content turnaway"
        static let ContentLogin = "login"
        static let Next = "next"
        static let Previous = "previous"
        static let SearchResults = "search:results"
        static let SearchSaveResults = "save search"
        static let SearchResultsClick = "search result click"
        static let ContentLoginSuccess = "login success"
        static let ContentChangeFontSize = "change font size"
        static let ContentSubmitFeedback = "submit feedback"
        static let ContentDeleteAIP = "settings:delete aip"
        static let ContentDeleteIssue = "settings:delete issue"
        static let ViewPDF = "view pdf"
    }
    struct Analytics {
        static let PreferenceMultiJournal = "isMultiJournalAnalyticsPreference"
    }
}









struct Analytics {
    
    static let PreferenceMultiJournal       = "isMultiJournalAnalyticsPreference"
    
    static let ActionContentInnovationClick = "content innovation click"
    
    static func ActionContentPlay(_ one: String) -> String { return "content play \(one)" }
    static func ActionProductInfo(_ one: String) -> String { return "\(one)" }
    
    static let ContentMediaType = "content.mediaType"
    
    static let EventContentPlay             = "event.contentPlay"
    static let EventProductInfo             = "&&products"
    static let EventContentInnovationName   = "content.innovationName"
    static let EventContentInnovationClick  = "content.innovationClick"
    static let EventName                    = "event.name"
    
    static let MediaTypeAudio = "Audio"
    static let MediaTypeVideo = "Video"
    
    
    
    
    
    
    
    
}
