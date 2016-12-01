//
//  ArticlesHeaderView_Helper.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 8/9/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import Cartography

private struct IssueInformation {
    var screenType : ScreenType
    var headerStae : HeaderState
    var issueInfo  : HeaderInformation
}



extension ArticlesHeaderView {
    
    func _setupAutoLayout(screenType: ScreenType) {
        
        guard let issue = self.issue else { return }
        guard let _issueInfo = issueInfo() else { return }
        let headerState = self.headerState
        
        if let cg = constraintGroup { constrain(clear: cg) }
        _setupForAutoLayout(screenType: screenType, headerState: headerState, issueInfo: _issueInfo)
        
        constraintGroup = constrain(subviewList) { (_views) in
            guard let view = ArticlesHeaderProxyViews(views: _views) else { return }
            
            view.overlayView.top == view.mainView.top
            view.overlayView.right == view.mainView.right
            view.overlayView.bottom == view.mainView.bottom
            view.overlayView.left == view.mainView.left
            
            view.mainView.height >= 32 + (Config.Padding.Default * 2)
            
            switch headerState {
            case .collapsed:
                
                let topSide    : Edge = view.mainView.top
                let rightSide  : Edge = view.mainView.right
                let bottomSide : Edge = view.mainView.bottom
                let leftSide   : Edge = view.mainView.left

                view.issueDateLabel.top   == topSide   + Config.Padding.Default
                view.issueDateLabel.right == rightSide - Config.Padding.Default
                view.issueDateLabel.left  == leftSide  + Config.Padding.Default
                
                let aboveEdge  : Edge = view.issueDateLabel.bottom
                
                switch _issueInfo.downloadStatus() {
                case .notDownloaded:
                    view.downloadButton.top    == aboveEdge + Config.Padding.Default
                    view.downloadButton.bottom == bottomSide - Config.Padding.Default
                    view.downloadButton.left   == leftSide + Config.Padding.Default
                    view.downloadButton.height == 32
                    view.downloadButton.width  == 150
                case .downloading:
                    view.spinnerView.left    == leftSide + Config.Padding.Default
                    view.spinnerView.centerY == view.fullTextLabel.centerY
                    
                    view.fullTextLabel.top   == aboveEdge + Config.Padding.Default
                    view.fullTextLabel.right == rightSide - Config.Padding.Default
                    view.fullTextLabel.left  == view.spinnerView.right + Config.Padding.Default
                    view.fullTextLabel.bottom == bottomSide - Config.Padding.Default
                case .downloaded:
                    aboveEdge == bottomSide - Config.Padding.Default
                }

            case .expanded:
                
                let topSide    : Edge = view.mainView.top
                let rightSide  : Edge = view.mainView.right
                var bottomSide : Edge = view.mainView.bottom
                var leftSide   : Edge
                
                var aboveEdge  : Edge
                
                switch screenType {
                case .mobile:
                    leftSide   = view.mainView.left
                    bottomSide = view.mainView.bottom
                case .tablet:
                    leftSide   = view.coverImageView.right
                }
                
                if screenType == .tablet {
                    view.coverImageView.top    == topSide + Config.Padding.Default
                    view.coverImageView.bottom == bottomSide - Config.Padding.Default
                    view.coverImageView.left   == view.mainView.left + Config.Padding.Default
                    
                    view.freeImageView.top == view.coverImageView.top
                    view.freeImageView.right == view.coverImageView.right
                    view.freeImageView.width == 40
                    view.freeImageView.height == 40
                } else {
                    view.freeImageView.top == view.mainView.top
                    view.freeImageView.right == view.mainView.right
                    view.freeImageView.width == 40
                    view.freeImageView.height == 40
                }
                
                view.issueTypeLavel.top     == topSide   + Config.Padding.Default
                view.issueTypeLavel.right   == rightSide - Config.Padding.Default
                view.issueTypeLavel.left    == leftSide  + Config.Padding.Default
                aboveEdge = view.issueTypeLavel.bottom
                
                view.issueDateLabel.top     == aboveEdge + Config.Padding.Default
                view.issueDateLabel.right   == rightSide - Config.Padding.Default
                view.issueDateLabel.left    == leftSide  + Config.Padding.Default
                aboveEdge = view.issueDateLabel.bottom
                
                view.issueVolumeLabel.top   == aboveEdge + Config.Padding.Default
                if screenType == .tablet {
                    view.issueVolumeLabel.right == rightSide - Config.Padding.Default
                }
                view.issueVolumeLabel.left  == leftSide  + Config.Padding.Default
                aboveEdge = view.issueVolumeLabel.bottom
                
                if issue.shouldShowOpenAccessLabel {
                    view.openAccessLabel.top   == aboveEdge + Config.Padding.Default
                    view.openAccessLabel.right == rightSide - Config.Padding.Default
                    view.openAccessLabel.left  == leftSide  + Config.Padding.Default
                    aboveEdge = view.openAccessLabel.bottom
                }
                
                switch _issueInfo.downloadStatus() {
                case .notDownloaded:
                    view.downloadButton.height == 32
                    view.downloadButton.width  == 150
                    view.downloadButton.top    == aboveEdge + Config.Padding.Default
                    view.downloadButton.left   == leftSide  + Config.Padding.Default
                    if screenType == .mobile {
                        view.downloadButton.bottom == bottomSide - Config.Padding.Default
                    }
                case .downloading:
                    view.spinnerView.left    == leftSide + Config.Padding.Default
                    view.spinnerView.centerY == view.fullTextLabel.centerY
                    
                    view.fullTextLabel.top   == aboveEdge + Config.Padding.Default
                    view.fullTextLabel.right == rightSide - Config.Padding.Default
                    view.fullTextLabel.left  == view.spinnerView.right + Config.Padding.Default
                    if screenType == .mobile {
                        view.fullTextLabel.bottom == bottomSide - Config.Padding.Default
                    }
                case .downloaded:
                    if screenType == .mobile {
                        aboveEdge == bottomSide - Config.Padding.Default
                    }
                }
            }
            
            var buttonsRightEdge : Edge = view.mainView.right
            
            if screenType == .tablet {
                view.collapseButton.right  == view.mainView.right  - Config.Padding.Default
                view.collapseButton.bottom == view.mainView.bottom - Config.Padding.Default
                view.collapseButton.width  == 120
                buttonsRightEdge = view.collapseButton.left
            }
            
            if _issueInfo.notes {
                view.noteButton.right      == buttonsRightEdge     - Config.Padding.Default
                view.noteButton.bottom     == view.mainView.bottom - Config.Padding.Default
                buttonsRightEdge = view.noteButton.left
            }
            
            if _issueInfo.bookmarks {
                view.starredButton.right  == buttonsRightEdge     - Config.Padding.Default
                view.starredButton.bottom == view.mainView.bottom - Config.Padding.Default
                buttonsRightEdge = view.starredButton.left
            }
            
            
            if screenType == .mobile {
                if headerState == .expanded {
                    view.issueVolumeLabel.right == buttonsRightEdge - Config.Padding.Default
                }
            }
        }
    }
    
    
    
