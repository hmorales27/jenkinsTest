//
//  DatabaseManager+Journal.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/26/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

extension DatabaseManager {
    
    public func getTopArticles(journal: Journal) -> [Article] {
        let fetchRequest = TopArticle.FetchRequest()
        fetchRequest.predicate = NSPredicate(format: "article.journal == %@", journal)
        do {
            let results = try moc!.fetch(fetchRequest)
            let articles = results.map({ (topArticle) -> Article in
                topArticle.article
            })
            return articles
        } catch let error {
            print(error.localizedDescription)
        }
        return []
    }
    
    public func getArticles(issue: Issue, sortingKey key: String = "sequence") -> [Article] {
        let fetchRequest = Article.getFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "issue = %@", issue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: true)]
        do {
            return try self.moc!.fetch(fetchRequest)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    public func getArticles(journal: Journal, withNotes notes: Bool) -> [Article] {
        let fetchRequest = Note.getFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "article.journal == %@", journal)
        do {
            let notes = try moc!.fetch(fetchRequest)
            let nonUnique = notes.map({ (note) -> Article in
                return note.article
            })
            let articlesSet = Set<Article>(nonUnique)
            return Array<Article>(articlesSet)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getNotes(journal: Journal) -> [Note] {
        let fetchRequest = Note.getFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "article.journal == %@", journal)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "savedDate", ascending: false)]
        do {
            return try moc!.fetch(fetchRequest)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    func getNote(article: Article, highlightId: String) -> Note? {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "article == %@ && highlightId == %@", article, highlightId)
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
    
}
