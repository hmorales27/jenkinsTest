//
//  AdvertisementViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 7/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
import GoogleMobileAds

private let JBSMIPadAdSize = kGADAdSizeLeaderboard
private let JBSMIPhoneAdSize = GADAdSize(size: CGSize(width: 300, height: 50), flags: 0)

enum AdType {
    case iPadPortrait
    case iPadLandscape
    case iPadSkyScraper
    case iPhonePortrait
    
    func gadSize() -> GADAdSize {
        switch self {
        case .iPadPortrait:
            return JBSMIPadAdSize
        case .iPadLandscape:
            return JBSMIPadAdSize
        case .iPadSkyScraper:
            return JBSMIPhoneAdSize
        case .iPhonePortrait:
            return JBSMIPhoneAdSize
        }
    }
}

class AdvertisementViewController: UIViewController, GADBannerViewDelegate {
    
    weak var widthConstraint: NSLayoutConstraint?
    weak var heightConstraint: NSLayoutConstraint?
    
    weak var topConstraint: NSLayoutConstraint?
    weak var bottomConstraint: NSLayoutConstraint?
    
    var type: AdType?
    
    var splashScreen: Bool = false
    
    let adView = GADBannerView()
    
    init(type: AdType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        adView.rootViewController = self
        adView.delegate = self
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        adView.rootViewController = self
        adView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    fileprivate var iPadLandscapeAdUnitId = ""
    fileprivate var iPadPortraitAdUnitId = ""
    fileprivate var iPadSkyScraperAdUnitId = ""
    fileprivate var iPhonePortraitAdUnitId = ""
    
    func setup(_ type: AdType, publisher: Publisher) {
        if let adUnitId = publisher.adFullPageLandscapeIPad {
            iPadLandscapeAdUnitId = adUnitId
        }
        if let adUnitId = publisher.adBannerPortraitIPad {
            iPadPortraitAdUnitId = adUnitId
        }
        if let adUnitId = publisher.adBannerPortraitIPhone {
            iPhonePortraitAdUnitId = adUnitId
        }
        
        self.type = type
        setup()
    }
    
    func setup(_ type: AdType, journal: Journal) {
        
        if let adUnitId = journal.adFullPageLandscapeIPad {
            iPadLandscapeAdUnitId = adUnitId
        }
        if let adUnitId = journal.adBannerPortraitIPad {
            iPadPortraitAdUnitId = adUnitId
        }
        if let adUnitId = journal.adBannerPortraitIPhone {
            iPhonePortraitAdUnitId = adUnitId
        }
        
        self.type = type
        setup()
    }
    
    func loadAd() {
        let request = GADRequest()
        if Strings.IsTestAds { request.testDevices = [kGADSimulatorID] }
        adView.load(request)
    }
    
    fileprivate func setup() {
        view.addSubview(adView)
        if self.view.frame.width < 728 {
            adView.adSize = JBSMIPhoneAdSize
            adView.adUnitID = iPhonePortraitAdUnitId
        } else {
            
            let orientation = UIApplication.shared.statusBarOrientation
            
            
            adView.adSize = JBSMIPadAdSize
            
            if orientation == .portrait || orientation == .portraitUpsideDown {
                adView.adUnitID = iPadPortraitAdUnitId
            
            } else if orientation == .landscapeLeft || orientation == .landscapeRight {
                
                adView.adUnitID = iPadLandscapeAdUnitId
            }
        }
        
        if splashScreen {
            setupAutoLayoutForSplashScreen()
        } else {
            setupAutoLayout()
        }

        loadAd()
        adView.accessibilityLabel = "Advertisement"
    }
    
    func setupAutoLayout() {
        
        constrain(adView) { (adV) in
            
            guard let superview = adV.superview else { return }
            
            adV.top == superview.top
            adV.bottom == superview.bottom
            adV.centerX == superview.centerX
            
            if self.view.frame.width < 728 {
                widthConstraint = (adV.width == JBSMIPhoneAdSize.size.width)
                heightConstraint = (adV.height == JBSMIPhoneAdSize.size.height)
            } else {
                widthConstraint = (adV.width == JBSMIPadAdSize.size.width)
                heightConstraint = (adV.height == JBSMIPadAdSize.size.height)
            }
        }
    }
    
    func setupAutoLayoutForSplashScreen() {
        
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        log.error(error.localizedDescription)
        guard let height = heightConstraint?.constant else { return }
        bottomConstraint?.constant = height
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
//        
//        if !ScreenshotStrings.RunningSnapshots {
//            bottomConstraint?.constant = 0
//        }

        let adSubview = adView.subviews.first
        if let subviews = adSubview?.subviews {
            for view in subviews {
                if view is UIWebView {
                    view.isAccessibilityElement = true
                    view.accessibilityLabel = "advertisement"
                }
            }
        }
    }
}
