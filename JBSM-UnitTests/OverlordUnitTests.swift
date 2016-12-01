//
//  OverlordUnitTests.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/7/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
@testable import JBSM

class OverlordUnitTests: XCTestCase {
    
    let database = DatabaseManager.SharedInstance
    var overlord: Overlord.NavigationController!
    
    // MARK: - Setup -
    
    override func setUp() {
        super.setUp()
        
        let splashScreenVC = SplashScreenViewController()
        overlord = Overlord.NavigationController(rootViewController: splashScreenVC)
    }
    
    override func tearDown() {
        let splashScreenVC = SplashScreenViewController()
        overlord.removeAllAndPushViewController(splashScreenVC, animated: false)
        super.tearDown()
    }
    
    func testMultiJournalScreen() {
        guard let appMetadata = JSONHelper.app else {
            XCTFail("Unable to get local App JSON")
            return
        }
        let app = database.addOrUpdateApp(metadata: appMetadata)
        let info = Overlord.CurrentAppInformation(publisher: app, journal: nil, issue: nil, article: nil)
        overlord.navigateToViewControllerType(.multiJournal, appInfo: info)
        
        let exp = expectation(description: "")
        performOnMainThreadAfter(seconds: 2) {
            let viewControllers = self.overlord.viewControllers
            guard viewControllers.count == 1 else {
                XCTFail("Expecting [UIViewController] size to be 1. Actual size is \(viewControllers.count)")
                return
            }
            guard viewControllers[0] is MultiJournalViewController else {
                XCTFail("viewControllers[0] is not of expected type - \(viewControllers[0])")
                return
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            XCTFail("time out")
        }
    }
    
    func testSingleJournalScreen() {
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
        let info = Overlord.CurrentAppInformation(publisher: app, journal: journal, issue: nil, article: nil)
        overlord.navigateToViewControllerType(.singleJournal, appInfo: info)
        
        let exp = expectation(description: "")
        performOnMainThreadAfter(seconds: 2) {
            
            var index = 0
            let viewControllers = self.overlord.viewControllers
            
            if app.allJournals.count > 1 {
                guard viewControllers[index] is MultiJournalViewController else {
                    XCTFail("viewControllers[\(index)] is not of expected type - \(viewControllers[index])")
                    return
                }
                index += 1
            }
            
            /*guard viewControllers[index] is SingleJournalViewController else {
                XCTFail("viewControllers[\(index)] is not of expected type - \(viewControllers[index])")
                return
            }*/
            index += 1
            
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
}
