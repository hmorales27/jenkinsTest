/**
 HighlightHeaderView.swift

 Created by Sharkey, Justin (ELS-CON) on 12/2/15.
 Copyright © 2015 Elsevier, Inc. All rights reserved.
*/

import UIKit
import Cartography

protocol HighlightHeaderViewDelegate: class {
    func headerViewLinkWasClicked(_ url: URL)
}

class HighlightHeaderView: UIView, JBSMButtonDelegate, SocialDelegate {
    
    let scrollView = UIScrollView()
    let scrollViewConentView = UIView()
    
    var coverImageView: CoverImageView!
    let freeImageView = FreeImageView()
    
    let facebookView = FacebookButton()
    let twitterImageView = TwitterButton()
    
    let openAccessLabel = OpenAccessLabel()
    let openArchiveLabel = OpenArchiveLabel()
    
    var delegate: HighlightHeaderViewDelegate?
    
    var issue: Issue!
    var linkButtons: [UIButton] = []
    var shouldUseNewUi = USE_NEW_UI
    
    // MARK: Initializers
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
     * MARK: SETUP
    */
    
    func setup(screenType type: ScreenType) {
        coverImageView = CoverImageView(screenType: type)
        setupSubviews()
        
        if shouldUseNewUi {
            setupNewLayout(screenType: type)
            openArchiveLabel.font = UIFont.systemFont(ofSize: 14)

        } else {
            setupAutoLayout(screenType: type)
        }
        
        setupBorders()
        setupTwitterImageView()
        setupFacebookView()
        
        scrollView.canCancelContentTouches = true
        openAccessLabel.numberOfLines = 0
        openArchiveLabel.numberOfLines = 0
    }
    
    
    func setupNewLayout(screenType type: ScreenType) {
        
        switch type {
        case .mobile:
            setupNewLayoutForMobile()
        case .tablet:
            setupNewLayoutForTablet()
        }
    }
    
    func setupNewLayoutForMobile() {
        
        setupScrollViewLayout()
        
        let subviews = [
            coverImageView,    // 0
            freeImageView,     // 1
            openAccessLabel,   // 2
            openArchiveLabel,  // 3
            facebookView, // 4
            twitterImageView   // 5
        ]
        
        constrain(subviews) { (views) in
            
            let coverIV      = views[0]
            let freeIV       = views[1]
            let openAccessL  = views[2]
            let openArchiveL = views[3]
            let facebookV   = views[4]
            let twitterIV    = views[5]
            
            guard let superview = coverIV.superview else {
                return
            }
            
            guard let scrollView = openAccessL.superview else {
                return
            }
            
            coverImageView.constraint.top    = (coverIV.top       == superview.top    + Config.Padding.Double)
            coverImageView.constraint.bottom = (coverIV.bottom    == superview.bottom - Config.Padding.Double)
            coverImageView.constraint.left   = (coverIV.left      == superview.left   + Config.Padding.Double)
            coverImageView.constraint.width  = (coverIV.width == 100)
            coverImageView.constraint.height = (coverIV.height == 125)

            
            freeIV.top         == coverIV.top - 1
            freeIV.right       == coverIV.right + 1
            
            openAccessL.top    == scrollView.top     + Config.Padding.Default
            openAccessL.left   == scrollView.left       + Config.Padding.Default
            openAccessL.right  == scrollView.right     - Config.Padding.Default
            
            openArchiveL.top   == openAccessL.bottom  + Config.Padding.Small
            openArchiveL.right == scrollView.right     - Config.Padding.Default
            openArchiveL.left  == scrollView.left       + Config.Padding.Default
            
            
            facebookV.top      == openArchiveL.bottom + Config.Padding.Default
            facebookV.left     == scrollView.left       + Config.Padding.Default
            facebookV.width    == 30
            facebookV.height   == 30
            
            twitterIV.left     == facebookV.right    + Config.Padding.Default
            twitterIV.centerY  == facebookV.centerY
            twitterIV.width    == 30
            twitterIV.height   == 30
        }

    }
    
    func setupNewLayoutForTablet() {
        setupAutoLayoutForTablet()
    }
    
    
    
    func setupAutoLayout(screenType type: ScreenType) {
        switch type {
        case .mobile:
            setupAutoLayoutForMobile()
        case .tablet:
            setupAutoLayoutForTablet()
        }
    }
    
