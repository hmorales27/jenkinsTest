/*
    Created by Sharkey, Justin (ELS-CON) on 10/10/15.
    Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
*/

import UIKit
import Cartography
import GoogleMobileAds

private let SOCIETY_INFO_REUSE_IDENTIFIER = "society_info_reuse_identifier"

private let SOCIETY_INFO_HEIGHT: CGFloat = 300

private let SOCIETY_INFO_WIDTH: CGFloat = 320

extension MultiJournalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return flowLayout.sectionInset
        default:
            return UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
        }
    }
}

class MultiJournalViewController: JBSMViewController, UICollectionViewDelegate, UICollectionViewDataSource, SocietyInformationViewDelegate {
    
    // MARK: MAIN VIEWS
    
    let brandImageView = BrandImageView(society: true)
    var _collectionView: UICollectionView!
    
    let advertisementVC = AdvertisementViewController()
    
    var societyView = SocietyInformationView()
    
    var autolayoutIPhoneGroup: ConstraintGroup?
    var autolayoutIPadGroup: ConstraintGroup?
    
    var autolayoutGroup = ConstraintGroup()
    
    var firstLoad = true
    
    // MARK: DATA
    
    var journals: [Journal] = []
    var publisher: Publisher!
    
    override var screenTitle: String {
        guard let publisher = self.publisher else { return "" }
        switch screenType {
        case .mobile:
            guard let title = publisher.appTitleIPhone else { return "" }
            return title
        case .tablet:
            guard let title = publisher.appTitle else { return "" }
            return title
        }
    }
    
