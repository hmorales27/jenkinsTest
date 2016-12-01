//
//  JBSMPushNotificationViewTest.swift
//  AlertView
//
//  Created by Morales Hernandez, Humberto (ELS-PHI) on 11/11/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
@testable import JBSM

class JBSMPushNotificationViewTest: XCTestCase {
    
    var pushNotificationView : JBSMPushNotificationView? = nil
    
    override func setUp() {
        super.setUp()
    }
    
    func testInitializer(){
        let onTapBlock = {}
        let onDismissBlock = {}
        pushNotificationView = JBSMPushNotificationView(title: "Test", subTitle: "Test", onTapBlock: onTapBlock, onDismissBlock: onDismissBlock, backgroundColor: UIColor.black, image: nil)
        
        XCTAssertNotNil(pushNotificationView, "should not be nil")
        XCTAssertEqual(pushNotificationView?.titleLabel.text, "Test","should be Test")
        XCTAssertEqual(pushNotificationView?.detailLabel.text, "Test", "should be Test")
        XCTAssertNotNil(pushNotificationView?.onTapBlock,"should not be nil")
        XCTAssertNotNil(pushNotificationView?.onDismissBlock,"should not be nil")
        XCTAssertEqual(pushNotificationView?.backgroundColor, UIColor.black, "should be black")
        XCTAssertNil(pushNotificationView?.image, "should be nil")
        XCTAssertTrue(pushNotificationView?.dismissOnTap ?? false, "should be true by default")
        XCTAssertTrue(pushNotificationView?.hasShadow ?? false, "should be true")
        XCTAssertEqual(pushNotificationView?.animationDuration, 0.3, "should be true")
        XCTAssertEqual(pushNotificationView?.type, JBSMPushNotificationViewType.dark, "should be dark")
    }
    
    func testOnTapBlockShouldExecuteTapBlock(){
        var blockExecuted = false
        let onTapBlock = {
            blockExecuted = true
        }
        pushNotificationView = JBSMPushNotificationView(title: "Test", subTitle: "Test", onTapBlock: onTapBlock, onDismissBlock: nil, backgroundColor: UIColor.black, image: nil)
        pushNotificationView?.show()
        pushNotificationView?.onTap()
        
        XCTAssertNotNil(pushNotificationView, "should not be nil")
        XCTAssertTrue(blockExecuted, "should be true")
    }
    
    func testOnTapBlockShouldExecuteDismissBlock(){
        let blockExpectation = expectation(description: "expectation for block")
        var blockExecuted = false
        let onDismissBlock = {
            blockExecuted = true
            blockExpectation.fulfill()
        }
        pushNotificationView = JBSMPushNotificationView(title: "Test", subTitle: "Test", onTapBlock: nil, onDismissBlock: onDismissBlock, backgroundColor: UIColor.black, image: nil)
        pushNotificationView?.show()
        pushNotificationView?.onTap()
        
        waitForExpectations(timeout: 4.0) { (error) in
            if let error = error {
                XCTFail()
                print(error.localizedDescription)
            }
        }
        
        XCTAssertNotNil(pushNotificationView, "should not be nil")
        XCTAssertTrue(blockExecuted, "should be true")
    }
    
    func testOnSwipeShouldDismissViewShouldExecuteDismissBlock(){
        let blockExpectation = expectation(description: "expectation for block")
        var blockExecuted = false
        let onDismissBlock = {
            blockExecuted = true
            blockExpectation.fulfill()
        }
        pushNotificationView = JBSMPushNotificationView(title: "Test", subTitle: "Test", onTapBlock: nil, onDismissBlock: onDismissBlock, backgroundColor: UIColor.black, image: nil)
        pushNotificationView?.show()
        pushNotificationView?.onSwipe()
        
        waitForExpectations(timeout: 4.0) { (error) in
            if let error = error {
                XCTFail()
                print(error.localizedDescription)
            }
        }
        
        XCTAssertNotNil(pushNotificationView, "should not be nil")
        XCTAssertTrue(blockExecuted, "should be true")
    }
    
    func testRefreshUI(){
        let pushNotificationView = MockJBSMPushNotificationView(title: "Test", subTitle: "Test", onTapBlock: nil, onDismissBlock: nil, backgroundColor: UIColor.black, image: nil)
        pushNotificationView.type = .light
        
        XCTAssertTrue(pushNotificationView.refreshuiCalled, "should be true")
    }
}

private class MockJBSMPushNotificationView : JBSMPushNotificationView {
    open var refreshuiCalled = false
    
    override func refreshUI() {
        refreshuiCalled = true
    }
}
