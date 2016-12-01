//
//  SplashScreenViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/27/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class SplashScreenViewController: JBSMViewController {
    
    let imageView = UIImageView()
    
    var advertisementVC = AdvertisementViewController()
    
    var timerCompleted = false
    var updateCompleted = false
    
    var movedOn = false
    var success = false
    
    var deepLink: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(snapshot: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        addChildViewController(advertisementVC)
        advertisementVC.didMove(toParentViewController: self)
    }
    
    init(deepLink: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.deepLink = deepLink
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        guard !deepLink else {
            return
        }
        
        if ScreenshotStrings.RunningSnapshots {
            if ScreenshotStrings.ScreenName == "SplashScreen" {
                return
            }
            updateMetadataForScreenShots()
            return
        } else {
            updateMetadata()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let publisher = DatabaseManager.SharedInstance.getAppPublisher() {
            advertisementVC.setup(AdType.iPadPortrait, publisher: publisher)
        }
        
        performOnMainThreadAfter(seconds: 5) { 
            self.timerCompleted = true
            
            if self.updateCompleted == true {
                if self.success {
                    self.metadataCallSuccess()
                } else {
                    self.metadataCallFailure()
                }
            }
        }
    }
    
    func updateMetadataForScreenShots() {
        let success = ContentKit.SharedInstance.updateAppMetadataSynchronously()
        if success {
            loadNextView()
        } else {
            assertionFailure("Unable to get App Metadata")
        }
    }
    
    func updateMetadata() {
        
        guard NETWORKING_ENABLED else {
            metadataCallFailure()
            return
        }
        ContentKit.SharedInstance.updateApp(appShortCode: Strings.AppShortCode) { (success) in
            if success == true {
                APIManager.sharedInstance.downloadAnnouncementMetadata(completion: { (success) in
                    
                    self.updateCompleted = true
                    self.success = success
                    
                    APIManager.sharedInstance.multiPartnerList(nil)
                    APIManager.sharedInstance.downloadAppHTML(nil)
                    APIManager.sharedInstance.downloadOpenAccessInformation()
                    APIManager.sharedInstance.downloadLiscenses(nil)
                    MKStoreManager.shared().sendingProductRequests()
                    
                    if self.timerCompleted == true {
                        if success {
                            self.metadataCallSuccess()
                        } else {
                            self.metadataCallFailure()
                        }
                    }
                })
                
                return
                
            } else {
                self.updateCompleted = true
                
                if self.timerCompleted == true {
                    if success {
                        self.metadataCallSuccess()
                    } else {
                        self.metadataCallFailure()
                    }
                }
            }
        }
    }
    
    // MARK: - Setup -
    
    func setup() {
        
        setupSubviews()
        setupAutoLayout()
        setupImageView()
    }
    
    func setupSubviews() {
        view.addSubview(imageView)
        view.addSubview(advertisementVC.view)
    }
    
    func setupAutoLayout() {
        constrain(imageView, advertisementVC.view) { (imageView, adView) -> () in
            guard let superview = imageView.superview else {
                return
            }
            
            imageView.top == superview.top
            imageView.right == superview.right
            imageView.left == superview.left
            imageView.bottom == superview.bottom
            
            //adView.top == imageView.bottom
            adView.right == superview.right
            advertisementVC.bottomConstraint = (adView.bottom == superview.bottom)
            adView.left == superview.left
        }
    }
    
    func setupImageView() {
        switch self.screenType {
        case .mobile:
            imageView.image = UIImage(named: "SplashScreenIPhone")
        case .tablet:
            
            if view.frame.width > view.frame.height {
                imageView.image = UIImage(named: "SplashScreenIPadLandscape")
            } else {
                imageView.image = UIImage(named: "SplashScreenIPadPortrait")
            }
        }
    }
    
    func metadataCallSuccess() {
        APIManager.sharedInstance.downloadAnnouncementMetadata(completion: nil)
        loadNextView()
    }
    
    func metadataCallFailure() {
        loadNextView()
    }
    
    func loadNextView() {
        let journals = DatabaseManager.SharedInstance.getAllJournals()
        if journals.count == 0 {
            noJournalsAvailable()
        } else if journals.count == 1 {
            loadSingleJournal(journals[0])
        } else {
            loadPublication(journals[0].publisher)
        }
    }

    func goToNextView(journals: [Journal]) {}
    
    func loadSingleJournal(_ journal: Journal) {
       AnalyticsHelper.MainInstance.isMultiJournal = false
        performOnMainThread { 
            let highlightVC = HighlightViewController(journal: journal)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = UINavigationController(rootViewController: highlightVC)
        }
    }
    
    func loadPublication(_ publisher: Publisher) {
        AnalyticsHelper.MainInstance.isMultiJournal = true
        performOnMainThread {
            let publisherVC = MultiJournalViewController(publisher: publisher)
            self.overlord?.removeAllAndPushViewController(publisherVC, animated: false)
        }
    }
    
    func noJournalsAvailable() {
        DispatchQueue.main.async { () -> Void in
            log.warning("Metadata call completed with no Journals")
            let alertView = UIAlertController(title: nil, message: "No Journals Are Configured.", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                //assertionFailure()
            }))
            self.present(alertView, animated: true, completion: nil)
        }
    }
}
