//
//  ReferenceLinkViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/25/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class ReferenceLinkViewController: JBSMViewController, ArticleViewControllerLinkClickedDelegate {
    
    var articleVC: ArticleViewController?
    
    init(journalIssn: String, issuePii: String?, articlePii: String) {
        super.init(nibName: nil, bundle: nil)
        
        if let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: articlePii) {
            setupArticleVC(article: article)
            self.setupViews()
            return
        }
        
        if let issuePii = issuePii {
            ContentKit.SharedInstance.updateForIssueArticleDeepLink(journalIssn: journalIssn, issuePii: issuePii, articlePii: articlePii) { (success) in
                guard success else {
                    self.presentFailureAlert()
                    return
                }
                
                guard
                    DatabaseManager.SharedInstance.getJournal(issn: journalIssn) != nil,
                    DatabaseManager.SharedInstance.getIssue(issuePii) != nil,
                    let article = DatabaseManager.SharedInstance.getArticle(articleInfoId: articlePii)
                else {
                    self.presentFailureAlert()
                    return
                }
                
                self.setupArticleVC(article: article)
                self.setupViews()
            }
        }
    }
    
    func setupArticleVC(article: Article) {
        self.articleVC = ArticleViewController(article: article)
        self.articleVC?.delegate = self
        self.articleVC?.linkClickedDelegate = self
    }
    
    func presentFailureAlert() {
        let alertVC = UIAlertController(title: "Error", message: "Unable to fetch article.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            performOnMainThread {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
    init(journalIssn: String, articlePii: String) {
        super.init(nibName: nil, bundle: nil)
        
        ContentKit.SharedInstance.updateForAipArticleDeepLink(journalIssn: journalIssn, articlePii: articlePii) { (success) in
            guard success else {
                let alertVC = UIAlertController(title: "Error", message: "Unable to fetch article.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    performOnMainThread {
                        self.dismiss(animated: true, completion: nil)
                    }
                }))
                return
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupViews() {
        performOnMainThread {
            guard let articleVC = self.articleVC else {
                return
            }
            self.addChildViewController(articleVC)
            articleVC.didMove(toParentViewController: self)
            self.view.addSubview(articleVC.view)
            
            articleVC.view.translatesAutoresizingMaskIntoConstraints = false
            
            articleVC.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            articleVC.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            articleVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            articleVC.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        }
    }
    
    override func setupNavigationBar() {
        navigationItem.leftBarButtonItem = closeBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem(title: "Go to Full Article", style: .plain, target: self, action: #selector(goToArticleClicked))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func goToArticleClicked() {
        guard let article = articleVC?.article else {
            return
        }
        self.dismiss(animated: true, completion: nil)
        if article.issue != nil {
            let info = Overlord.CurrentAppInformation(publisher: article.journal.publisher, journal: article.journal, issue: article.issue, article: article)
            AppDelegate.shared.overlord.navigateToViewControllerType(.issueArticle, appInfo: info)
        } else {
            let info = Overlord.CurrentAppInformation(publisher: article.journal.publisher, journal: article.journal, issue: article.issue, article: article)
            AppDelegate.shared.overlord.navigateToViewControllerType(.aipArticle, appInfo: info)
        }
    }
    
    func handleArticleLinkClicked(request: URLRequest) -> Bool {
        presentGoToFullTextAlert()
        return false
    }
}

extension ReferenceLinkViewController: ArticleViewControllerDelegate {
    
    func articleViewController(_ viewController: ArticleViewController, didRequestMedia media: Media) {
        presentGoToFullTextAlert()
    }
    
    func articleViewController(_ viewController: ArticleViewController, didRequestURL url: URL, ofType type: ArticleURLRequestType) {
        presentGoToFullTextAlert()
    }
    
    func presentGoToFullTextAlert() {
        let alertVC = UIAlertController(title: "View Full Article?", message: "You need to go to the full article to view this content.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction(title: "Go to Full Article", style: .default, handler: { (alert) in
            self.goToArticleClicked()
        }))
        performOnMainThread {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}