    // MARK: OTHER
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        return flowLayout
    }()
    
    // MARK: - Initializers -
    
    init(publisher: Publisher) {
        super.init(nibName: nil, bundle: nil)
        self.publisher = publisher
        _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        analyticsScreenName = Constants.Page.Name.Home
        analyticsScreenType = Constants.Page.Type.np_hp
        super.viewDidLoad()

        update()
        setup()
        
        showAnnouncementAlertIfNecessary()
        
        switch DatabaseManager.SharedInstance.checkForMemoryWarning() {
        case .fiveGB:
            let alertVC = UIAlertController(title: "Over 5 GB of journal content has been downloaded and is being stored on your device.", message: "You can manage your usage by deleting content you no longer need within the setting -> Usage menu.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        case .oneGB:
            let alertVC = UIAlertController(title: "Over 1 GB of journal content has been downloaded and is being stored on your device.", message: "You can manage your usage by deleting content you no longer need within the setting -> Usage menu.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch screenType {
        case .mobile:
            advertisementVC.setup(AdType.iPhonePortrait, publisher: DatabaseManager.SharedInstance.getAppPublisher()!)
        case .tablet:
            advertisementVC.setup(AdType.iPhonePortrait, publisher: DatabaseManager.SharedInstance.getAppPublisher()!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        brandImageView.update(view.frame.size)
        
        if firstLoad {
            firstLoad = false
        } else {
            reloadCollectionView()
        }
        
        currentlyDisplayedView = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //currentlyDisplayedView = false
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupView()
        setupCollectionView()
        setupAutoLayout()
        setupNavigationBar()
        setupSocietyView()
    }
    
    func setupSubviews() {
        view.addSubview(_collectionView)
        view.backgroundColor = UIColor.colorWithHexString("E1E1E1")
        _collectionView.addSubview(brandImageView)
        view.addSubview(advertisementVC.view)
        _collectionView.addSubview(societyView)
    }
    
    func setupView() {

    }
    
    func setupSocietyView() {
        guard let publisher = self.publisher else { return }
        guard publisher.isSocietyInfoAvailable == true else { return }
        
        societyView.delegate = self
        
        societyView.aboutLabel.text = publisher.desc
        
        if let facebook = publisher.societyFacebookURL {
            if facebook != "" {
                societyView.facebookButton.isHidden = false
                societyView.facebookButton.setLink(link: facebook)
            } else {
                societyView.facebookButton.isHidden = true
            }
        } else {
            societyView.facebookButton.isHidden = true
        }
        
        if let twitter = publisher.societyTwitterURL {
            if twitter != "" {
                societyView.twitterButton.isHidden = false
                societyView.twitterButton.setLink(link: twitter)
            } else {
                societyView.twitterButton.isHidden = true
            }
        } else {
            societyView.twitterButton.isHidden = true
        }
        
        if let links = publisher.links?.allObjects as? [Link] {
            societyView.addLinks(links, delegate: self)
        }
    }
    
    func setupCollectionView() {
        _collectionView.register(UICollectionReusableView.self,
                                     forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                     withReuseIdentifier: Strings.CollectionView.HeaderView.Publication)
        
        _collectionView.register(PublicationCollectionCell.self, forCellWithReuseIdentifier: PublicationCollectionCell.Identifier)
        _collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: SOCIETY_INFO_REUSE_IDENTIFIER)
        
        _collectionView.delegate = self
        _collectionView.dataSource = self
        
        _collectionView.backgroundColor = UIColor.clear
    }
    
    func setupAutoLayoutForIPhone(views _views: [View]) {
        
        societyView.isHidden = true
        
        constrain(_views, replace: autolayoutGroup) { (views) in
            
            let brandImageV = views[0]
            let collectionV = views[1]
            let adV         = views[3]
            
            guard let superview = collectionV.superview else { return }
            
            brandImageV.top == collectionV.top
            brandImageV.centerX == collectionV.centerX
            //brandImageV.width == superview.width
            
            collectionV.top == superview.top
            collectionV.right == superview.right
            collectionV.left == superview.left
            
            adV.top == collectionV.bottom
            adV.right == superview.right
            advertisementVC.bottomConstraint = (adV.bottom == superview.bottom)
            adV.left == superview.left
        }
    }
    
    func setupAutLayoutForIPad(views _views: [View]) {
        
        societyView.isHidden = false
        
        constrain(_views, replace: autolayoutGroup) { (views) in
            
            let brandImageV = views[0]
            let collectionV = views[1]
            let societyV = views[2]
            let adV = views[3]
            
            guard let superview = collectionV.superview else {
                return
            }
            
            brandImageV.top == collectionV.top
            brandImageV.centerX == collectionV.centerX
            //brandImageV.width == superview.width
            
            collectionV.top == superview.top
            collectionV.right == superview.right
            collectionV.left == superview.left
            
            societyView.layoutConstraints.top = (societyV.top == collectionV.top)
            societyV.right == superview.right - 8
            societyView.layoutConstraints.width = (societyV.width == 0)
            societyView.layoutConstraints.height = (societyV.height == 0)
            
            adV.top == collectionV.bottom
            adV.right == superview.right
            advertisementVC.bottomConstraint = (adV.bottom == superview.bottom)
            adV.left == superview.left
        }
    }
    
    func setupAutoLayout(screenType type: ScreenType? = nil) {
        
        var absoluteType: ScreenType
        if let _type = type {
            absoluteType = _type
        } else {
            absoluteType = self.screenType
        }
        
        let subviews = [
            brandImageView,   // 0
            _collectionView,   // 1
            societyView,      // 2
            advertisementVC.view!
        ]
            
        switch absoluteType {
        case .mobile:
            setupAutoLayoutForIPhone(views: subviews)
        case .tablet:
            setupAutLayoutForIPad(views: subviews)
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationTitle()
        updateNavigationItemsForScreenType(screenType)
    }
    

    
    func updateNavigationItemsForScreenType(_ type: ScreenType) {
        switch type {
        case .mobile:
            performOnMainThread({ 
                self.navigationItem.rightBarButtonItems = nil
            })
            
        case .tablet:
            performOnMainThread({ 
                self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
            })
            
        }
    }
    
    
    
    // MARK: - Update -
    
    func update() {
        performOnMainThread { 
            self.updateBrandImageView()
            self.updateBrandImageViewInset(nil)
            self.updateJouranlList()
            self.updateApp()
            self._collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func updateJouranlList() {
        let newJournals = DatabaseManager.SharedInstance.getAllJournals()
        if newJournals != journals {
            journals = newJournals
            _collectionView.reloadData()
        }
    }
    
    func updateApp() {
        publisher = DatabaseManager.SharedInstance.getAppPublisher()
        updateNavigationTitle()
    }
    
    func updateBrandImageView(screenType type: ScreenType? = nil) {
        if let _type = type {
            self.brandImageView.update(screenType: _type)
        } else {
            self.brandImageView.update(screenType: screenType)
        }
    }
    
    func updateBrandImageViewInset(_ width: CGFloat?) {
        
        var type: ScreenType
        if let _width = width {
            type = ScreenType.TypeForSize(CGSize(width: _width, height: 0))
        } else {
            type = screenType
        }
        
        var brandImageHeight: CGFloat = 0
        if let image = brandImageView.image {
            brandImageHeight = image.size.height
        }
        
        var societyInfoWidth: CGFloat = 0
        if type == .tablet {
            societyInfoWidth = SOCIETY_INFO_WIDTH
        }
        
        if publisher.isSocietyInfoAvailable == true {
            self.societyView.layoutConstraints.width?.constant = societyInfoWidth - 8
            self.flowLayout.sectionInset = UIEdgeInsets(top: brandImageHeight + 8, left: 8, bottom: 8, right: societyInfoWidth + 8)
        } else {
            self.societyView.layoutConstraints.width?.constant = 0
            self.flowLayout.sectionInset = UIEdgeInsets(top: brandImageHeight + 8, left: 8, bottom: 8, right: 8)
        }
        
        self.societyView.layoutConstraints.top?.constant = brandImageHeight + 8
        self.societyView.layoutConstraints.height?.constant = societyInfoWidth - 8
    }
    
    // MARK: - Layout -
    
    override func updateViewsForScreenChange(_ type: ScreenType, withExpectedWidth width: CGFloat, forTransitionState state: ScreenTransitionState) {
        switch state {
        case .willTransition:
            updateNavigationItemsForScreenType(type)
            setupAutoLayout(screenType: type)
            updateBrandImageView(screenType: type)
            updateBrandImageViewInset(width)
        case .didTransition:
            reloadCollectionView()
        }
    }
    
    func reloadCollectionView() {
        _collectionView.collectionViewLayout.invalidateLayout()
        _collectionView.reloadData()
    }

    // MARK: - Collection View -
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = _collectionView.dequeueReusableCell(withReuseIdentifier: PublicationCollectionCell.Identifier, for: indexPath) as! PublicationCollectionCell
            cell.setupJournal(journals[(indexPath as NSIndexPath).row], screenType: screenType)
            cell.coverImageView.setScreenType(self.screenType)
            cell.delegate = self
            return cell
        } else {
            let cell = _collectionView.dequeueReusableCell(withReuseIdentifier: SOCIETY_INFO_REUSE_IDENTIFIER, for: indexPath)
            
            for view in cell.contentView.subviews {
                view.removeFromSuperview()
            }
            
            let societyView = SocietyInformationView()
            cell.contentView.addSubview(societyView)
            
            societyView.backgroundColor = UIColor.white
            societyView.layer.cornerRadius = 8
            societyView.layer.borderColor = UIColor.gray.cgColor
            societyView.layer.borderWidth = 1
            societyView.delegate = self
            
            societyView.setup(self.publisher, delegate: self)
            
            constrain(societyView, block: { (societyView) in
                guard let superview = societyView.superview else { return }
                societyView.top == superview.top + 8
                societyView.right == superview.right - 8
                societyView.bottom == superview.bottom - 8
                societyView.left == superview.left + 8
            })
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return journals.count
        } else {
            return 1
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch screenType {
        case .mobile:
            if publisher.isSocietyInfoAvailable == true {
                return 2
            } else {
                return 1
            }
        case .tablet:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Strings.CollectionView.HeaderView.Publication, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            let journal = journals[(indexPath as NSIndexPath).row]
            let highlightVC = HighlightViewController(journal: journal)
            ContentKit.SharedInstance.updateIssues(journal: journal, completion: nil)
            self.overlord?.pushViewController(highlightVC, animated: true)
        }
    }
    
    var collectionViewWidth: CGFloat {
        return _collectionView.contentSize.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
    }

    @objc(collectionView:layout:sizeForItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch (indexPath as NSIndexPath).section {
        case 0:
            let cellWidth = widthForCellWithCollectionViewWidth(collectionViewWidth)
            var height: CGFloat
            switch screenType {
            case .mobile:
                height = 150
            case .tablet:
                height = 200
            }
            return CGSize(width: cellWidth, height: height + (Config.Padding.Default * 2) + 53)
        default:
            return CGSize(width: _collectionView.frame.width, height: SOCIETY_INFO_HEIGHT)
        }
    }
    
    func widthForCellWithCollectionViewWidth(_ width: CGFloat) -> CGFloat {
        let paddingWidth = CGFloat(8)
        var numberOfCells = CGFloat(1)
        if journals.count >= 6 {
            if width <= 507 {
                numberOfCells = 1
            } else if width <= 768 {
                numberOfCells = 2
            } else {
                numberOfCells = 3
            }
        } else {
            numberOfCells = 1
        }
        let numberOfPadding = -1 + numberOfCells
        let spaceForCells = width - (numberOfPadding * paddingWidth)
        let cellWidth = spaceForCells / numberOfCells
        return cellWidth
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

    }
    
    @available(iOS 9.0, *)
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self._collectionView.indexPathForItem(at: gesture.location(in: self._collectionView)) else {
                break
            }
            _collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            _collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            _collectionView.endInteractiveMovement()
        default:
            _collectionView.cancelInteractiveMovement()
        }
    }
    
    // MARK: - Settings -
    
    func viewControllerForPopoverController() -> UIViewController {
        return self
    }
    
    func societyInformationLinkClicked(url: URL) {
        performOnMainThread { 
            self.loadAndPresentURL(url: url)
        }
    }
}

extension MultiJournalViewController: PublicationCellDelegate {
    
    
    func stackViewSelectedForIssue(_ issue: Issue) {
        let articlesVC = StoryboardHelper.Articles()
        articlesVC.issue = issue
        articlesVC.currentJournal = issue.journal
        ContentKit.SharedInstance.updateArticles(issue: issue) { (success) in
            
        }
        self.overlord?.pushViewController(articlesVC, animated: true)
    }

}

extension MultiJournalViewController: JBSMButtonDelegate {
    func jbsmButtonWasClicked(_ sender: JBSMButton) {
        if let urlString = sender.linkURL {
            if let url = URL(string: urlString) {
                societyInformationLinkClicked(url: url)
            }
        }
    }
}

