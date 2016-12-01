//
//  TopArticlesMasterVCTest.swift
//  JBSM
//
//  Created by Morales Hernandez, Humberto (ELS-PHI) on 11/23/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
@testable import JBSM

class TopArticlesMasterVCTest: XCTestCase {
    
    let database = DatabaseManager.SharedInstance
    var topArticlesMasterVC:TopArticlesMasterVC?
    
    override func setUp() {
        super.setUp()
        guard let appMetadata = JSONHelper.app else {
            XCTFail("Unable to get local App JSON")
            return
        }
        guard let journalMetadata = JSONHelper.journal else {
            XCTFail("Unable to get local Journal JSON")
            return
        }
        let app = database.addOrUpdateApp(metadata: appMetadata)!
        let journal = database.addOrUpdateJournal(metadata: journalMetadata)!
        journal.publisher = app
        topArticlesMasterVC = TopArticlesMasterVC(journal: journal)
    }
    
    func testSetupHeaderView(){
        topArticlesMasterVC?.setupHeaderView()
        XCTAssertEqual(topArticlesMasterVC?.headerView.issueDateLabel.text, "Most-read articles in the last 30 days", "should be equal")
        XCTAssertEqual(topArticlesMasterVC?.headerView.issueDateLabel.textColor, UIColor.white, "should be white")
        XCTAssertEqual(topArticlesMasterVC?.headerView.issueDateLabel.font, AppConfiguration.DefaultBoldTitleFont, "should be DefaultBoldTitleFont")
        XCTAssertEqual(topArticlesMasterVC?.headerView.backgroundColor, AppConfiguration.HeaderBackgroundColor, "should be HeaderBackgroundColor")
        XCTAssertEqual(topArticlesMasterVC?.headerView.issueDateLabel.textAlignment, NSTextAlignment.left, "should be left")
    }
    
    func testAdBannerVisible(){
        XCTAssertFalse(topArticlesMasterVC?.advertisementVC.view.isHidden ?? true, "should be visible")
        XCTAssertTrue(topArticlesMasterVC?.advertisementVC.isViewLoaded ?? false, "should be loaded")
    }
}