    func _setupTopArtAutoLayout(screenType: ScreenType) {
        
        let headerState = self.headerState
        
        if let cg = constraintGroup { constrain(clear: cg) }
        
        constraintGroup = constrain(subviewList) { (_views) in
            guard let view = ArticlesHeaderProxyViews(views: _views) else { return }
            
            
            print("overlay == \(view.overlayView) mainView == \(view.mainView)")
            
            view.overlayView.top == view.mainView.top
            view.overlayView.right == view.mainView.right
            view.overlayView.bottom == view.mainView.bottom
            view.overlayView.left == view.mainView.left
            
            view.mainView.height >= 32 + (Config.Padding.Default * 2)
            
            switch headerState {
            case .collapsed:
                
                let topSide    : Edge = view.mainView.top
                let rightSide  : Edge = view.mainView.right
//                let bottomSide : Edge = view.mainView.bottom
                let leftSide   : Edge = view.mainView.left
                
                view.issueDateLabel.top   == topSide   + Config.Padding.Double
                view.issueDateLabel.right == rightSide - Config.Padding.Default
                view.issueDateLabel.left  == leftSide  + Config.Padding.Double
                
                
            case .expanded:
                
                let topSide    : Edge = view.mainView.top
                let rightSide  : Edge = view.mainView.right
                //var bottomSide : Edge = view.mainView.bottom
                var leftSide   : Edge
                
                
                switch screenType {
                case .mobile:
                    leftSide   = view.mainView.left
                    //bottomSide = view.mainView.bottom
                case .tablet:
                    leftSide   = view.coverImageView.right
                }
                
                view.issueDateLabel.top     == topSide   + Config.Padding.Double
                view.issueDateLabel.right   == rightSide - Config.Padding.Default
                view.issueDateLabel.left    == leftSide  + Config.Padding.Default
                
                switch screenType {
                case .mobile:
                    leftSide   = view.mainView.left
                    //bottomSide = view.mainView.bottom
                case .tablet:
                    leftSide   = view.coverImageView.right
                }

            }
                        
            if screenType == .tablet {
                view.collapseButton.right  == view.mainView.right  - Config.Padding.Default
                view.collapseButton.bottom == view.mainView.bottom - Config.Padding.Default
                view.collapseButton.width  == 120
                //buttonsRightEdge = view.collapseButton.left
            }
        }
    }
    
    
    
    
    func _setupForAutoLayout(screenType: ScreenType, headerState: HeaderState, issueInfo: HeaderInformation) {
        
        // guard let issue = self.issue else { return }
        //let journalColor = issue.journal.color ?? UIColor.grayColor()
        
        /* Download Status */
        _setupHidden(screenType: screenType, headerState: headerState, issueInfo: issueInfo)

    }
    
