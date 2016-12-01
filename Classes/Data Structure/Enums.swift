//
//  Enums.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 8/30/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

enum AccessType: String {
    case FreeAccess = "Free Access"
    case FreeAbstract = "Free Abstract"
}

enum ArticleFormatType: String {
    case HTML = "html"
    case PDF = "pdf"
}

enum DisplayFileType: String {
    case Figure = "Figure"
    case Table = "Table"
    case Audio = "Audio"
    case Video = "Video"
    case Other = "Other"
}

enum DownloadStatus: Int {
    case notAvailable = -1
    case notDownloaded = 0
    case downloading = 1
    case downloadFailed = 2
    case downloaded = 3
}

enum HighlightDisplayType: String {
    case LatestIssue = "Latest Issue"
    case TopArticles = "Top Articles"
}

enum FileExtensionType: String {
    
    init(type: String) {
        if type == "jpg" {
            self = .JPG
        } else if type == "png" {
            self = .PNG
        } else if type == "gif" {
            self = .GIF
        } else if type == "mp3" {
            self = .MP3
        } else if type == "mp4" {
            self = .MP4
        } else if type == "mov" {
            self = .MOV
        } else if type == "pdf" {
            self = .PDF
        } else if type == "html" {
            self = .HTML
        } else {
            self = .NA
        }
    }
    
    case JPG = "jpg"
    case PNG = "png"
    case GIF = "gif"
    case MP3 = "mp3"
    case MP4 = "mp4"
    case MOV = "mov"
    case PDF = "pdf"
    case HTML = "html"
    case NA = "na"
}

enum MediaFileType: String {
    case Video = "Video"
    case Audio = "Audio"
    case Document = "Document"
    case Presentation = "Presentation"
    case Spreadsheet = "Spreadsheet"
    case PDF = "PDF"
    case Image = "Image"
    case Table = "Table"
    case Other = "Other"
    case NoFileType = "NoFileType"
    
    static func TypeFromString(_ type: String) -> MediaFileType? {
        switch type {
        case Image.rawValue:
            return .Image
        case Table.rawValue:
            return .Table
        case Audio.rawValue:
            return .Audio
        case Video.rawValue:
            return .Video
        case Document.rawValue:
            return .Document
        case Presentation.rawValue:
            return .Presentation
        case Spreadsheet.rawValue:
            return .Spreadsheet
        case PDF.rawValue:
            return .PDF
        case Other.rawValue:
            return .Other
        default:
            return .NoFileType
        }
    }
}

enum ModelType: String {
    case Article = "Article"
    case Issue   = "Issue"
    case Journal = "Journal"
}

enum OAIdentifier: Int, CustomStringConvertible {
    
    case noIdentifier = 0
    case openAccess = 1
    case openAccessSince = 2
    case openAccessSinceWithOpenArchive = 3
    case supportOpenAccess = 4
    case supportOpenAccessWithOpenArchive = 5
    case openAccessFundedBy = 6
    case openArchive = 7
    case openAccessFundedByIssue = 8
    
    var description: String {
        switch self {
        case .noIdentifier:
            return "Not Open Access"
        case .openAccess:
            return "Open Access"
        case .openAccessSince:
            return "Open Access Since"
        case .openAccessSinceWithOpenArchive:
            return "Open Access Since With Open Archive"
        case .supportOpenAccess:
            return "Supports Open Access"
        case .supportOpenAccessWithOpenArchive:
            return "Supports Open Access With Open Archive"
        case .openAccessFundedBy:
            return "Open Access Funded By"
        case .openArchive:
            return "Open Archive"
        case .openAccessFundedByIssue:
            return "Open Access Funded By Issue"
        }
    }
}

enum ViewDisplayStatus {
    case load
    case show
    case hide
    case destroy
}

enum FileSizeType {
    case abstractSupplement
    case fullText
    case fullTextSupplement
    case allSupplement
    case fullTextAndSupplement
}

enum MemoryWarning {
    case none
    case oneGB
    case fiveGB
}