    func setupAutoLayoutForMobile() {
        
        setupScrollViewLayout()
        
        let subviews = [
            coverImageView,    // 0
            freeImageView,     // 1
            openAccessLabel,   // 2
            openArchiveLabel,  // 3
            facebookView, // 4
            twitterImageView   // 5
        ]
        
        constrain(subviews) { (views) in
            
            let coverIV      = views[0]
            let freeIV       = views[1]
            let openAccessL  = views[2]
            let openArchiveL = views[3]
            let facebookV   = views[4]
            let twitterIV    = views[5]
            
            guard let superview = coverIV.superview else {
                return
            }
            
            guard let scrollView = openAccessL.superview else {
                return
            }
            
            coverImageView.constraint.top    = (coverIV.top       == superview.top    + Config.Padding.Default)
            coverImageView.constraint.bottom = (coverIV.bottom    == superview.bottom - Config.Padding.Default)
            coverImageView.constraint.left   = (coverIV.left      == superview.left   + Config.Padding.Default)

            
            freeIV.top         == coverIV.top - 1
            freeIV.right       == coverIV.right + 1
            
            openAccessL.top    == scrollView.top
            openAccessL.left   == scrollView.left       + Config.Padding.Default
            openAccessL.right  == scrollView.right     - Config.Padding.Default
            
            openArchiveL.top   == openAccessL.bottom  + Config.Padding.Small
            openArchiveL.right == scrollView.right     - Config.Padding.Default
            openArchiveL.left  == scrollView.left       + Config.Padding.Default
            
            facebookV.top     == openArchiveL.bottom + Config.Padding.Default
            facebookV.left    == scrollView.left       + Config.Padding.Default
            
            twitterIV.left     == facebookV.right    + Config.Padding.Default
            twitterIV.centerY  == facebookV.centerY
        }
    }
    
    func setupAutoLayoutForTablet() {
        
        setupScrollViewLayout()
        
        let subviews = [
            coverImageView,    // 0
            freeImageView,     // 1
            openAccessLabel,   // 2
            openArchiveLabel,  // 3
            facebookView, // 4
            twitterImageView   // 5
        ]
        
        constrain(subviews) { (views) in
            
            let coverImage  = views[0]
            let freeImage   = views[1]
            let openAccess  = views[2]
            let openArchive = views[3]
            let facebookIV  = views[4]
            let twitterIV   = views[5]
            
            guard let superview = coverImage.superview else {
                return
            }
            
            coverImage.top    == superview.top      + Config.Padding.Default
            coverImage.bottom == superview.bottom   - Config.Padding.Default
            coverImage.left   == superview.left     + Config.Padding.Default
            coverImageView.constraint.width  = (coverImage.width == 150)
            coverImageView.constraint.height = (coverImage.height == 200)
            
            freeImage.top     == coverImage.top - 1
            freeImage.right   == coverImage.right + 1
            
            openAccess.top    == superview.top      + Config.Padding.Default
            openAccess.left   == coverImage.right   + Config.Padding.Default
            
            openArchive.top   == openAccess.bottom  + Config.Padding.Small
            openArchive.right == openAccess.right
            openArchive.left  == coverImage.right   + Config.Padding.Default
            
            facebookIV.top    == superview.top      + Config.Padding.Default
            facebookIV.left   == openAccess.right   + Config.Padding.Default
            
            twitterIV.right   == superview.right    - Config.Padding.Default
            twitterIV.left    == facebookIV.right   + Config.Padding.Default
            twitterIV.centerY == facebookIV.centerY
        }
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupBorders()
        setupTwitterImageView()
        setupFacebookView()
        
        backgroundColor = USE_NEW_UI ? UIColor.groupTableViewBackground : UIColor.white
        
        facebookView.accessibilityLabel = "Facebook Link"
        facebookView.accessibilityTraits = UIAccessibilityTraitNone
        
        twitterImageView.accessibilityLabel = "Twitter Link"
        twitterImageView.accessibilityTraits = UIAccessibilityTraitNone
        
        freeImageView.isAccessibilityElement = false
        openAccessLabel.isAccessibilityElement = false
        openArchiveLabel.isAccessibilityElement = false
        
        scrollView.canCancelContentTouches = true
    }
    
