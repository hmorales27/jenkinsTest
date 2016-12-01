//
//  PushNotificationTest.swift
//  JBSM
//
//  Created by Morales Hernandez, Humberto (ELS-PHI) on 11/11/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
@testable import JBSM

class PushNotificationManagerTest: XCTestCase {
    
    fileprivate var mockPushNotificationManager:MockPushNotificationManager?
    fileprivate let mockHelper = PushNotificationManagerHelper()
    var localNotification = UILocalNotification()
    var userInfo:[String:String]?
    let splashVC = SplashScreenViewController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var mockOverlord:MockOverlord!
    var pushNotificationManager:PushNotification.Manager!
    
    override func setUp() {
        super.setUp()
        mockPushNotificationManager = MockPushNotificationManager()
        mockOverlord = MockOverlord(rootViewController: splashVC)
        pushNotificationManager = PushNotification.Manager.shared
    }
    
    func testInitializer(){
        XCTAssertNotNil(mockPushNotificationManager)
    }
    /*
    func testUserDidOpenNotificationWhenAppIsActiveAndContentTypeIsDeepLink(){
        let userInfo = mockHelper.userInfo(.DeepLink, screenType: .TableOfContents)
        localNotification.userInfo = userInfo
        let applicationState = UIApplicationState.active
        
        mockPushNotificationManager?.userDidOpenNotification(notification: localNotification, applicationState: applicationState)
        
        XCTAssertTrue(mockPushNotificationManager?.showNotificationAlertCalled ?? false, "should call")
    }
    
    func testUserDidOpenNotificationWhenAppIsInBackgroundAndContentTypeIsDeepLink(){
        userInfo = mockHelper.userInfo(.DeepLink, screenType: .TableOfContents)
        localNotification.userInfo = userInfo
        let applicationState = UIApplicationState.background
        
        mockPushNotificationManager?.userDidOpenNotification(notification: localNotification, applicationState: applicationState)
        
        XCTAssertTrue(mockPushNotificationManager?.handleNotificationCalled ?? false, "should call")
    }
    
    func testUserDidOpenNotificationWhenAppIsInactiveAndContentTypeIsDeepLink(){
        let userInfo = mockHelper.userInfo(.DeepLink, screenType: .TableOfContents)
        localNotification.userInfo = userInfo
        let applicationState = UIApplicationState.inactive
        
        mockPushNotificationManager?.userDidOpenNotification(notification: localNotification, applicationState: applicationState)
        
        XCTAssertTrue(mockPushNotificationManager?.handleNotificationCalled ?? false, "should call")
    }
    
    func testUserDidOpenNotificationWhenUserInfoIsNil(){
        localNotification.userInfo = nil
        let applicationState = UIApplicationState.active
        
        mockPushNotificationManager?.userDidOpenNotification(notification: localNotification, applicationState: applicationState)
        
        XCTAssertFalse(mockPushNotificationManager?.showNotificationAlertCalled ?? false, "should call")
        XCTAssertFalse(mockPushNotificationManager?.handleNotificationCalled ?? false, "should call")
    }
    
    func testUserDidOpenNotificationWhenParsePayloadFails(){
        localNotification.userInfo = [:]
        let applicationState = UIApplicationState.active
        
        mockPushNotificationManager?.userDidOpenNotification(notification: localNotification, applicationState: applicationState)
        
        XCTAssertFalse(mockPushNotificationManager?.showNotificationAlertCalled ?? false, "should call")
        XCTAssertFalse(mockPushNotificationManager?.handleNotificationCalled ?? false, "should call")
    }
    
    func testShowNotificationAlertShouldShowNotificationWhenIsDeepLink(){
        let userInfo = mockHelper.userInfo(.DeepLink, screenType: .TableOfContents)
        if let mockPayload = PushNotification.Payload(json: userInfo), let view = UIApplication.shared.delegate?.window {
            pushNotificationManager.presentForegroundAlert(payload:mockPayload)
            XCTAssertTrue(view?.subviews.last?.isKind(of: JBSMPushNotificationView.classForCoder()) ?? false)
            let alert = view?.subviews.last as? JBSMPushNotificationView
            alert?.onTap()
        }else{
            XCTFail("payload should not be nil")
        }
    }
    
    func testShowNotificationAlertShouldShowNotification(){
        userInfo = mockHelper.userInfo(.DeepLink, screenType: .TableOfContents)
        if let mockPayload = PushNotification.Payload(json: userInfo!), let view = UIApplication.shared.delegate?.window {
            pushNotificationManager.presentForegroundAlert(payload:mockPayload)
            XCTAssertTrue(view?.subviews.last?.isKind(of: JBSMPushNotificationView.classForCoder()) ?? false)
        }else{
            XCTFail("payload should not be nil")
        }
    }
    
    func testHandleNotificationShouldNavigateToIssueTocVCWhenIsNotDeepLink(){
        userInfo = mockHelper.userInfo(.ContentOnly, screenType: .TableOfContents)
        if let mockPayload = PushNotification.Payload(json: userInfo!) {
            appDelegate.overlord = mockOverlord
            pushNotificationManager.handleNotification(payload: mockPayload)
            XCTAssertFalse(mockOverlord.navigateToViewControllerTypeCalled, "should be true")
        }else{
            XCTFail("payload should not be nil")
        }
    }
    
    func testHandleNotificationShouldNavigateToIssueTocVCWhenScreenIsTableOfContents(){
        userInfo = mockHelper.userInfo(.DeepLink, screenType: .TableOfContents)
        if let mockPayload = PushNotification.Payload(json: userInfo!) {
            appDelegate.overlord = mockOverlord
            pushNotificationManager.handleNotification(payload: mockPayload)
            XCTAssertTrue(mockOverlord.navigateToViewControllerTypeCalled, "should be true")
            XCTAssertEqual(mockOverlord.overlordVCType, .issueTOC, "should be issueTOC")
        }else{
            XCTFail("payload should not be nil")
        }
    }
    
    func testHandleNotificationShouldNavigateToIssueTocVCWhenScreenIsTopArticle(){
        userInfo = mockHelper.userInfo(.DeepLink, screenType: .TopArticle)
        if let mockPayload = PushNotification.Payload(json: userInfo!) {
            appDelegate.overlord = mockOverlord
            pushNotificationManager.handleNotification(payload: mockPayload)
            XCTAssertTrue(mockOverlord.navigateToViewControllerTypeCalled, "should be true")
            XCTAssertEqual(mockOverlord.overlordVCType, .topArticles, "should be single journal")
        }else{
            XCTFail("payload should not be nil")
        }
    }
    
    func testHandleNotificationShouldNavigateToIssueTocVCWhenScreenIsAIPSection(){
        userInfo = mockHelper.userInfo(.DeepLink, screenType: .AIPSection)
        if let mockPayload = PushNotification.Payload(json: userInfo!) {
            appDelegate.overlord = mockOverlord
            pushNotificationManager.handleNotification(payload: mockPayload)
            XCTAssertTrue(mockOverlord.navigateToViewControllerTypeCalled, "should be true")
            XCTAssertEqual(mockOverlord.overlordVCType, .aips, "should be aips")
        }else{
            XCTFail("payload should not be nil")
        }
    }
    
    func testHandleNotificationShouldNavigateToIssueTocVCWhenScreenIsAIPArticle(){
        userInfo = mockHelper.userInfo(.DeepLink, screenType: .AIPArticle)
        if let mockPayload = PushNotification.Payload(json: userInfo!) {
            appDelegate.overlord = mockOverlord
            pushNotificationManager.handleNotification(payload: mockPayload)
            XCTAssertTrue(mockOverlord.navigateToViewControllerTypeCalled, "should be true")
            XCTAssertEqual(mockOverlord.overlordVCType, .aipArticle, "should be aipArticle")
        }else{
            XCTFail("payload should not be nil")
        }
    }
    
    func testHandleNotificationShouldNavigateToIssueTocVCWhenScreenIsIssueArticle(){
        userInfo = mockHelper.userInfo(.DeepLink, screenType: .IssueArticle)
        if let mockPayload = PushNotification.Payload(json: userInfo!) {
            appDelegate.overlord = mockOverlord
            pushNotificationManager.handleNotification(payload: mockPayload)
            XCTAssertTrue(mockOverlord.navigateToViewControllerTypeCalled, "should be true")
            XCTAssertEqual(mockOverlord.overlordVCType, .issueArticle, "should be issueArticle")
        }else{
            XCTFail("payload should not be nil")
        }
    }
    */
}

private class PushNotificationManagerHelper :NSObject{
    func userInfo(_ contentType:PushNotification.ContentType, screenType:PushNotification.ScreenType) -> [String:String] {
        return ["contentType": "\(contentType.rawValue)", "screenId": "\(screenType.rawValue)", "alert":"Lancet : DeepLink Push For Issue TOC!", "issuePii": "S0140673615X61551", "journalIssn": "01406736", "articleInfoId": "123456"]
    }
}

private class MockPushNotificationManager:PushNotification.Manager {
    open var handleNotificationCalled = false
    open var showNotificationAlertCalled = false
    /*
    private override func handleNotification(payload: PushNotification.Payload) {
        handleNotificationCalled = true
    }
    
    private override func presentForegroundAlert(payload:PushNotification.Payload){
        showNotificationAlertCalled = true
    }*/
}

private class MockOverlord:Overlord.NavigationController {
    open var navigateToViewControllerTypeCalled = false
    open var overlordVCType:Overlord.ViewControllerType = .unknown
    
    private override func navigateToViewControllerType(_ type: Overlord.ViewControllerType, appInfo: Overlord.CurrentAppInformation) -> Bool {
        navigateToViewControllerTypeCalled = true
        overlordVCType = type
        return true
    }
}
