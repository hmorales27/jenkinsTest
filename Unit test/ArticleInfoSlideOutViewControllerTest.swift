//
//  ArticleInfoSlideOutViewControllerTest.swift
//  JBSM
//
//  Created by Morales Hernandez, Humberto (ELS-PHI) on 10/27/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import XCTest
import MessageUI
@testable import JBSM

class ArticleInfoSlideOutViewControllerTest: XCTestCase {
    
    var controller:ArticleInfoSlideOutViewController?
    let spyDelegate = SpyArticleInfoSlideOutProtocol()
    
    override func setUp() {
        super.setUp()
        controller = ArticleInfoSlideOutViewController()
        controller?.notes.append(Note())
        controller?.references.append(Reference())
        controller?.delegate = spyDelegate
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNotesTableViewDidSelectedShouldDoNothing(){
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        if let notesTableView = controller?.notesTableView {
            notesTableView.delegate?.tableView!((controller?.notesTableView)!, didSelectRowAtIndexPath: indexPath)
            XCTAssertFalse(spyDelegate.openNoteWasCalled, "should not be called")
            XCTAssertFalse(spyDelegate.openDrawerWasCalled, "should not be called")
        }else{
            XCTFail("notes tableView should not be nil")
        }
    }
    
    func testNotesTableViewDidSelectedShouldCallDelegate(){
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        if let notesTableView = controller?.notesTableView {
            notesTableView.delegate?.tableView!((controller?.notesTableView)!, didSelectRowAtIndexPath: indexPath)
            XCTAssertTrue(spyDelegate.openNoteWasCalled, "should be called")
            XCTAssertTrue(spyDelegate.openDrawerWasCalled, "should be called")
            XCTAssertFalse(controller!.open, "should be false")
        }else{
            XCTFail("notes tableView should not be nil")
        }
    }
    
    func testReferencesTableViewDidSelectedShouldDoNothing(){
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        if let notesTableView = controller?.outlineTableView {
            notesTableView.delegate?.tableView!((controller?.outlineTableView)!, didSelectRowAtIndexPath: indexPath)
            XCTAssertFalse(spyDelegate.openReferenceWasCalled, "should not be called")
            XCTAssertFalse(spyDelegate.openDrawerWasCalled, "should not be called")
        }else{
            XCTFail("notes tableView should not be nil")
        }
    }
    
    func testReferencesTableViewDidSelectedShouldCallDelegate(){
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        if let notesTableView = controller?.outlineTableView {
            notesTableView.delegate?.tableView!((controller?.outlineTableView)!, didSelectRowAtIndexPath: indexPath)
            XCTAssertTrue(spyDelegate.openReferenceWasCalled, "should be called")
            XCTAssertTrue(spyDelegate.openDrawerWasCalled, "should be called")
        }else{
            XCTFail("notes tableView should not be nil")
        }
    }
}

class SpyArticleInfoSlideOutProtocol:ArticleInfoSlideOutProtocol{
    
    var openNoteWasCalled = false
    var openDrawerWasCalled = false
    var openReferenceWasCalled = false
    
    func openNote(note: Note) {
        openNoteWasCalled = true
    }
    
    func openDrawer(open: Bool) {
        openDrawerWasCalled = true
    }
    
    func openReference(reference: Reference) {
        openReferenceWasCalled = true
    }
    
    func presentMailVC(mailVC: MFMailComposeViewController) {
        //Left blank due to protol requires implementation
    }
    
    func noteTabWasClicked() {
        //Left blank due to protol requires implementation
    }
    
    func outlineTabWasClicked() {
        //Left blank due to protol requires implementation
    }
}

