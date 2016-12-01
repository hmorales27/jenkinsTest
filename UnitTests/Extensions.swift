//
//  Extensions.swift
//  JBSM
//
//  Created by Curtis, Michael (ELS-PHI) on 11/9/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
@testable import JBSM

class Extensions: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testString_stringBetweenSubstrings() {
        let test = "test1blahtest2"
        XCTAssertEqual(test.stringBetweenSubstrings(beginningSubstring: "test1", endingSubstring: "test2"), "blah", "should be equal")
        XCTAssertEqual(test.stringBetweenSubstrings(beginningSubstring: "test1"), "blahtest2", "should be equal")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
