//
//  FullPageAdViewController.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 4/23/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
import GoogleMobileAds

class FullPageAdViewController: JBSMViewController, GADBannerViewDelegate, GADAdSizeDelegate {
    
    let spinner = UIActivityIndicatorView()
    
    let adView: GADBannerView
    var adUnitID: String!
    
    var isIpadPro: Bool {
        let size = view.frame.size
        
        if size.width > 1023 && size.height > 768 {
            
            return true
        
        } else {
        
            return false
        }
    }
    
    
    var request: GADRequest {
        let _request = GADRequest()
        
        return _request
    }
    
    var viewSize: CGSize {
        get {
            switch screenType {
            case .mobile:
                return CGSize(width: 320, height: 480)
            case .tablet:
                if view.frame.width > view.frame.height {
                    return CGSize(width: 1024, height: 768)
                } else {
                    return CGSize(width: 768, height: 1024)
                }
            }
        }
    }
    
    // MARK: - Initializer -
    
    init(journal: Journal) {
        
        //self.adUnitID = adUnitID
        self.adView = GADBannerView(frame: CGRect.zero)
        
        super.init(nibName: nil, bundle: nil)
        
        self.currentJournal = journal
        
        self.view.backgroundColor = UIColor.white
        
        setup()
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(rotated(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        
        //adView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        spinner.stopAnimating()
    }
    
    func rotated(notification: NSNotification)
    {
        var adSize: GADAdSize?
        
        if isIpadPro == false {
            if UIDevice.current.orientation.isLandscape {
                
                adSize = kGADAdSizeSmartBannerLandscape
                
            } else {
                adSize = kGADAdSizeSmartBannerPortrait
            }
        }
        
        guard let _adSize = adSize else {
            
            setupAutoLayout()
            load()
            return
        }
        
        //  May need to send another request for the ad here? Need to look at the logic for how
        //  the banner view gets specified ad image sizes.
        adView.adSize = _adSize
        setupAutoLayout()
        load()
    }

    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupSpinner()
        setupAdView()
        setupAutoLayout()
    }
    
    func setupSubviews() {
        view.addSubview(spinner)
        view.addSubview(adView)
    }
    
    func setupAdView() {
        adView.delegate = self
        adView.rootViewController = self
        var adSize: GADAdSize?
        
        if isIpadPro == false {
            if UIDevice.current.orientation.isLandscape {
                adSize = kGADAdSizeSmartBannerLandscape
            } else {
                adSize = kGADAdSizeSmartBannerPortrait
            }
        }
        
        guard let _adSize = adSize else { return }
        
        adView.adSize = _adSize
    }
    
    
    func setupSpinner() {
        spinner.hidesWhenStopped = true
        spinner.color = UIColor.lightGray
    }
    
    
    func setupAutoLayout() {
        let subviews = [
            spinner,
            adView
        ]
        constrain(subviews) { (views) in
            let spin = views[0]
            let adV = views[1]
            guard let superview = adV.superview else {
                return
            }
            spin.center == superview.center
            spin.width == 25
            spin.height == 25
            
            adV.centerY == superview.centerY
            adV.centerX == superview.centerX
            
            if isIpadPro == false {
                adV.width == superview.width
                adV.height == superview.height
            }
        }
    }
    
    func load() {
        loadRequest()
    }
    
    func loadRequest() {
        guard let journal = self.currentJournal else {
            return
        }
        
        spinner.startAnimating()
        
        adView.rootViewController = self
        
            switch self.screenType {
            case .mobile:
                self.adView.adUnitID = journal.adFullPagePortraitIPhone4
            case .tablet:
                switch JBSMDevice().currentOrientation() {
                case .portrait, .portraitUpsideDown:
                    self.adView.adUnitID = journal.adFullPagePortraitIPad
                default:
                    self.adView.adUnitID = journal.adFullPageLandscapeIPad
                }
            }
        self.adView.frame.size = self.viewSize

        self.adView.load(self.request)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        spinner.stopAnimating()
        log.verbose("Ad Successful")
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        spinner.stopAnimating()
        log.warning(error.localizedDescription)
    }
    
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        print(size)
    }
}
