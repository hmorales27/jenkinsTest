//
//  ServiceCallTests.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 9/16/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
import JBSM

class ServiceCallTests: XCTestCase {
    
    var api: APIManager?
    var contentKit: ContentKit?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        contentKit = ContentKit.SharedInstance
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
        let parseable = _contentKit.parseTopArticlesMetadata(metadata: _serialized, journal: nil)
        
        XCTAssertTrue(parseable)
    }
    
    
    func testHandlingBadResponse() {
        
        let type = type(of: self)
        let bundle = Bundle(for: type)
        print(bundle)
        
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
            
            
        } catch {
        }
        
        guard let _serialized = serialized, let _contentKit = contentKit else {
            
            return
        }
        let parseable = _contentKit.parseTopArticlesMetadata(metadata: _serialized, journal: nil)
        
        XCTAssertFalse(parseable)
    }

    
    func testExample() {

    }
    
    func testPerformanceExample() {

    }
    
}
