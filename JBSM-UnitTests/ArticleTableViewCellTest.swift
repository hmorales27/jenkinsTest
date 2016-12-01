//
//  ArticleTableViewCellTest.swift
//  JBSM
//
//  Created by Morales Hernandez, Humberto (ELS-PHI) on 11/3/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
@testable import JBSM

class ArticleTableViewCellTest: XCTestCase {
    
    fileprivate var cell:MockArticleTableViewCell?
    let database = DatabaseManager.SharedInstance
    
    override func setUp() {
        super.setUp()
        cell = MockArticleTableViewCell(style: .default, reuseIdentifier: "cell")
        
        guard let appMetadata = JSONHelper.app else {
            XCTFail("Unable to get local App JSON")
            return
        }
        guard let journalMetadata = JSONHelper.journal else {
            XCTFail("Unable to get local Journal JSON")
            return
        }
        guard let topArticles = JSONHelper.topArticles else {
            XCTFail("Unable to get local top Articles JSON")
            return
        }
        let app = database.addOrUpdateApp(metadata: appMetadata)!
        let journal = database.addOrUpdateJournal(metadata: journalMetadata)!
        journal.publisher = app
        let controller = HighlightViewController(journal: journal)
        controller.shouldUseNewUi = true
        guard let article = database.addOrUpdateArticle(metadata: topArticles) else{
            XCTFail("unable to get Article")
            return
        }
        cell?.article = article
    }
    
    func testNewUIWhenLayoutSubViews(){
        cell?.shouldUseNewUi = true
        cell?.layoutIfNeeded()
        if let _ = cell?.layer.sublayers?[0]{
            XCTAssertEqual(cell?.styleLayer.shadowColor, UIColor.gray.cgColor, "should be equal")
            XCTAssertEqual(cell?.styleLayer.fillColor, UIColor.white.cgColor, "should be equal")
            XCTAssertEqual(cell?.styleLayer.shadowOffset, CGSize(width: 0.0, height: 1.0), "should be equal")
            XCTAssertEqual(cell?.styleLayer.shadowOpacity, 1, "should be equal")
            XCTAssertEqual(cell?.styleLayer.shadowRadius, 1.5, "should be equal")
            
            XCTAssertEqual(cell?.contentView.layer.cornerRadius, 5, "should be equal")
            XCTAssertTrue(cell?.contentView.layer.masksToBounds ?? false, "should be true")
        }else{
            XCTFail("should not be nil")
        }
    }
    
    func testOldUIWhenLayoutSubViews(){
        cell?.shouldUseNewUi = false
        cell?.layoutIfNeeded()
        if let layer = cell?.layer.sublayers?[0] {
            XCTAssertEqual(layer.shadowOpacity, 0, "should be zero")
            XCTAssertEqual(cell?.contentView.layer.cornerRadius, 0.0,"should be zero")
            XCTAssertFalse(cell?.contentView.layer.masksToBounds ?? false, "should be true")
        }else{
            XCTFail("should not be nil")
        }
    }
    
    func testDownloadOpenAccessArticleShouldCallDownloadOpenAccessArticle(){
        let mockJBSMController = MockJBSMViewController()
        cell?.parentJbsmViewController = mockJBSMController
        
        cell?.downloadOpenAccessArticle()
        
        XCTAssertTrue((cell?.parentJbsmViewController as? MockJBSMViewController)?.downloadOpenAccessArticleCalled ?? false, "should be called")
    }
    
    func testDeleteOaArticleShouldCallRemove(){
        let mainThreadExpectation = expectation(description: "expectation for main thread")
        let mockJBSMController = MockJBSMViewController()
        mockJBSMController.expectation = mainThreadExpectation
        cell?.parentJbsmViewController = mockJBSMController
        
        cell?.deleteOaArticle()
        waitForExpectations(timeout: 4.0, handler: nil)
        
        XCTAssertTrue((cell?.parentJbsmViewController as? MockJBSMViewController)?.presentViewControllerCalled ?? false, "should be called")
    }
    
    func testNotificationShouldReturn(){
        cell?.setupNotificationsForOa()
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Started), object: nil, userInfo: [:])
        
        XCTAssertFalse(cell?.updateDownloadButtonCalled ?? false, "should not be called")
    }
    
    func testNotificationShouldCallUpdateButton(){
        cell?.expectation = expectation(description: "expectation for main thread")
        cell?.setupNotificationsForOa()
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Download.Article.Started), object: nil, userInfo: ["article":cell?.article])
        
        waitForExpectations(timeout: 4.0, handler: nil)

        XCTAssertTrue(cell?.updateDownloadButtonCalled ?? false, "should be called")
    }
}

private class MockArticleTableViewCell:ArticleTableViewCell{
    
    open var expectation:XCTestExpectation?
    open var updateDownloadButtonCalled = false
    
    private override func updateDownloadButton(_ article: Article) {
        super.updateDownloadButton(article)
        updateDownloadButtonCalled = true
        expectation?.fulfill()
    }
}

private class MockJBSMViewController : JBSMViewController {
    open var downloadOpenAccessArticleCalled = false
    open var presentViewControllerCalled = false
    open var expectation:XCTestExpectation?
    
    private override func download(openAccessArticle article: Article, pushVC: Bool) {
        super.download(openAccessArticle: article, pushVC: pushVC)
        downloadOpenAccessArticleCalled = true
    }
    
    private override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        expectation?.fulfill()
        presentViewControllerCalled = true
    }
}