    func setupSubviews() {
        addSubview(coverImageView)
        addSubview(freeImageView)
        addSubview(scrollView)
        scrollView.addSubview(scrollViewConentView)
        scrollViewConentView.addSubview(openAccessLabel)
        scrollViewConentView.addSubview(openArchiveLabel)
        scrollViewConentView.addSubview(facebookView)
        scrollViewConentView.addSubview(twitterImageView)
    }
    
    func setupScrollViewLayout() {
        
        constrain(self, scrollView, scrollViewConentView, coverImageView) { (view, scrollView, scrollViewContentView, coverImageView) in
            scrollView.top == view.top
            scrollView.right == view.right
            scrollView.bottom == view.bottom
            scrollView.left == coverImageView.right
            
            scrollViewContentView.top == scrollView.top
            scrollViewContentView.right == scrollView.right
            scrollViewContentView.bottom == scrollView.bottom
            scrollViewContentView.left == scrollView.left
            scrollViewContentView.width == scrollView.width
        }
    }
    
    
    func setupBorders() {
        
        let topView = UIView()
        topView.backgroundColor = UIColor.gray
        topView.isHidden = true

        addSubview(topView)
        
        constrain(self, topView) { (view, topView) in
            
            topView.top == view.top
            topView.right == view.right
            topView.left == view.left
            topView.height == 1
        }
        
        if USE_NEW_UI {
            coverImageView.layer.borderColor = UIColor.darkGray.cgColor
            coverImageView.layer.borderWidth = 1.5
        
        } else {
            setupBottomBorder()
        }
    }
    
    func setupBottomBorder() {
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.gray
        addSubview(bottomView)

        constrain(self, bottomView) { (view, bottomView) in
            
            bottomView.right == view.right
            bottomView.bottom == view.bottom
            bottomView.left == view.left
            bottomView.height == 1
        }
    }
    
    
    func setupFacebookView() {
        facebookView.delegate = self
    }
    
    func setupTwitterImageView() {
        twitterImageView.delegate = self
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            coverImageView,    // 0
            freeImageView,     // 1
            openAccessLabel,   // 2
            openArchiveLabel,  // 3
            facebookView, // 4
            twitterImageView   // 5
        ]
        
