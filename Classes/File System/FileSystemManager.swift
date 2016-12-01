//
//  FileSystemManager.swift
//  JATV3
//
//  Created by Sharkey, Justin (ELS-CON) on 7/6/15.
//  Copyright (c) 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit

/*enum FileSystemError: ErrorType {
    case SaveError
}*/

open class FileSystemManager {
    
    static open let sharedInstance = FileSystemManager()
    
    @discardableResult func setupJournal(_ journal: Journal) -> Bool {
        if setupJournalPath(journal) == false {
            return false
        }
        if setupJournalArticlesPath(journal) == false {
            return false
        }
        if setupJournalCoverImages(journal) == false {
            return false
        }
        if setupJournalBrandImagesPath(journal) == false {
            return false
        }
        if setupJournalAbstractsPath(journal) == false {
            return false
        }
        if setupPDFPath(journal) == false {
            return false
        }
        return true
    }
    
    // MARK: - Cover Image -
    
    @discardableResult func setupJournalCoverImages(_ journal: Journal) -> Bool {
        if pathExists(journal.coverImagesPath) == true {
            return true
        }
        if createPath(journal.coverImagesPath) == true {
            return true
        }
        return false
    }
    
    // MARK: - Journal -
    
    func setupJournalPath(_ journal: Journal) -> Bool {
        if pathExists(journal.basePath) == true {
            return true
        }
        if createPath(journal.basePath) == true {
            return true
        }
        return false
    }
    
    // MARK: - Articles -
    
    func setupJournalArticlesPath(_ journal: Journal) -> Bool {
        if pathExists(journal.fullTextPath) == true {
            return true
        }
        if createPath(journal.fullTextPath) == true {
            return true
        }
        return false
    }
    
    func setupJournalAbstractsPath(_ journal: Journal) -> Bool {
        if pathExists(journal.abstractsPath) == true {
            return true
        }
        if createPath(journal.abstractsPath) == true {
            return true
        }
        return false
    }
    
    @discardableResult func deleteArticle(_ article: Article) -> Bool {
        do {
            if fileExists(article.fulltextBasePath) {
                try FileManager.default.removeItem(atPath: article.fulltextBasePath)
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
            return false
        }
        return true
    }
    
    func deleteArticleMultimedia(_ article: Article) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: article.fulltextSupplementDirectory)
        } catch let error as NSError {
            log.error(error.localizedDescription)
            return false
        }
        return true
    }
    
    func deleteAbstractMultimedia(_ article: Article) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: article.abstractSupplementDirectory)
        } catch let error as NSError {
            log.error(error.localizedDescription)
            return false
        }
        return true
    }
    
    // MARK: - Brand Images -
    
    func setupJournalBrandImagesPath(_ journal: Journal) -> Bool {
        if pathExists(journal.brandImagesPath) == true {
            return true
        }
        if createPath(journal.brandImagesPath) == true {
            return true
        }
        return false
    }
    
    func journalBrandImagePath(_ journal: Journal, isPortrait portrait:Bool) -> String? {
        var fileName = journal.brandImagesPath + "Journal_branding_graphic_ipad"
        if portrait {
            fileName += "_P.png"
        } else {
            fileName += "_L.png"
        }
        if pathExists(fileName) {
            return fileName
        }
        return nil
    }
    
    // MARK: - PDF -
    
    func setupPDFPath(_ journal: Journal) -> Bool {
        if pathExists(journal.pdfPath) == true {
            return true
        }
        if createPath(journal.pdfPath) == true {
            return true
        }
        return false
    }
    
    // MARK: - Other -
    
    func createPath(_ path: String) -> Bool {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return false
    }
    
    func pathExists(_ path: String) -> Bool {
        var isDirectory: ObjCBool = true
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            return true
        } else {
            return false
        }
    }
    
    func fileExists(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            return true
        } else {
            return false
        }
    }
    
    @discardableResult func deleteFile(_ path: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch let error as NSError {
            log.error(error.localizedDescription)
            return false
        }
    }
}
