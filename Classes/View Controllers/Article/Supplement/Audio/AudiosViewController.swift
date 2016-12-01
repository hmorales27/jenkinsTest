//
//  AudiosViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/20/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CellIdentifier = "AudioTableViewCell"
private let CellSize = CGSize(width: 300, height: 200)

class AudiosViewController: JBSMViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    let flowLayout = UICollectionViewFlowLayout()
    
    var audios:[Media] = []
    var article: Article?
    
    // MARK: Initializers
    
    init(medias: [Media]) {
        super.init(nibName: nil, bundle: nil)
        audios = medias
        if audios.count > 0 {
            self.article = audios[0].article
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: Setup
    
    func setup() {
        title = "Audio"
        
        view.backgroundColor = UIColor.black
        
        flowLayout.itemSize = CellSize
        flowLayout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.register(AudioCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = UIColor.veryLightGray()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupAutoLayout()
        setupNavigationBar()
    }
    
    func setupAutoLayout() {
        constrain(collectionView) { (collectionView) -> () in
            guard let superview = collectionView.superview else { return }
            collectionView.left == superview.left
            collectionView.top == superview.top
            collectionView.right == superview.right
            collectionView.bottom == superview.bottom
        }
    }
    
    // MARK: TableView
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = audios[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! AudioCollectionViewCell
        cell.contentView.backgroundColor = UIColor.white
        cell.setup(audio: media)
        cell.media = media
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = audios.count
        return count
    }
    
    override func setupNavigationBar() {
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
        navigationItem.leftBarButtonItem = closeBarButtonItem
//        navigationItem.titleView?.accessibilityTraits = UIAccessibilityTraitNone
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Notifications -
    
    func setupNotifications() {
        
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
            contentID             : article.articleInfoId,
            bibliographic         : AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: issueNumber),
            contentFormat         : Constants.Content.ValueFormatHTML,
            contentInnovationName : nil,
            contentStatus         : nil,
            contentTitle          : article.articleTitle,
            contentType           : Constants.Content.ValueTypeFull,
            contentViewState      : Constants.ScreenType.FullText
        )
        
        contentUsageMap[Constants.Events.HTMLView] = "1" as AnyObject?
        
        return contentUsageMap
    }
    
    fileprivate func getProductInfoForAnalytics(_ article: Article) -> String {
        
        guard let article = self.article else { return "" }
        
        var issueNumber: String?
        if let _issueNumber = article.issue?.issueNumber {
            issueNumber = _issueNumber
        }
        
        return AnalyticsHelper.MainInstance.createProductInforForEventAction(
            article.articleInfoId,
            fileFormat        : Constants.Content.ValueFormatHTML,
            contentType       : Constants.Content.ValueTypeFull,
            bibliographicInfo : AnalyticsHelper.MainInstance.createBibliographicInfo(article.issue?.volume, issue: issueNumber),
            articleStatus     : nil,
            articleTitle      : article.articleTitle!.lowercased(),
            accessType        : article.journal.accessType
        )
    }
}

extension AudiosViewController: AudioCollectionViewCellDelegate {
    
    func audioCollectionCellPlayButtonWasClicked(_ audio: Media) {
        if audio.userHasAccess == true  || audio.articleType == .abstract || audio.downloadStatus == .downloaded || audio.downloadStatus == .downloading {
            switch audio.downloadStatus {
            case .downloaded:
                pushAudioViewControllerForMedia(audio)
            default:
                guard NETWORK_AVAILABLE else {
                    Alerts.NoNetwork().present(from: self)
                    return
                }
                pushAudioViewControllerForMedia(audio)
            }
        } else {
            showMediaAuthenticationAlert(media: audio, forDownload: false)
        }
    }
    
    func audioCollectionCellDownloadButtonWasClicked(_ audio: Media) {
        guard NETWORK_AVAILABLE else {
            Alerts.NoNetwork().present(from: self)
            return
        }
        if audio.userHasAccess || audio.articleType == .abstract {
            showDownloadAlertForMedia(audio)
        } else {
            showMediaAuthenticationAlert(media: audio, forDownload: false)
        }
    }
    
    func pushAudioViewControllerForMedia(_ audio: Media) {
        let audioVC = AudioViewController(media: audio, dismissable: false)
        navigationController?.pushViewController(audioVC, animated: true)
    }
    
    func showDownloadAlertForMedia(_ audio: Media) {
        Alerts.DownloadMedia(audio, fullText: true) { (selection) in
            guard let context = self.getMapForContentValuesForAnalytics() else { return }
            AnalyticsHelper.MainInstance.contentDownloadAnalytics(self.getProductInfoForAnalytics(audio.article), contentInfo: context)
        }.present(from: self)
    }
}

//  MARK: Override LoginVcDelegate

extension AudiosViewController {
    
    override func didLoginForMedia(_ media: Media, forDownload: Bool) {
        super.didLoginForMedia(media, forDownload: forDownload)
        
        if forDownload == false {
            switch media.downloadStatus {
            case .downloaded:
                pushAudioViewControllerForMedia(media)
            default:
                guard NETWORK_AVAILABLE else {
                    Alerts.NoNetwork().present(from: self)
                    return
                }
                pushAudioViewControllerForMedia(media)
            }
        }
    }
}

