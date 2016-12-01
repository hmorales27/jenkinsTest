//
//  ServiceCallTests.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 9/16/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
@testable import JBSM

class ServiceCallTests: XCTestCase {
    
    var api: APIManager?
    var contentKit: ContentKit?
    var db: DatabaseManager?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        contentKit = ContentKit.SharedInstance
        db = DatabaseManager.SharedInstance
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    //  MARK: - Top Articles -
    
    
    func testApiResponseHandler() {
        
        let type = type(of: self)
        let bundle = Bundle(for: type)
        print(bundle)
        
        
        guard let filePath = bundle.path(forResource: "topArticles_test_json", ofType:"text") else {
            
            return
        }
        
        var serialized: [String: Any]?
        
        do {
            let json = try NSString.init(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue)
            guard let data = json.data(using: String.Encoding.utf8.rawValue) else {
                
                XCTAssertNotNil(serialized)
                return
            }
            serialized = try JSONSerialization.jsonObject(with: data,
                                                          options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
            
        } catch {
            XCTAssertNotNil(serialized)
        }
        
        guard let _serialized = serialized, let _contentKit = contentKit else {
            
            XCTAssertNotNil(serialized)
            return
        }
        /*let parseable = _contentKit.parseTopArticlesMetadata(metadata: _serialized, journal: nil)
        
        XCTAssertTrue(parseable)*/
    }
    
    
    func testHandlingBadResponse() {
        
        let type = type(of: self)
        let bundle = Bundle(for: type)
        
        var serialized: [String: Any]?
        
        let filePath = bundle.path(forResource: "garbage", ofType: "json")
        
        guard let _filePath = filePath else {
            
            XCTAssertNotNil(serialized)
            return
        }
        
        do {
            let json = try NSString.init(contentsOfFile: _filePath, encoding: String.Encoding.utf8.rawValue)
            guard let data = json.data(using: String.Encoding.utf8.rawValue) else {
                
                XCTAssertNotNil(serialized)
                return
            }
            serialized = try JSONSerialization.jsonObject(with: data,
                                                          options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
            
        } catch {}
        
        guard let _serialized = serialized, let _contentKit = contentKit else {
            
            return
        }
        /*let parseable = _contentKit.parseTopArticlesMetadata(metadata: _serialized, journal: nil)
        
        XCTAssertFalse(parseable)*/
    }
    
    
    /*func testUpdateHighlightData() {
        let article = self.db?.newArticle()
        
        guard let journals = self.contentKit?.getAllJournals() else {
            XCTFail("no journals found in db.")
            return
        }
        guard let journal = journals.first else {
            XCTFail("somehow journals were found but could not pull any from returned array.")
            return
        }
        
        let highlightVc = HighlightViewController.init(journal: journal)
        
        
        guard let _article = article else {
            
            XCTFail()
            return
        }
        highlightVc.tableViewData = [_article]
        
        XCTAssertEqual(highlightVc.tableViewData, [_article])
    }*/
    
    /*func testTopArticlesUpdateWithNilResponseShouldReturnFalse() {
        let blockExpectation = expectation(description: "block in main thread has ended")
        contentKit?.dlPubData = { (_ completion:@escaping (_ success:Bool, _ response:[String: AnyObject]?) -> ()) in
            completion(true, nil)
        }
        
        contentKit?.updateAppMetadata({ (success) in
            XCTAssertFalse(success, "should be false")
            blockExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 5.0) { (error:Error?) in
            if let _ = error {
                XCTFail("time out")
            }
        }
    }*/
}