    func _setupHidden(screenType: ScreenType, headerState: HeaderState, issueInfo: HeaderInformation) {
        _setupDownloadStatus(screenType: screenType, headerState: headerState, issueInfo: issueInfo)
        _setupButtons(screenType: screenType, headerState: headerState, issueInfo: issueInfo)
        _setupLabels(screenType: screenType, headerState: headerState, issueInfo: issueInfo)
        _setupColors(screenType: screenType, headerState: headerState, issueInfo: issueInfo)
    }
    
    func _setupDownloadStatus(screenType: ScreenType, headerState: HeaderState, issueInfo: HeaderInformation) {
        switch issueInfo.downloadStatus() {
        case .notDownloaded:
            downloadButton.isHidden  = false
            fullTextLabel.isHidden   = true
            spinnerView.isHidden     = true
        case .downloading:
            downloadButton.isHidden  = true
            fullTextLabel.isHidden   = false
            spinnerView.isHidden     = false
        case .downloaded:
            downloadButton.isHidden  = true
            fullTextLabel.isHidden   = true
            spinnerView.isHidden     = true
        }
    }
    
    func _setupButtons(screenType: ScreenType, headerState: HeaderState, issueInfo: HeaderInformation) {
        switch screenType {
        case .mobile:
            collapseButton.isHidden = true
        case .tablet:
            collapseButton.isHidden = false
        }
        
        noteButton.isHidden     = issueInfo.notes       ? false : true
        starredButton.isHidden  = issueInfo.bookmarks   ? false : true
    }
    
    func _setupLabels(screenType: ScreenType, headerState: HeaderState, issueInfo: HeaderInformation) {
        
        guard let issue = self.issue else { return }
        
        switch screenType {
        case .mobile:
            coverImageView.isHidden = true
        case .tablet:
            switch headerState {
            case .collapsed:
                coverImageView.isHidden = true
            case .expanded:
                coverImageView.isHidden = false
            }
        }
        
        if !issue.journal.isJournalOpenAccessOrArchive && !issue.isIssueOpenAccessOrArchive && issue.isIssueFree {
            switch headerState {
            case .collapsed:
                freeImageView.isHidden = true
            case .expanded:
                freeImageView.isHidden = false
            }
        } else {
            freeImageView.isHidden = true
        }
        
        switch headerState {
        case .collapsed:
            issueTypeLabel.isHidden   = true
            issueDateLabel.isHidden   = false
            issueVolumeLabel.isHidden = true
            openAccessLabel.isHidden  = true
        case .expanded:
            issueTypeLabel.isHidden   = false
            issueDateLabel.isHidden   = false
            issueVolumeLabel.isHidden = false
            openAccessLabel.isHidden  = issue.shouldShowOpenAccessLabel ? false : true
        }
        
        
    }
    
    func _setupColors(screenType: ScreenType, headerState: HeaderState, issueInfo: HeaderInformation) {
        guard let issue = self.issue else { return }
        
        var _backgroundColor = UIColor.colorWithHexString("7B7B7B")
        if let color = issue.journal.color {
            _backgroundColor = color
        }
        
        if screenType == .tablet && headerState == .expanded {
            backgroundColor = UIColor.white
            issueTypeLabel.textColor = UIColor.black
            issueDateLabel.textColor = UIColor.black
            issueVolumeLabel.textColor = UIColor.black
        } else {
            backgroundColor = _backgroundColor
            issueTypeLabel.textColor = UIColor.white
            issueDateLabel.textColor = UIColor.white
            issueVolumeLabel.textColor = UIColor.white
        }
    }
}
