 /*
 * Notifications
*/

import Foundation
 
 extension NSNotification.Name {
    static let CoverImageDownloadUpdated = NSNotification.Name(rawValue: "notification.download.coverImage.updated")
    static let AbstractDownloadUpdated = NSNotification.Name(rawValue: "notification.download.abstract.updated")
    static let FullTextDownloadUpdated = NSNotification.Name(rawValue: "notification.download.fulltText.updated")
    static let FullTextSupplementDownloadUpdated = NSNotification.Name(rawValue: "notification.download.fullTextSupplement.updated")
    static let MediaDownloadUpdated = NSNotification.Name(rawValue: "notification.download.media.updated")
    
    static let UpdateArticleWithJavascript = NSNotification.Name(rawValue: "notification.article.updateWithJavascript")
    
    static let ShowReadingListDialogue = NSNotification.Name(rawValue: "notification.readingList.showDialogue")
    static let HideReadingListDialogue = NSNotification.Name(rawValue: "notification.readingLIst.hideDialogue")
 }
 
struct Notification {
    
    struct Announcement {
        static let Updated = "notification.announcement.updated"
    }
    
    struct Font {
        static let DidChange = "notification.font.didchange"
    }
    
    struct Download {
        struct CoverImage {
            static let started = "notification.download.fulltextsupplement.started"
            static let Successful = "notification.download.coverimage.successful"
            static let Failure = "notification.download.coverimage.failure"
        }
        
        struct FullText {
            static let started = "notification.download.fulltext.started"
            static let Successful = "notification.download.fulltext.successful"
            static let UpdateDownloadedSize = "notification.download.fulltext.updatedownloadedsize"
            static let Failure = "notification.download.fulltext.failure"
            static let Updated = "notification.download.fulltext.updated"
        }
        
        struct FullTextSupplement {
            static let Started = "notification.download.fulltextsupplement.started"
            static let Successful = "notification.download.fulltextsupplement.successful"
            static let UpdateDownloadedSize = "notification.download.fulltextsupplement.updatedownloadedsize"
            static let Failure = "notification.download.fulltextsupplement.failure"
        }
        
        struct Abstract {
            static let started = "notification.download.abstract.started"
            static let Successful = "notification.download.abstract.successful"
            static let UpdateDownloadedSize = "notification.download.abstract.updatedownloadedsize"
            static let Failure = "notification.download.abstract.failure"
        }
        
        struct AbstractSupplement {
            static let started = "notification.download.abstractsupplement.started"
            static let Successful = "notification.download.abstractupplement.successful"
            static let UpdateDownloadedSize = "notification.download.abstractsupplement.updatedownloadedsize"
            static let Failure = "notification.download.abstractsupplement.failure"
        }
        
        struct Media {
            static let Updated = "notification.download.media.updated"
            static let Started = "notification.download.media.started"
            static let Successful = "notification.download.media.successful"
            static let UpdateDownloadedSize = "notification.download.media.updatedownloadedsize"
            static let Failure = "notification.download.media.failure"
        }
        
        struct Issue {
            static let started = "notification.download.issue.started"
            static let DownloadStarted = "notification.download.issue.downloadstarted"
            static let UpdateCount = "notification.download.issue.updatecount"
            static let DownloadComplete = "notification.download.issue.downloadcomplete"
        }
        
        struct AIP {
            static let Started = "notification.download.aip.started"
            static let Updated = "notification.download.aip.update"
            static let Completed = "notification.download.aip.completed"
            static let Failure = "notification.download.aip.failure"
        }
        
        struct Article {
            static let Started = "notification.download.article.started"
            static let Updated = "notification.download.article.updated"
            static let Finished = "notification.download.article.finished"
        }
        
        struct DMSection {
            static let Updated = "notification.download.dmsection.updated"
        }
        
        struct DMItem {
            static let Updated = "notification.download.dmitem.updated"
        }
        
    }
    
    struct Article {
        static let UpdateWithJavascript = "notification.article.updatewithjavascript"
    }
    
    struct Authentication {
        static let Login = "notification.authentication.login"
        static let Logout = "notification.authentication.logout"
    }
    
}