        constrain(subviews) { (views) in
            
            let coverImage  = views[0]
            let freeImage   = views[1]
            let openAccess  = views[2]
            let openArchive = views[3]
            let facebookIV  = views[4]
            let twitterIV   = views[5]
            
            guard let superview = coverImage.superview else {
                return
            }
            
            coverImage.top    == superview.top      + Config.Padding.Default
            coverImage.bottom == superview.bottom   - Config.Padding.Default
            coverImage.left   == superview.left     + Config.Padding.Default
            coverImage.width  == 150
            coverImage.height == 200
            
            freeImage.top     == coverImage.top - 1
            freeImage.right   == coverImage.right + 1
            
            openAccess.top    == superview.top      + Config.Padding.Default
            openAccess.left   == coverImage.right   + Config.Padding.Default
            
            openArchive.top   == openAccess.bottom  + Config.Padding.Small
            openArchive.right == openAccess.right
            openArchive.left  == coverImage.right   + Config.Padding.Default
            
            facebookIV.top    == superview.top      + Config.Padding.Default
            facebookIV.left   == openAccess.right   + Config.Padding.Default
            
            twitterIV.right   == superview.right    - Config.Padding.Default
            twitterIV.left    == facebookIV.right   + Config.Padding.Default
            twitterIV.centerY == facebookIV.centerY
        }
    }
    
    /*
     * MARK: Update
    */
    
    func update(issue: Issue) {
        guard let journal = issue.journal else {
            return
        }
        
        updateCoverImage(issue: issue)
        updateOpenAccess(text: journal.openAccess.oaStatusDisplay)
        updateOpenArchive(text: journal.openAccess.oaStatusArchive)
        updateFacebookButton(url: journal.journalFacebookURL)
        updateTwitterButton(url: journal.journalTwitterURL)
        
        freeImageView.isHidden = issue.coverImageShouldShowFreeLabel ? false : true
        
        var accessibility   = ""
        if let openAccess   = issue.journal.openAccess.oaStatusDisplay  { accessibility += openAccess + ". "   }
        if let journalTitle = issue.journal.journalTitle                { accessibility += journalTitle + ". " }
        if let openArchive  = issue.journal.openAccess.oaStatusArchive  { accessibility += openArchive + ". "  }
        
        coverImageView.accessibilityLabel = accessibility + ". Current issue cover image double tap to view all articles of Current issue"
        coverImageView.accessibilityTraits = UIAccessibilityTraitNone
        coverImageView.isAccessibilityElement = true
        
        freeImageView.isAccessibilityElement = false
        openAccessLabel.isAccessibilityElement = false
        openArchiveLabel.isAccessibilityElement = false
        
        addLinks(journal.allLinks)
        layoutSubviews()
        
        accessibilityElements = [coverImageView, facebookView, twitterImageView]
        
        for button in linkButtons {
            accessibilityElements?.append(button)
        }
    }

    func updateCoverImage(issue: Issue) {
        coverImageView.update(issue)
    }
    
    func updateOpenAccess(text: String?) {
        openAccessLabel.update(text)
    }
    
    func updateOpenArchive(text: String?) {
        openArchiveLabel.update(text)
    }
    
    func updateFacebookButton(url _url: String?) {
        if let url = _url {
            facebookView.linkURL = url
            facebookView.isHidden = false
        } else {
            facebookView.isHidden = true
        }
    }
    
    func updateTwitterButton(url _url: String?) {
        if let url = _url {
            twitterImageView.linkURL = url
            twitterImageView.isHidden = false
        } else {
            twitterImageView.isHidden = true
        }
    }
    
    func updateFreeImage(display: Bool) {
        if display {
            freeImageView.isHidden = false
        } else {
            freeImageView.isHidden = true
        }
    }
    
    func addLinks(_ links: [Link]) {
        var previousLinkButton: UIView = facebookView
        
        linkButtons = []
        
        for link in links {
            let newButton = createNewButton(link.title, link: link.url)
            newButton.accessibilityLabel = link.title + ", link"
            newButton.accessibilityTraits = UIAccessibilityTraitLink
            scrollViewConentView.addSubview(newButton)
            constrain(newButton, previousLinkButton, coverImageView, scrollViewConentView, block: { (new, previous, coverImage, scrollViewContentView) -> () in
                
                new.left == scrollViewContentView.left + Config.Padding.Default
                new.right == scrollViewContentView.right - Config.Padding.Default
                new.top == previous.bottom + Config.Padding.Default
                //new.height == 20
            })
            previousLinkButton = newButton
            linkButtons.append(newButton)
        }
        constrain(previousLinkButton, scrollViewConentView) { (previous, cv) in
            previous.bottom == cv.bottom - 8
        }
    }
    
    func createNewButton(_ title:String, link:String) -> UIButton {
        let newButton = HighLightHeaderViewButton(title: title, link: link)
        newButton.addTarget(self, action: #selector(buttonWasClicked(_:)), for: .touchUpInside)
        return newButton
    }
    
    func buttonWasClicked(_ button: HighLightHeaderViewButton) {
        if let url = URL(string: button._link!) {
            delegate?.headerViewLinkWasClicked(url)
        }
    }
    
    /*
     * MARK: COVER IMAGE
    */
    
    func coverImageDownloaded(_ notification: Foundation.Notification) {
        DispatchQueue.main.async { 
            if !self.setCoverImage() {
                self.setTempCoverImage()
            }
        }
    }
    
    func setCoverImage() -> Bool {
        if let imagePath = issue.coverImagePath {
            if let image = UIImage(contentsOfFile: imagePath) {
                self.coverImageView.image = image
                return true
            }
        }
        return false
    }
    
    func setTempCoverImage() {
        guard let image = UIImage(named: "Placeholder") else {
            assertionFailure("No Placeholder Image Provided")
            return
        }
        coverImageView.image = image
    }
    
    func jbsmButtonWasClicked(_ sender: JBSMButton) {
        if let linkURL = sender.linkURL {
            if let url = URL(string: linkURL) {
                delegate?.headerViewLinkWasClicked(url)
            }
        }
    }
    
    func socialViewWasClicked(_ sender: SocialView) {
        if let linkURL = sender.linkURL {
            if let url = URL(string: linkURL) {
                delegate?.headerViewLinkWasClicked(url)
            }
        }
    }
}
