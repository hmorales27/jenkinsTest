//
//  ArticleActivity.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/12/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class ArticleActivity: UIActivity {
    
    let article: Article
    
    init(article: Article) {
        self.article = article
        super.init()
    }
    
    func setup() {
        setValue("Recommended article from \(article.journal.journalTitle)", forKey: "subject")
    }
    
    override func activityType() -> String? {
        return UIActivityTypeMail
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
}
