//
//  TopArticlesTableVCTest.swift
//  JBSM
//
//  Created by Morales Hernandez, Humberto (ELS-PHI) on 11/22/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
@testable import JBSM

class TopArticlesTableVCTest: XCTestCase {
    
    let database = DatabaseManager.SharedInstance
    var topArticlesTableController:TopArticlesTableVC?
    
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
        topArticlesTableController = TopArticlesTableVC(journal: journal)
        topArticlesTableController?.analyticsInstance = MockAnalyticsHelper()
    }
    
    func testTrackAnalyticsShouldNotHitRequest(){
        topArticlesTableController?.tracked = true
        topArticlesTableController?.trackTopArticlesView()
        guard let analyticsInstance = topArticlesTableController?.analyticsInstance as? MockAnalyticsHelper else{
            XCTFail()
            return
        }
        XCTAssertTrue(topArticlesTableController?.tracked ?? false, "should be true")
        XCTAssertFalse(analyticsInstance.trackStateCalled, "should not be called")
    }
    
    func testTrackAnalyticsShouldHitRequest(){
        topArticlesTableController?.tracked = false
        topArticlesTableController?.trackTopArticlesView()
        XCTAssertTrue(topArticlesTableController?.tracked ?? false, "should be true")
        guard let analyticsInstance = topArticlesTableController?.analyticsInstance as? MockAnalyticsHelper else{
            XCTFail()
            return
        }
        XCTAssertTrue(analyticsInstance.trackStateCalled, "should be called")
        XCTAssertEqual(analyticsInstance.pageName, Constants.Page.Name.topArticles,"should be top articles page")
        XCTAssertNotNil(analyticsInstance.stateContentData?[AnalyticsConstant.TagPageType], "should not be nil")
        XCTAssertEqual(analyticsInstance.stateContentData?[AnalyticsConstant.TagPageType] as? String, Constants.Page.Type.np_gp, "should be equal")
    }
    
    func testLoadTableViewDataShouldTrackAnalytics(){
        topArticlesTableController?.tracked = false
        topArticlesTableController?.loadTableViewData()
        guard let analyticsInstance = topArticlesTableController?.analyticsInstance as? MockAnalyticsHelper else{
            XCTFail()
            return
        }
        XCTAssertTrue(analyticsInstance.trackStateCalled, "should be called")
    }
}

private class MockAnalyticsHelper : AnalyticsHelper {
    
    public var pageName:String?
    public var stateContentData:[AnyHashable:Any]?
    public var trackStateCalled = false
    
    private override func trackState(_ pageName: String, stateContentData: [AnyHashable : Any]) {
        trackStateCalled = true
        self.pageName = pageName
        self.stateContentData = stateContentData
    }
}
