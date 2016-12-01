//
//  HighlightViewControllerTest.swift
//  JBSM
//
//  Created by Morales Hernandez, Humberto (ELS-PHI) on 11/3/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
import CoreData
@testable import JBSM

class HighlightViewControllerTest: XCTestCase {
    
    var controller:HighlightViewController?
    var journal:Journal?
    lazy var dbsharedInstance = DatabaseManager()
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entity(forEntityName: "Journal", in: dbsharedInstance.moc!)
        journal = Journal(entity: entity!, insertInto: dbsharedInstance.moc!)
        guard let journal = journal else{
            XCTFail()
            return
        }
        controller = HighlightViewController(journal: journal)
        controller?.topArticlesVC = TopArticlesTableVC(journal:journal)
    }
    
    func testViewDidLoadWhenNewUiIsTrue(){
        controller?.shouldUseNewUi = true
        controller?.viewDidLoad()
        XCTAssertEqual(controller?.view.backgroundColor, Config.Colors.SingleJournalBackgroundColor, "should be equal")
        XCTAssertEqual(controller?.tableView.separatorColor, Config.Colors.SingleJournalBackgroundColor, "should be equal")
        XCTAssertTrue((controller?.view.subviews.contains(controller!.tableViewContainer)) ?? false, "should be true")
        XCTAssertTrue((controller?.tableViewContainer.subviews.contains(controller!.tableView)) ?? false, "should be true")
    }
    
    func testViewDidLoadWhenNewUiIsFalse(){
        controller?.shouldUseNewUi = false
        controller?.viewDidLoad()
        XCTAssertEqual(controller?.view.backgroundColor, Config.Colors.SingleJournalBackgroundColor, "should be equal")
        XCTAssertEqual(controller?.tableView.separatorColor, UIColor.clear, "should be equal")
        guard let tableViewContainer = controller?.tableViewContainer else{
            XCTFail("should not be nil")
            return
        }
        XCTAssertTrue(controller?.view.subviews.contains(tableViewContainer) ?? false, "should be true")
    }
    
    func testCellForRowAtIndexPathWhenShouldUseNewUiIsTrue(){
        controller?.shouldUseNewUi = true
        let indexPath = IndexPath(row: 0, section: 0)
        guard let tableView = controller?.tableView else {
            XCTFail("table view should not be nil")
            return
        }
        let cell = controller?.tableView(tableView, cellForRowAt: indexPath)
        XCTAssertNotNil(cell, "should not be nil")
        XCTAssertEqual(cell?.contentView.backgroundColor, controller?.view.backgroundColor, "should be equal")
    }
    
    func testCellForRowAtIndexPathWhenShouldUseNewUiIsFalse(){
        controller?.shouldUseNewUi = false
        let indexPath = IndexPath(row: 0, section: 0)
        guard let tableView = controller?.tableView else {
            XCTFail("table view should not be nil")
            return
        }
        let cell = controller?.tableView(tableView, cellForRowAt: indexPath)
        XCTAssertNotNil(cell, "should not be nil")
        XCTAssertEqual(cell?.contentView.backgroundColor, UIColor.white, "should be equal")
    }
    
    func testNumberOfRowsInSectionShouldReturnOne(){
        controller?.shouldUseNewUi = true
        guard let tableView = controller?.tableView else {
            XCTFail("table view should not be nil")
            return
        }
        let result = controller?.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(result, 1, "should be equal")
    }
    
    func testNumberOfRowsInSectionShouldReturnTwo(){
        controller?.shouldUseNewUi = false
        controller?.tableViewData.append(Article())
        guard let tableView = controller?.tableView else {
            XCTFail("table view should not be nil")
            return
        }
        let result = controller?.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(result, 2, "should be equal")
    }
    
    func testNumberOfSectionsShouldReturnTwo(){
        controller?.shouldUseNewUi = true
        controller?.tableViewData.append(Article())
        guard let tableView = controller?.tableView else {
            XCTFail("table view should not be nil")
            return
        }
        let result = controller?.numberOfSections(in: tableView)
        XCTAssertEqual(result, 2, "should be equal")
    }
    
    func testNumberOfSectionsShouldReturnOne(){
        controller?.shouldUseNewUi = false
        guard let tableView = controller?.tableView else {
            XCTFail("table view should not be nil")
            return
        }
        let result = controller?.numberOfSections(in: tableView)
        XCTAssertEqual(result, 1, "should be equal")
    }
    
    func testHeightForHeaderInSectionShouldReturnFive(){
        controller?.shouldUseNewUi = true
        guard let tableView = controller?.tableView else {
            XCTFail("table view should not be nil")
            return
        }
        let result = controller?.tableView(tableView, heightForHeaderInSection: 0)
        XCTAssertEqual(result, 5, "should be equal")
    }
    
    func testHeightForHeaderInSectionShouldReturnZero(){
        controller?.shouldUseNewUi = false
        guard let tableView = controller?.tableView else {
            XCTFail("table view should not be nil")
            return
        }
        let result = controller?.tableView(tableView, heightForHeaderInSection: 0)
        XCTAssertEqual(result, 0, "should be equal")
    }
    
    func testOpenTopArticles() {
        controller?.shouldUseNewUi = true
        
        
        guard let _controller = controller, let topArticlesVC = controller?.topArticlesVC else {
            
            XCTFail()
            return
        }
        
        let nav = UINavigationController.init(rootViewController: _controller)
        
        topArticlesVC.delegate = controller
        
        let entity = NSEntityDescription.entity(forEntityName: "Article", in: dbsharedInstance.moc!)
        let _entity = NSEntityDescription.entity(forEntityName: "Issue", in: dbsharedInstance.moc!)
        let infoEntity = NSEntityDescription.entity(forEntityName: "DownloadInfo", in: dbsharedInstance.moc!)

        
        let article = Article(entity: entity!, insertInto: dbsharedInstance.moc!)
        let issue = Issue(entity: _entity!, insertInto: dbsharedInstance.moc!)
        let info = DownloadInfo(entity: infoEntity!, insertInto: dbsharedInstance.moc!)
        
        info.fullTextDownloadStatus = .downloaded
        
        article.issue = issue
        article.downloadInfo = info
        
        topArticlesVC.tableViewData.append(article)
        
        guard let topArticlesData = controller?.topArticlesVC?.tableViewData, let topTable = controller?.topArticlesVC?.tableView
            else {
            
            XCTFail()
            return
        }
        
        let row = 0
        let section = topArticlesData.index(of: topArticlesData.first!)
        
        let indexPath = IndexPath.init(row: row, section: section!)

        controller?.topArticlesVC?.tableView(topTable, didSelectRowAt: indexPath)
        
        print("nav stack's controllers == \(nav.viewControllers)")
        
    }
}


