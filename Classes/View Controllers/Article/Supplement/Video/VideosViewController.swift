//
//  VideosViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/17/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CellIdentifier = "VideoTableViewCell"
private let CellSize = CGSize(width: 360, height: (360 * (200/300)) + 100)

class VideosViewController: JBSMViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    
    let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    var videos:[Media] = []
    var article: Article?
    
    // MARK: Initializers
    
    init(medias: [Media]) {
        
        flowLayout.itemSize = CellSize
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        
        super.init(nibName: nil, bundle: nil)
        self.videos = medias.sorted(by: {
            $0.sequence.int32Value < $1.sequence.int32Value
        })
        if videos.count > 0 {
            article = videos[0].article
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
    }
    
    // MARK: Setup
    
    func setup() {
        title = "Videos"
        
        view.backgroundColor = UIColor.veryLightGray()
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = UIColor.veryLightGray()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupAutoLayout()
        setupNavigationBar()
    }
    
    func setupAutoLayout() {
        constrain(collectionView) { (collectionView) -> () in
            guard let superview = collectionView.superview else {
                return
            }
            collectionView.left == superview.left
            collectionView.top == superview.top
            collectionView.right == superview.right
            collectionView.bottom == superview.bottom
        }
    }
    
    // MARK: TableView
    
    override func updateViewsForScreenChange(_ type: ScreenType) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = videos[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! VideoCollectionViewCell
        cell.contentView.backgroundColor = UIColor.white
        cell.setup(video: media)
        cell.media = media
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let cvWidth = view.frame.width - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right
        return widthForCellWithCollectionViewWidth(cvWidth)
    }
    
    func widthForCellWithCollectionViewWidth(_ width: CGFloat) -> CGSize {
        let paddingWidth: CGFloat = 8
        var numberOfCells: CGFloat = 1
        if width <= 507 {
            numberOfCells = 1
        } else if width <= 768 {
            numberOfCells = 2
        } else {
            numberOfCells = 3
        }
        let numberOfPadding = -1 + numberOfCells
        let spaceForCells = width - (numberOfPadding * paddingWidth)
        let cellWidth = spaceForCells / numberOfCells
        
        let _size = CGSize(width: cellWidth, height: (cellWidth * (2/3)) + 100)
        
        return _size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = videos.count
        return count
    }
    
    override func setupNavigationBar() {
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
        navigationItem.leftBarButtonItem = closeBarButtonItem
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func getMapForContentValuesForAnalytics() -> [String: AnyObject]? {
        guard let article = self.article else {
            return nil
        }
        
        var issueNumber: String?
        if let _issueNumber = article.issue?.issueNumber {
            issueNumber = _issueNumber
        }
        
        var contentUsageMap = AnalyticsHelper.MainInstance.createMapForContentUsage(
            article.journal.accessType,
            contentID: article.articleInfoId,
            bibliographic: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: issueNumber),
            contentFormat: Constants.Content.ValueFormatHTML,
            contentInnovationName: nil,
            contentStatus: nil,
            contentTitle: article.articleTitle,
            contentType: Constants.Content.ValueTypeFull,
            contentViewState: Constants.ScreenType.FullText
        )
        
        contentUsageMap[Constants.Events.HTMLView] = "1" as AnyObject?

        return contentUsageMap
    }
    
    fileprivate func getProductInfoForAnalytics(_ article: Article) -> String {
        
        guard let article = self.article else {
            return ""
        }
        
        var issueNumber: String?
        if let _issueNumber = article.issue?.issueNumber {
            issueNumber = _issueNumber
        }
        
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            article.articleInfoId,
            fileFormat: Constants.Content.ValueFormatHTML,
            contentType: Constants.Content.ValueTypeFull,
            bibliographicInfo: AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: issueNumber),
            articleStatus: nil,
            articleTitle: article.articleTitle!.lowercased(),
            accessType: article.journal.accessType
        )
    }
}

extension VideosViewController: VideoCollectionViewCellDelegate {
    
    func videoCollectionCellPlayButtonWasClicked(_ video: Media) {
        
        let article = video.article
        if video.userHasAccess == true || video.articleType == .abstract || video.downloadStatus == .downloading || video.downloadStatus == .downloaded {
            switch video.downloadStatus {
            case .downloaded:
                pushVideoViewControllerForMedia(video)
            default:
                if !InternetHelper.sharedInstance.available {
                    navigationController?.present(Alerts.NoNetwork(), animated: true, completion: nil)
                    return
                }
                pushVideoViewControllerForMedia(video)
            }
        } else if article?.userHasAccess == false {
            showMediaAuthAlert(media: video, forDownload: false)
        }
    }
    
    func videoCollectionCellDownloadButtonWasClicked(_ video: Media) {
        if !InternetHelper.sharedInstance.available {
            navigationController?.present(Alerts.NoNetwork(), animated: true, completion: nil)
            return
        }
        guard video.userHasAccess || video.articleType == .abstract else {
            showMediaAuthenticationAlert(media: video, forDownload: false)
            return
        }
        Alerts.DownloadMedia(video, fullText: true).present(from: self)
    }
    
    func pushVideoViewControllerForMedia(_ video: Media) {
        let videoVC = VideoViewController(media: video, isDismissable: false)
        navigationController?.pushViewController(videoVC, animated: true)
    }
}


//  MARK: LoginVcDelegate override


extension VideosViewController {
    
    override func didLoginForMedia(_ media: Media, forDownload: Bool) {
        super.didLoginForMedia(media, forDownload: forDownload)
        
        if forDownload == false {
            switch media.downloadStatus {
            case .downloaded:
                pushVideoViewControllerForMedia(media)
            default:
                if !InternetHelper.sharedInstance.available {
                    navigationController?.present(Alerts.NoNetwork(), animated: true, completion: nil)
                    return
                }
                pushVideoViewControllerForMedia(media)
            }
        }
    }
}


