//
//  JBSMAdBannerView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/15/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import Cartography

class JBSMAdBannerView: GADBannerView {
    
    var topConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    var leftConstraint: NSLayoutConstraint?
    
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    let configuration = DatabaseManager.SharedInstance.getAppPublisher()!
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    init(type: String, config: String) {
        super.init(frame: CGRect.zero)
        if type == "Skyscraper" {
            constrain(self, block: { (ad) -> () in
                widthConstraint = (ad.width == 160)
                heightConstraint = (ad.height == 600)
            })
            adSize = kGADAdSizeSkyscraper
            adUnitID = config
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        constrain(self) { (view) -> () in
            heightConstraint = (view.height == 0)
            widthConstraint = (view.width == 0)
        }

        setupView(device: UI_USER_INTERFACE_IDIOM(), orientation: JBSMDevice().currentOrientation())
        
        switch JBSMDevice().currentOrientation() {
        case .portrait, .portraitUpsideDown:
            adUnitID = configuration.adBannerPortraitIPad
        case .landscapeLeft, .landscapeRight:
            adUnitID = configuration.adFullPageLandscapeIPad
        default:
            break
        }
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupView(device: UIUserInterfaceIdiom, orientation: UIDeviceOrientation) {
        if device == UIUserInterfaceIdiom.pad {
            if orientation == .landscapeLeft || orientation == .landscapeRight {
                setupViewForIPadLandscape()
            } else {
                setupViewForIPadPortrait()
            }
        } else {
            setupViewForIPhonePortrait()
        }
    }
    
    func setupViewForIPadLandscape() {
        widthConstraint?.constant = 728
        heightConstraint?.constant = 90
        adSize = kGADAdSizeLeaderboard
    }
    
    func setupViewForIPadPortrait() {
        widthConstraint?.constant = 728
        heightConstraint?.constant = 90
    }
    
    func setupViewForIPhonePortrait() {
        widthConstraint?.constant = 300
        heightConstraint?.constant = 50
    }
    
    func deviceOrientationDidChange() {
        setupView(device: UI_USER_INTERFACE_IDIOM(), orientation: JBSMDevice().currentOrientation())
    }
}
