//
//  DatabaseManager.swift
//  ContentKit
//
//  Created by Sharkey, Justin (ELS-CON) on 10/9/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import CoreData
import SWXMLHash

open class DatabaseManager: NSObject {
    
    open static let SharedInstance = DatabaseManager()
    
    open let moc: NSManagedObjectContext?
    
    
    
    // MARK: - Initializers -
    
    override init() {
        self.moc = Database.sharedInstance.managedObjectContext!
    }
    
    var numberOfJournals: Int {
        let journals = getAllJournals()
        return journals.count
    }
    
    // MARK: - Top Articles -
    
    func getNewTopArticle() -> TopArticle {
        return NSEntityDescription.insertNewObject(forEntityName: "TopArticle", into: moc!) as! TopArticle
    }
    
    func removeAllTopArticles() {
        let fetchRequest = NSFetchRequest<TopArticle>(entityName: "TopArticle")
        do {
            let results = try self.moc!.fetch(fetchRequest)
            for topArticle in results {
                moc?.delete(topArticle)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - IAP -
    
    func getAllNonConsumableProductIds() -> [String] {
        let fetchRequest: NSFetchRequest = NSFetchRequest<Issue>(entityName: "Issue")
        do {
            if let results = try self.moc?.fetch(fetchRequest) {
                var productIds: [String] = []
                for issue in results {
                    if let productId = issue.productId {
                        productIds.append(productId)
                    }
                }
                return productIds
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getSubscriptionIds() -> [String] {
        let fetchRequest = NSFetchRequest<Journal>(entityName: "Journal")
        do {
            if let results = try self.moc?.fetch(fetchRequest) {
                var productIds: [String] = []
                for issue in results {
                    if let subscriptionId = issue.subscriptionId {
                        productIds.append(subscriptionId)
                    }
                    // Need Free SubscriptionId Too
                }
                return productIds
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func updatePurchasedInformationWithProductId(_ productId: String) {
        let fetchRequest = NSFetchRequest<Issue>(entityName: "Issue")
        fetchRequest.predicate = NSPredicate(format: "productId = %@", productId)
        do {
            let results = try self.moc!.fetch(fetchRequest)
            for issue in results {
                performChangesAndSave({ 
                    issue.purchased = true
                })
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func updatePrice(_ price: String, forSubscriptionId subscriptionId: String) {
        
    }
    
    func updatePrice(_ price: String, forProductId productId: String) {
        
    }
    
    // MARK: - Journal -
    
    open func getAllArticlesforJournal(_ journal: Journal) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "journal = %@", journal)
        do {
            let articles = try moc!.fetch(fetchRequest)
            return articles
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    public func addOrUpdateJournal(metadata: [String: AnyObject]) -> Journal? {
        guard let issn = metadata["journalIssn"] as? String else {
            return nil
        }
        var journal: Journal
        if let _journal = getJournal(issn: issn) {
            _journal.update(metadata: metadata)
            journal = _journal
        } else {
            journal = NSEntityDescription.insertNewObject(forEntityName: "Journal", into: self.moc!) as! Journal
            journal.create(metadata: metadata)
        }
        if let journalLinks = metadata["journalLinks"] as? [[String: AnyObject]] {
            DatabaseManager.SharedInstance.addOrUpdateLinks(journalLinks, journal: journal)
        }
        FileSystemManager.sharedInstance.setupJournal(journal)
        return journal
    }
    
    public func newJournal() -> Journal {
        return NSEntityDescription.insertNewObject(forEntityName: "Journal", into: self.moc!) as! Journal
    }
    
    public func getJournal(journalId: Int) -> Journal? {
        let fetchRequest = NSFetchRequest<Journal>(entityName: "Journal")
        let predicate = NSPredicate(format: "journalId = \(journalId)")
        fetchRequest.predicate = predicate
        do {
            let journals = try self.moc!.fetch(fetchRequest)
            if journals.count > 0 {
                return journals[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    public func getJournal(journalShortCode: String) -> Journal? {
        let fetchRequest = NSFetchRequest<Journal>(entityName: "Journal")
        let predicate = NSPredicate(format: "journalShortCode = %@", journalShortCode)
        fetchRequest.predicate = predicate
        do {
            let journals = try self.moc!.fetch(fetchRequest)
            if journals.count > 0 {
                return journals[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    public func getJournal(issn: String) -> Journal? {
        let fetchRequest = NSFetchRequest<Journal>(entityName: "Journal")
        let predicate = NSPredicate(format: "issn = %@", issn)
        fetchRequest.predicate = predicate
        do {
            let journals = try self.moc!.fetch(fetchRequest)
            if journals.count > 0 {
                return journals[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    open func getAllJournals() -> [Journal] {
        let fetchRequest = NSFetchRequest<Journal>(entityName: "Journal")
        let sortDescriptor = NSSortDescriptor(key: "sequence", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let journals = try self.moc!.fetch(fetchRequest)
            return journals
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getAips(journal: Journal) -> [Article] {
        let fetchRequest = Article.getFetchRequest()
        let predicate = NSPredicate(format: "journal = %@ && issue = nil", journal)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOfRelease", ascending: false)]
        do {
            return try self.moc!.fetch(fetchRequest)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getNonAIPArticlesForJournal(_ journal: Journal) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        let predicate = NSPredicate(format: "journal = %@ && issue != nil", journal)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "dateOfRelease", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let articles = try self.moc!.fetch(fetchRequest)
            if articles.count > 0 {
                return articles 
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getDownloadedArticlesForJournal(_ journal: Journal) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        let predicate = NSPredicate(format: "journal.issn = %@ && (downloadInfo.fullTextHTMLDownload == %d || downloadInfo.fullTextImagesDownload = %d)", journal.issn, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue)
        fetchRequest.predicate = predicate
        do {
            let articles = try self.moc!.fetch(fetchRequest)
            if articles.count > 0 {
                return articles 
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getDownloadedArticles(issue: Issue) -> [Article] {
        let fetchRequest = Article.getFetchRequest()
        let predicate = NSPredicate(format: "issue = %@ && (downloadInfo.fullTextHTMLDownload == %d || downloadInfo.fullTextImagesDownload = %d)", issue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue)
        fetchRequest.predicate = predicate
        do {
            return try self.moc!.fetch(fetchRequest)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getMostRecentIssue(_ journal: Journal) -> Issue? {
        let fetchRequest = NSFetchRequest<Issue>(entityName: "Issue")
        fetchRequest.predicate = NSPredicate(format: "journal = %@", journal)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOfRelease", ascending: false)]
        do {
            let issues = try self.moc!.fetch(fetchRequest)
            if issues.count > 0 {
                return issues[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
        
    }
    
    // MARK: - Issue
    
    @discardableResult
    public func addOrUpdateIssue(metadata: [String: AnyObject]) -> Issue? {
        guard let issuePii = metadata["issuePii"] as? String else {
            return nil
        }
        if let issue = getIssue(issuePii) {
            issue.update(metadata: metadata)
            return issue
        } else {
            let issue = Issue.new(context: self.moc!)
            issue.setup(json: metadata, journal: nil)
            return issue
        }
    }
    
    open func getIssue(_ issuePii:String?) -> Issue? {
        guard let _ = issuePii else {
            return nil
        }
        let fetchRequest = NSFetchRequest<Issue>(entityName: "Issue")
        let predicate = NSPredicate(format: "issuePii = '\(issuePii!)'")
        fetchRequest.predicate = predicate
        do {
            let issues = try self.moc!.fetch(fetchRequest)
            if issues.count > 0 {
                return issues[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    open func getAllIssuesForJournal(_ journal:Journal) -> [Issue] {
        let fetchRequest = NSFetchRequest<Issue>(entityName: "Issue")
        let predicate = NSPredicate(format: "journal = %@", journal)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "dateOfRelease", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let issues = try self.moc!.fetch(fetchRequest)
            if issues.count > 0 {
                return issues 
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    open func getAllIssuesBySectionForJournal(_ journal: Journal) -> [TableViewSection] {
        let fetchRequest = NSFetchRequest<Issue>(entityName: "Issue")
        let predicate = NSPredicate(format: "journal = %@", journal)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "dateOfRelease", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            if let issues = try self.moc?.fetch(fetchRequest) {
                if issues.count > 0 {
                    let dateFormatter = DateFormatter(dateFormat: "YYYY")
                    var sections: [TableViewSection] = []
                    var currentSection: TableViewSection?
                    var currentYear: String = ""
                    for issue in issues {
                        let year = dateFormatter.string(from: issue.dateOfRelease!)
                        if year == currentYear {
                            currentSection?.items.append(issue)
                        } else {
                            currentSection = TableViewSection(title: year)
                            currentSection?.items.append(issue)
                            sections.append(currentSection!)
                            currentYear = year
                        }
                    }
                    return sections
                }
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    open func getAllArticlesForIssue(_ issue:Issue) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        let predicate = NSPredicate(format: "issue = %@", issue)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "sequence", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let articles = try self.moc!.fetch(fetchRequest)
            if articles.count > 0 {
                return articles 
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    open func getArticlesCountForIssue(_ issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "issue = %@", issue)
        
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    open func getFullTextArticlesDownloadedCount(issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format:
            "issue = %@ AND (downloadInfo.fullTextHTMLDownload == -1 OR downloadInfo.fullTextHTMLDownload == 3) AND (downloadInfo.fullTextImagesDownload == -1 OR downloadInfo.fullTextImagesDownload == 3)", issue)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    open func getFullTextDownloadedArticles(issue: Issue) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format:
            "issue = %@ AND (downloadInfo.fullTextHTMLDownload == -1 OR downloadInfo.fullTextHTMLDownload == 3) AND (downloadInfo.fullTextImagesDownload == -1 OR downloadInfo.fullTextImagesDownload == 3)", issue)
        do {
            if let articles = try moc?.fetch(fetchRequest) {
                return articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        
        return []
    }
    
    open func getFullTextSupplementTotalCount(issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Issue>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "issue = %@ AND downloadInfo.fullTextSupplDownload != -1", issue)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    open func getAbstractSupplementTotalCount(issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "issue = %@ AND downloadInfo.abstractSupplDownload != -1", issue)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    open func getFullTextSupplementDownloadedCount(issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "issue = %@ AND downloadInfo.fullTextSupplDownload == 3", issue)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    open func getAbstractSupplementDownloadedCount(issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "issue = %@ AND downloadInfo.abstractSupplDownload == 3", issue)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    open func getArticlesForIssue(_ issue: Issue, starred: Bool, notes: Bool) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        
        if starred == true && notes == true {
            fetchRequest.predicate = NSPredicate(format: "issue == %@ && ((starred == true && notes.@count != 0) || (starred == true) || (notes.@count != 0))", issue)
        } else if starred == true && notes == false {
            fetchRequest.predicate = NSPredicate(format: "issue == %@ && starred == true", issue)
        } else if starred == false && notes == true {
            fetchRequest.predicate = NSPredicate(format: "issue == %@ && notes.@count != 0", issue)
        } else {
            fetchRequest.predicate = NSPredicate(format: "issue = %@", issue)
        }
        
        let sortDescriptor = NSSortDescriptor(key: "sequence", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            guard let moc = self.moc else {
                return []
            }
            let articles = try moc.fetch(fetchRequest)
            if articles.count > 0 {
                return articles 
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    open func getAllArticlesForIssue(_ issue: Issue, key: String) -> [Article] {
        
        
        
        
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        let predicate = NSPredicate(format: "issue = %@", issue)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: key, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let articles = try self.moc!.fetch(fetchRequest)
            if articles.count > 0 {
                return articles 
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    open func getFeaturedArticlesForIssue(_ issue: Issue) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        let predicate = NSPredicate(format: "issue = %@", issue)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "sequence", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 4
        do {
            let articles = try self.moc!.fetch(fetchRequest)
            if articles.count > 0 {
                return articles 
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    open func firstIssueForJournal(_ journal:Journal) -> Issue {
        let fetchRequest = NSFetchRequest<Issue>(entityName: "Issue")
        let predicate = NSPredicate(format: "journal = %@", journal)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "dateOfRelease", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let issues = try self.moc!.fetch(fetchRequest)
            if issues.count > 0 {
                return issues[0] 
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return Issue()
    }
    
    // MARK: - Article
    
    public func addOrUpdateArticle(metadata: [String: AnyObject]) -> Article? {
        guard let articlePii = metadata["articlePii"] as? String else {
            return nil
        }
        var article: Article
        if let _article = getArticle(articleInfoId: articlePii) {
            article = _article
            article.update(metadata: metadata)
        } else {
            article = newArticle()
            article.create(metadata: metadata)
        }
        if let referencesMetadata = metadata["references"] as? [[String: AnyObject]] {
            for referenceMetadata in referencesMetadata {
                let reference = DatabaseManager.SharedInstance.addOrUpdateReferences(referenceMetadata)
                reference?.article = article
            }
        }
        if let mediasMetadata = metadata["medias"] as? [[String: AnyObject]] {
            for mediaMetadata in mediasMetadata {
                DatabaseManager.SharedInstance.addOrUpdateMedia(mediaMetadata, article: article)
            }
        }
        
        return article
    }
    
    func newArticle() -> Article {
        return NSEntityDescription.insertNewObject(forEntityName: "Article", into: moc!) as! Article
    }
    
    func newTopArticle() -> TopArticle? {
        guard let _moc = moc else { return nil }
        
        return NSEntityDescription.insertNewObject(forEntityName: "TopArticle", into: _moc) as? TopArticle
    }
    
    func deleteTopArticle(article: Article) {
        guard let _moc = moc else { return }

        let fetchRequest = NSFetchRequest<TopArticle>(entityName: "TopArticle")
        let predicate = NSPredicate(format: "article = %@", article)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedArticles = try _moc.fetch(fetchRequest)
            if fetchedArticles.count == 1, let fetchedArticle = fetchedArticles.first {
                 _moc.delete(fetchedArticle)
                    
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)

        }
    }

    func getArticle(articleInfoId: String) -> Article? {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        let predicate = NSPredicate(format: "articleInfoId = '\(articleInfoId)'")
        fetchRequest.predicate = predicate
        do {
            let articles = try self.moc!.fetch(fetchRequest)
            if articles.count > 0 {
                return articles[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    
    func getArticles(_ searchString: String) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "articleTitle contains[cd] %@", searchString)
        do {
            let articles = try self.moc!.fetch(fetchRequest)
            if articles.count > 0 {
                return articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getArticles(_ searchString: String, inIssue issue: Issue) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "articleTitle contains[cd] %@ && issue = %@", searchString, issue)
        do {
            let articles = try self.moc!.fetch(fetchRequest)
            if articles.count > 0 {
                return articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getArticles(_ searchString: String, inJournal journal: Journal) -> [Article] {
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "articleTitle contains[cd] %@ && journal = %@", searchString, journal)
        
        do {
            let articles = try self.moc!.fetch(fetchRequest)
            if articles.count > 0 {
                return articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    

    
    
    func getAllBookmarksForJournal(_ journal: Journal) -> [Article] {
            let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
            fetchRequest.predicate = NSPredicate(format: "starred = %@ && journal = %@", NSNumber(value: 1 as Int), journal)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "starredDate", ascending: false)]
            do {
                let articles = try self.moc!.fetch(fetchRequest)
                if articles.count > 0 {
                    return articles
                }
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
            return []
    }
    
    func getNotes(_ article: Article) -> [Note] {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "article = %@", article)
        do {
            guard let notes = try self.moc?.fetch(fetchRequest) else {
                return []
            }
            return notes
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }

    
    // MARK: - Publisher
    
    public func addOrUpdateApp(metadata: [String: AnyObject]) -> Publisher? {
        guard let appId = metadata["appId"] as? Int else {
            return nil
        }
        var app: Publisher
        if let _app = getPublisher(appId) {
            app = _app
            app.updateWithCase(metadata: metadata)
        } else {
            app = newAppPublisher()
            app.updateWithCase(metadata: metadata)
        }
        if let societyLinks = metadata["societyLinks"] as? [[String: AnyObject]] {
            DatabaseManager.SharedInstance.addOrUpdateLinks(societyLinks, publisher: app)
        }
        return app
    }
    
    func newAppPublisher() -> Publisher {
        return NSEntityDescription.insertNewObject(forEntityName: "Publisher", into: self.moc!) as! Publisher
    }
    
    open func getAppPublisher() -> Publisher? {
        let fetchRequest = NSFetchRequest<Publisher>(entityName: "Publisher")
        do {
            let publishers = try self.moc!.fetch(fetchRequest)
            if publishers.count > 0 {
                return publishers[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    fileprivate func getPublisher(_ appId: Int) -> Publisher? {
        let fetchRequest = NSFetchRequest<Publisher>(entityName: "Publisher")
        let predicate = NSPredicate(format: "appId = \(appId)")
        fetchRequest.predicate = predicate
        do {
            let publisher = try self.moc!.fetch(fetchRequest)
            if publisher.count > 0 {
                return publisher[0]
            } else {
                return nil
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Authentication
    
    fileprivate func getAuthentication(_ journal: Journal, startDate:Date, endDate:Date) -> Authentication? {
        
        let fetchRequest = NSFetchRequest<Authentication>(entityName: "Authentication")
        let predicate = NSPredicate(format: "journal == %@ && startDate == %@ && endDate == %@", journal, startDate as CVarArg, endDate as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            let results = try self.moc!.fetch(fetchRequest)
            if results.count > 0 {
                return results[0]
            } else {
                return nil
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Media
    
    @discardableResult open func addOrUpdateMedia(_ properties: [String: AnyObject], article: Article) -> Media? {
        guard let fileName = properties["mediaFileName"] as? String else {
            return nil
        }
        if let media = getMedia(fileName, article: article) {
            media.update(properties)
            return media
        } else {
            let media = getNewMedia()
            media.create(properties)
            media.article = article
            return media
        }
    }
    
    func deleteMediaForArticle(_ article:Article) {
        let fetchRequest = NSFetchRequest<Media>(entityName: "Media")
        fetchRequest.predicate = NSPredicate(format: "article = %@", article)
        do {
            let results = try self.moc!.fetch(fetchRequest)
            for result in results {
                moc!.delete(result)
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func getMedia(_ fileName: String, article: Article) -> Media? {
        let fetchRequest = NSFetchRequest<Media>(entityName: "Media")
        fetchRequest.predicate = NSPredicate(format: "fileName = %@ && article = %@", fileName, article)
        do {
            if let results = try moc?.fetch(fetchRequest) {
                if results.count > 0 {
                    return results[0]
                }
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    open func getAllMedia(_ article: Article) {
        
    }
    
    func getNewMedia() -> Media {
        return NSEntityDescription.insertNewObject(forEntityName: "Media", into: moc!) as! Media
    }
    
    // MARK: - Notes
    
    func addOrUpdateNote(_ article: Article, selectedText: String, noteText: String, highlightId: String) {
        if let note = getNote(article: article, highlightId: highlightId) {
            note.update(noteText)
        } else {
            let note = Note.new(context: moc!)
            note.create(article, selectedText: selectedText, noteText: noteText, highlightId: highlightId)
        }
    }
    
    // MARK: - Authors -
    
    @discardableResult func addOrUpdateAuthors(_ properties: [String: AnyObject]) -> Author? {
        guard let authorId = properties["author_id"] as? NSString else {
            return nil
        }
        let fetchRequest = NSFetchRequest<Author>(entityName: "Author")
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", authorId)
        do {
            let results = try self.moc!.fetch(fetchRequest)
            if results.count > 0 {
                return results[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    func addOrUpdateReferences(_ properties:[String:AnyObject]) -> Reference? {
        guard let referenceId = properties["referenceId"] as? Int else {
            return nil
        }
        if let reference = getReference("\(referenceId)") {
            reference.update(metadata: properties)
            return reference
        } else {
            let reference = newReference()
            reference.create(metadata: properties)
            return reference
        }
    }
    
    func getReference(_ referenceId: String) -> Reference? {
        let fetchRequest = NSFetchRequest<Reference>(entityName: "Reference")
        let query = "referenceId == " + String(referenceId)
        fetchRequest.predicate = NSPredicate(format: query)
        do {
            let results = try self.moc!.fetch(fetchRequest)
            if results.count > 0 {
                return results[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    func newReference() -> Reference {
        return NSEntityDescription.insertNewObject(forEntityName: "Reference", into: moc!) as! Reference
    }
    
    func newAuthor() -> Author {
        return NSEntityDescription.insertNewObject(forEntityName: "Author", into: moc!) as! Author
    }
    
    // MARK: - Links -
    
    func addOrUpdateLinks(_ links:[[String:AnyObject]], journal: Journal) {
        
        for link in journal.allLinks {
            moc!.delete(link)
        }
        for linkJSON in links {
            let link = getNewLink()
            link.create(linkJSON, withJournal: journal)
        }
    }
    
    func addOrUpdateLinks(_ links: [[String:AnyObject]], publisher: Publisher) {
        
        if let publisherLinks = publisher.links?.allObjects as? [Link] {
            for link in publisherLinks {
                moc!.delete(link)
            }
        }
        for linkJSON in links {
            let link = getNewLink()
            link.create(linkJSON, withPublisher: publisher)
        }
    }
    
    func getNewLink() -> Link {
        return NSEntityDescription.insertNewObject(forEntityName: "Link", into: moc!) as! Link
    }
    
    // MARK: - Announcements -
    
    func addOrUpdateAnnouncement(_ metadata: [String: AnyObject]) {
        guard let announcementId = metadata[Metadata.Announcement.announcementId] as? NSString  else {
            return
        }
        if let announcement = getAnnouncementWithId(announcementId) {
            announcement.update(metadata)
            announcement.app = self.getAppPublisher()
        } else {
            let announcement = newAnnouncement()
            announcement.create(metadata)
        }
    }
    
    func getAnnouncementWithId(_ identifier: NSString) -> Announcement? {
        let fetchRequest = NSFetchRequest<Announcement>(entityName: Announcement.key)
        fetchRequest.predicate = NSPredicate(format: "announcementId = %@", identifier)
        do {
            let results = try self.moc!.fetch(fetchRequest)
            if results.count > 0 {
                return results[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    func newAnnouncement() -> Announcement {
        return NSEntityDescription.insertNewObject(forEntityName: Announcement.key, into: self.moc!) as! Announcement
    }
    
    func getAllAnnouncements() -> [Announcement] {
        let fetchRequest = NSFetchRequest<Announcement>(entityName: Announcement.key)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "announcementDate", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "announcementDeleted == false AND userDeleted == \(false)")
        
        do {
            guard let results = try self.moc?.fetch(fetchRequest) else { return [] }
            
            if results.count > 0 {
                return results
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getUnreadAnnouncementsCount() -> Int {
        let fetchRequest = NSFetchRequest<Announcement>(entityName: Announcement.key)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "announcementDate", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "announcementDeleted == false AND userDeleted == \(false) AND opened == false")
        return try! moc!.count(for: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
    }
    
    // MARK: - DownloadInfo -
    
    open func getNewDownloadInfo() -> DownloadInfo {
        let downloadInfo = NSEntityDescription.insertNewObject(forEntityName: "DownloadInfo", into: moc!) as! DownloadInfo
        downloadInfo.create()
        return downloadInfo
    }
    
    // MARK: - IP Authentication -
    
    open func newIPAuthentication() -> IPAuthentication {
        return NSEntityDescription.insertNewObject(forEntityName: "IPAuthentication", into: moc!) as! IPAuthentication
    }
    
    // MARK: - Section -
    
    open func newSection() -> Section {
        return NSEntityDescription.insertNewObject(forEntityName: "Section", into: moc!) as! Section
    }
    
    // MARK: - Editor -
    
    open func newEditor() -> Editor {
        return NSEntityDescription.insertNewObject(forEntityName: "Editor", into: moc!) as! Editor
    }
    
    // MARK: - Aim & Scope -
    
    open func newAimAndScope() -> AimAndScope {
        return NSEntityDescription.insertNewObject(forEntityName: "AimAndScope", into: moc!) as! AimAndScope
    }
    
    // MARK: - Society Link -
    
    open func newSocietyLink() -> SocietyLink {
        return NSEntityDescription.insertNewObject(forEntityName: "SocietyLink", into: moc!) as! SocietyLink
    }
    
    // MARK: - Journal Link -
    
    open func newJournalLink() -> JournalLink {
        return NSEntityDescription.insertNewObject(forEntityName: "JournalLink", into: moc!) as! JournalLink
    }
    
    // MARK: - Authentication -
    
    
    
    open func newAuthentication() -> Authentication {
        return NSEntityDescription.insertNewObject(forEntityName: "Authentication", into: moc!) as! Authentication
    }
    
    // MARK: - Partner -
    
    open func newPartner() -> Partner {
        return NSEntityDescription.insertNewObject(forEntityName: "Partner", into: moc!) as! Partner
    }
    
    func getPartner(partnerId: Int, partnerName: String) -> Partner? {
        let fetchRequest = NSFetchRequest<Partner>(entityName: "Partner")
        fetchRequest.predicate = NSPredicate(format: "partnerId = %@ && partnerName = %@", "\(partnerId)", partnerName)
        do {
            let results = try self.moc!.fetch(fetchRequest)
            if results.count > 0 {
                return results[0]
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    func addOrUpdatePartners(json: [[String: Any]]) {
        deleteAllPartners()
        performChangesAndSave {
            for journalJSON in json {
                self.addOrUpdatePartner(json: journalJSON)
            }
        }
    }
    
    func addOrUpdatePartner(json: [String: Any]) {
        guard let cleanIssn = (json["issn"] as? String)?.replacingOccurrences(of: "-", with: ""),
            let partnersJSON = json["partner"] as? [[String: Any]],
            let journal = DatabaseManager.SharedInstance.getJournal(issn: cleanIssn) else {
            return
        }
        for partnerJSON in partnersJSON {
            Partner.create(json: partnerJSON, journal: journal, context: moc!)
        }
    }
    
    func deleteAllPartners() {
        let fetchRequest = NSFetchRequest<Partner>(entityName: "Partner")
        do {
            if let results = try self.moc?.fetch(fetchRequest) {
                for partner in results {
                    self.moc?.delete(partner)
                }
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    // MARK: - Open Access -
    
    func addOrUpdateOpenAccess(_ json: [String: AnyObject]) {
        
        var openAccess: OA
        var new = true
        
        if let _articleInfoId = json["articlePii"] as? String {
            if let _openAccess = getOpenAccessForArticle(articleInfoId: _articleInfoId) {
                openAccess = _openAccess
                new = false
            } else {
                openAccess = newOpenAccess()
            }
        } else if let _issuePii = json["issuePii"] as? String {
            if let _openAccess = getOpenAccessForIssue(issuePii: _issuePii) {
                openAccess = _openAccess
                new = false
            } else {
                openAccess = newOpenAccess()
            }
        } else {
            openAccess = newOpenAccess()
        }
        
        if new == true {
            openAccess.create(json: json)
        } else {
            openAccess.update(json: json)
        }
    }
    
    func newOpenAccess() -> OA {
        return NSEntityDescription.insertNewObject(forEntityName: "OA", into: moc!) as! OA
    }
    
    func getOpenAccessForArticle(articleInfoId: String) -> OA? {
        let fetchRequest = NSFetchRequest<OA>(entityName: "OA")
        fetchRequest.predicate = NSPredicate(format: "articleInfoId = %@", articleInfoId)
        do {
            if let results = try self.moc?.fetch(fetchRequest) {
                if results.count == 1 {
                    return results[0]
                }
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    func getOpenAccessForIssue(issuePii: String) -> OA? {
        let fetchRequest = NSFetchRequest<OA>(entityName: "OA")
        fetchRequest.predicate = NSPredicate(format: "issuePii = %@", issuePii)
        do {
            if let results = try self.moc?.fetch(fetchRequest) {
                if results.count == 1 {
                    return results[0]
                }
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    // MARK: - Misc -
    
    open func performChangesAndSave(_ closure:@escaping ()->()) {
        DispatchQueue.main.async { () -> Void in
            closure()
            self.save()
        }
    }

    func save() {
        Database.sharedInstance.saveContext()
    }
    
    func resetFullText() {
        
    }
    
    func resetAllDownloads() {
        performOnMainThread {
            let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
            fetchRequest.predicate = NSPredicate(format: "downloadInfo.abstractHTMLDownload == 1 OR downloadInfo.abstractImagesDownload == 1 OR downloadInfo.abstractSupplDownload == 1 OR downloadInfo.fullTextHTMLDownload == 1 OR downloadInfo.fullTextImagesDownload == 1 OR downloadInfo.fullTextSupplDownload == 1 OR downloadInfo.pdfDownload == 1")
            do {
                if let results = try self.moc?.fetch(fetchRequest) {
                    for article in results {
                        let downloadInfo = article.downloadInfo!
                        
                        if downloadInfo.abstractHTMLDownloadStatus == .downloading {
                            downloadInfo.abstractHTMLDownloadStatus = .notDownloaded
                        }
                        if downloadInfo.abstractImagesDownloadStatus == .downloading {
                            downloadInfo.abstractImagesDownloadStatus = .notDownloaded
                        }
                        if downloadInfo.abstractSupplDownloadStatus == .downloading {
                            downloadInfo.abstractSupplDownloadStatus = .notDownloaded
                        }
                        if downloadInfo.fullTextHTMLDownloadStatus == .downloading {
                            downloadInfo.fullTextHTMLDownloadStatus = .notDownloaded
                        }
                        if downloadInfo.fullTextImagesDownloadStatus == .downloading {
                            downloadInfo.fullTextImagesDownloadStatus = .notDownloaded
                        }
                        if downloadInfo.fullTextSupplDownloadStatus == .downloading {
                            downloadInfo.fullTextSupplDownloadStatus = .notDownloaded
                        }
                    }
                    DatabaseManager.SharedInstance.save()
                }
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
        }
    }
 
    func checkForMemoryWarning() -> MemoryWarning {
        let size = totalDownloadSize()
        
        var convertedValue = size
        var multiplyFactor = 0
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        
        if multiplyFactor > 2 {
            if convertedValue >= 5 {
                return .fiveGB
            } else if convertedValue >= 1 {
                return .oneGB
            } else {
                return .none
            }
        } else {
            return .none
        }
    }
    
    open func totalDownloadSize() -> Int {
        let fetchRequest = NSFetchRequest<DownloadInfo>(entityName: "DownloadInfo")
        fetchRequest.predicate = NSPredicate(format: "abstractSupplDownload == 3 OR fullTextHTMLDownload == 3 OR fullTextImagesDownload == 3 OR fullTextSupplDownload == 3 OR pdfDownload == 3")
        do {
            if let results = try self.moc?.fetch(fetchRequest) {
                var size: Int64 = 0
                for downloadInfo in results {
                    if downloadInfo.abstractSupplDownloadStatus == .downloaded {
                        size += downloadInfo.abstractFileSize
                    }
                    if downloadInfo.fullTextDownloadStatus == .downloaded {
                        size += downloadInfo.fullTextFileSize
                    }
                    if downloadInfo.fullTextSupplDownloadStatus == .downloaded {
                        size += downloadInfo.fullTextSupplFileSize
                    }
                }
                return Int(size)
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return 0
    }
}

// MARK: - General Articles Information
extension DatabaseManager {
    // MARK: -
    
    // MARK: ABSTRACT SUPPLEMENT
    
    func getCountOfArticlesWithAbstractSupplementalContentForIssue(_ issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = NSPredicate(format: "issue == %@ && downloadInfo.abstractSupplDownload != %d", issue, DownloadStatus.notAvailable.rawValue)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    func getArticlesWithAbstractSupplementalContentForIssue(_ issue: Issue) -> [Article] {
        var articles: [Article] = []
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = NSPredicate(format: "issue == %@ && downloadInfo.abstractSupplDownload != %d", issue, DownloadStatus.notAvailable.rawValue)
        do {
            if let _articles = try self.moc?.fetch(fetchRequest) {
                articles = _articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return articles
    }
    
    func getCountOfArticlesWithFullTextContentForIssue(_ issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = NSPredicate(format: "issue == %@ && downloadInfo.fullTextDownload != %d", issue, DownloadStatus.notAvailable.rawValue)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    func getCountOfArticlesWithFullTextSupplementContentForIssue(_ issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = NSPredicate(format: "issue == %@ && downloadInfo.fullTextSupplDownload != %d", issue, DownloadStatus.notAvailable.rawValue)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
}

// MARK: - Downloaded Articles Information
extension DatabaseManager {
    // MARK:
    
    // MARK: PREDICATES
    
    func predicateForArticlesWithDownloadedContentForIssue(_ issue: Issue) -> NSPredicate {
        return NSPredicate(format: "issue == %@ && (downloadInfo.abstractSupplDownload == %d || downloadInfo.fullTextHTMLDownload == %d || downloadInfo.fullTextImagesDownload = %d || downloadInfo.fullTextSupplDownload == %d)", issue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue)
    }
    
    func predicateForAIPArticlesWithDownloadedContentForJournal(_ journal: Journal) -> NSPredicate {
        return NSPredicate(format: "journal == %@ && issue == nil && (downloadInfo.abstractSupplDownload == %d || downloadInfo.fullTextHTMLDownload == %d || downloadInfo.fullTextImagesDownload = %d || downloadInfo.fullTextSupplDownload == %d)", journal, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue)
    }
    
    func predicateForNonAIPArticlesWithDownloadedContentForJournal(_ journal: Journal) -> NSPredicate {
        return NSPredicate(format: "journal == %@ && issue != nil && (downloadInfo.abstractSupplDownload == %d || downloadInfo.fullTextHTMLDownload == %d || downloadInfo.fullTextImagesDownload = %d || downloadInfo.fullTextSupplDownload == %d)", journal, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue)
    }
    
    func predicateForAllArticlesWithDownloadedContentForJournal(_ journal: Journal) -> NSPredicate {
        return NSPredicate(format: "journal == %@ && (downloadInfo.abstractSupplDownload == %d || downloadInfo.fullTextHTMLDownload == %d || downloadInfo.fullTextImagesDownload = %d || downloadInfo.fullTextSupplDownload == %d)", journal, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue)
    }
    
    func predicateForAllArticlesWithDownloadedContent() -> NSPredicate {
        return NSPredicate(format: "downloadInfo.abstractSupplDownload == %d || downloadInfo.fullTextHTMLDownload == %d || downloadInfo.fullTextImagesDownload = %d || downloadInfo.fullTextSupplDownload == %d", DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue, DownloadStatus.downloaded.rawValue)
    }
    
    // MARK: ISSUE ARTICLES
    
    func getCountOfArticlesWithDownloadedContentForIssue(_ issue: Issue) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = predicateForArticlesWithDownloadedContentForIssue(issue)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    func getArticlesWithDownloadedContentForIssue(_ issue: Issue) -> [Article] {
        var articles: [Article] = []
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = predicateForArticlesWithDownloadedContentForIssue(issue)
        do {
            if let _articles = try self.moc?.fetch(fetchRequest) {
                articles = _articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return articles
    }
    
    func getArticlesWithDownloadedAbstractSupplementForIssue(_ issue: Issue) -> [Article] {
        var articles: [Article] = []
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "issue == %@ && downloadInfo.abstractSupplDownload == %d", issue, DownloadStatus.downloaded.rawValue)
        do {
            if let _articles = try self.moc?.fetch(fetchRequest) {
                articles = _articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return articles
    }
    
    func getArticlesWithDownloadedFullTextForIssue(_ issue: Issue) -> [Article] {
        var articles: [Article] = []
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "issue == %@ && downloadInfo.fullTextDownload == %d", issue, DownloadStatus.downloaded.rawValue)
        do {
            if let _articles = try self.moc?.fetch(fetchRequest) {
                articles = _articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return articles
    }
    
    func getArticlesWithDownloadedFullTextSupplementForIssue(_ issue: Issue) -> [Article] {
        var articles: [Article] = []
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "issue == %@ && downloadInfo.fullTextSupplDownload == %d", issue, DownloadStatus.downloaded.rawValue)
        do {
            if let _articles = try self.moc?.fetch(fetchRequest) {
                articles = _articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return articles
    }
    
    // MARK: JOURNAL Non AIP Articles
    
    func getCountOfNonAIPArticlesWithDownloadedContentForJournal(_ journal: Journal) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = predicateForNonAIPArticlesWithDownloadedContentForJournal(journal)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    func getNonAIPArticlesWithDownloadedContentForJournal(_ journal: Journal) -> [Article] {
        var articles: [Article] = []
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = predicateForNonAIPArticlesWithDownloadedContentForJournal(journal)
        do {
            if let _articles = try self.moc?.fetch(fetchRequest) {
                articles = _articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return articles
    }
    
    // MARK: JOURNAL AIP Articles
    
    func getCountOfAIPArticlesWithDownloadedContentForJournal(_ journal: Journal) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = predicateForAIPArticlesWithDownloadedContentForJournal(journal)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    func getAIPArticlesWithDownloadedContentForJournal(_ journal: Journal) -> [Article] {
        var articles: [Article] = []
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = predicateForAIPArticlesWithDownloadedContentForJournal(journal)
        do {
            if let _articles = try self.moc?.fetch(fetchRequest) {
                articles = _articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return articles
    }
    
    // MARK: JOURNAL ARTICLES
    
    func getCountOfAllArticlesWithDownloadedContentForJournal(_ journal: Journal) -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = predicateForAIPArticlesWithDownloadedContentForJournal(journal)
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    func getAllArticlesWithDownloadedContentForJournal(_ journal: Journal) -> [Article] {
        var articles: [Article] = []
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = predicateForAllArticlesWithDownloadedContentForJournal(journal)
        do {
            if let _articles = try self.moc?.fetch(fetchRequest) {
                articles = _articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return articles
    }
    
    // MARK: APP ARTICLES
    
    func getCountOfAllArticlesWithDownloadedContent() -> Int {
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = predicateForAllArticlesWithDownloadedContent()
        let count = try! moc?.count(for: fetchRequest)
        return count!
    }
    
    func getAllArticlesWithDownloadedContent() -> [Article] {
        var articles: [Article] = []
        let fetchRequest = NSFetchRequest<Article>(entityName: Article.EntityName)
        fetchRequest.predicate = predicateForAllArticlesWithDownloadedContent()
        do {
            if let _articles = try self.moc?.fetch(fetchRequest) {
                articles = _articles
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return articles
    }
}

extension DatabaseManager {
    
    // Journal
    
    func getDownloadedSizeForArticlesInJournal(_ journal: Journal) -> Int {
        var size = 0
        for article in getAllArticlesWithDownloadedContentForJournal(journal) {
            size += article.entireArticleDownloadedSize
        }
        return size
    }
    func getDownloadedSupplementSizeForArticlesInJournal(_ journal: Journal) -> Int {
        var size = 0
        for article in getAllArticlesWithDownloadedContentForJournal(journal) {
            size += article.abstractAndFullTextSupplementDownloadedSize
        }
        return size
    }
    
    func getDownloadedSizeForNonAIPArticlesInJournal(_ journal: Journal) -> Int {
        var size = 0
        for article in getNonAIPArticlesWithDownloadedContentForJournal(journal) {
            size += article.entireArticleDownloadedSize
        }
        return size
    }
    func getDownloadedSupplementSizeForNonAIPArticlesInJournal(_ journal: Journal) -> Int {
        var size = 0
        for article in getNonAIPArticlesWithDownloadedContentForJournal(journal) {
            size += article.abstractAndFullTextSupplementDownloadedSize
        }
        return size
    }
    
    func getDownloadedSizeForAIPArticlesInJournal(_ journal: Journal) -> Int {
        var size = 0
        for article in getAIPArticlesWithDownloadedContentForJournal(journal) {
            size += article.entireArticleDownloadedSize
        }
        return size
    }
    func getDownloadedSupplementSizeForAIPArticlesInJournal(_ journal: Journal) -> Int {
        var size = 0
        for article in getAIPArticlesWithDownloadedContentForJournal(journal) {
            size += article.abstractAndFullTextSupplementDownloadedSize
        }
        return size
    }
    
    // Issue
    
    func getDownloadedSizeForArticlesInIssue(_ issue: Issue) -> Int {
        var size = 0
        for article in getDownloadedArticles(issue: issue) {
            size += article.entireArticleDownloadedSize
        }
        return size
    }
    
    func fileSize(_ issue: Issue, type: FileSizeType, downloaded: Bool) -> Int {
        return 0
    }
    
    func getDownloadedSupplementSizeForArticlesInIssue(_ issue: Issue) -> Int {
        var size = 0
        for article in getDownloadedArticles(issue: issue) {
            size += article.abstractAndFullTextSupplementDownloadedSize
        }
        return size
    }
}
