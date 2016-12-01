//
//  HighlightHeaderViewTest.swift
//  JBSM
//
//  Created by Morales Hernandez, Humberto (ELS-PHI) on 11/28/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
@testable import JBSM

class HighlightHeaderViewTest: XCTestCase {
    
    fileprivate var highlightHeaderView:MockHighlightHeaderView?
    
    override func setUp() {
        super.setUp()
        highlightHeaderView = MockHighlightHeaderView()
    }
    
    func testSetupShouldCallSetupNewUiForTablet(){
        highlightHeaderView?.shouldUseNewUi = true
        highlightHeaderView?.setup(screenType: .tablet)
        XCTAssertTrue(highlightHeaderView?.setupNewLayoutCalled ?? false, "should be called")
        XCTAssertTrue(highlightHeaderView?.setupNewLayoutForTabletCalled ?? false, "should be called")
    }
    
    func testSetupShouldCallSetupNewUiForMobile(){
        highlightHeaderView?.shouldUseNewUi = true
        highlightHeaderView?.setup(screenType: .mobile)
        XCTAssertTrue(highlightHeaderView?.setupNewLayoutCalled ?? false, "should be called")
        XCTAssertTrue(highlightHeaderView?.setupNewLayoutForMobileCalled ?? false, "should be called")
    }
    
    func testSetupShouldCallSetupOldUiForTablet(){
        highlightHeaderView?.shouldUseNewUi = false
        highlightHeaderView?.setup(screenType: .tablet)
        XCTAssertTrue(highlightHeaderView?.setupOldLayoutCalled ?? false, "should be called")
        XCTAssertTrue(highlightHeaderView?.setupAutoLayoutForTabletCalled ?? false, "should be called")
    }
    
    func testSetupShouldCallSetupOldUiForMobile(){
        highlightHeaderView?.shouldUseNewUi = false
        highlightHeaderView?.setup(screenType: .mobile)
        XCTAssertTrue(highlightHeaderView?.setupOldLayoutCalled ?? false, "should be called")
        XCTAssertTrue(highlightHeaderView?.setupAutoLayoutForMobileCalled ?? false, "should be called")
    }
    
    func testSetupNewLayoutShouldCallMobile(){
        highlightHeaderView?.setup(screenType: .mobile)
        highlightHeaderView?.setupNewLayout(screenType: .mobile)
        XCTAssertTrue(highlightHeaderView?.setupNewLayoutForMobileCalled ?? false, "should be called")
    }
    
    func testSetupNewLayoutShouldCallTablet(){
        highlightHeaderView?.setup(screenType: .tablet)
        highlightHeaderView?.setupNewLayout(screenType: .tablet)
        XCTAssertTrue(highlightHeaderView?.setupNewLayoutForTabletCalled ?? false, "should be called")
    }
}

private class MockHighlightHeaderView:HighlightHeaderView {
    open var setupNewLayoutForMobileCalled = false
    open var setupNewLayoutForTabletCalled = false
    open var setupOldLayoutCalled = false
    open var setupNewLayoutCalled = false
    open var setupAutoLayoutForMobileCalled = false
    open var setupAutoLayoutForTabletCalled = false
    
    private override func setupNewLayoutForMobile() {
        super.setupNewLayoutForMobile()
        setupNewLayoutForMobileCalled = true
    }
    
    private override func setupNewLayoutForTablet() {
        super.setupNewLayoutForTablet()
        setupNewLayoutForTabletCalled = true
    }
    
    private override func setupNewLayout(screenType type: ScreenType) {
        super.setupNewLayout(screenType: type)
        setupNewLayoutCalled = true
    }
    
    private override func setupAutoLayout(screenType type: ScreenType) {
        super.setupAutoLayout(screenType: type)
        setupOldLayoutCalled = true
    }
    
    private override func setupAutoLayoutForMobile() {
        super.setupAutoLayoutForMobile()
        setupAutoLayoutForMobileCalled = true
    }
    
    private override func setupAutoLayoutForTablet() {
        super.setupAutoLayoutForTablet()
        setupAutoLayoutForTabletCalled = true
    }
}
