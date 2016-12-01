/*
 * AdBannerView
*/

import UIKit
import GoogleMobileAds
import Cartography

class AdBannerView: GADBannerView, GADBannerViewDelegate {
    
    var topConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    var leftConstraint: NSLayoutConstraint?
    
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    /*
     * MARK: INITIALIZERS
    */
    
    init(rootViewController: UIViewController) {
        super.init(frame: CGRect.zero)
        self.rootViewController = rootViewController
        self.delegate = self
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     * MARK: SETUP
    */
    
    func setup() {
        setupAutoLayout()
        setupNotifications()
        setupView()
    }
    
    func setupAutoLayout() {
        constrain(self) { (view) in
            heightConstraint = (view.height == 0)
            widthConstraint = (view.width == 0)
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func setupRequest() {
        let request = GADRequest()
        if Strings.IsTestAds {
            request.testDevices = [kGADSimulatorID]
        }
        load(request)
    }
    
    func setupView() {
        let device = UI_USER_INTERFACE_IDIOM()
        let orientation = JBSMDevice().currentOrientation()
        
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
        let request = GADRequest()
        if Strings.IsTestAds {
            request.testDevices = [kGADSimulatorID]
        }
        widthConstraint?.constant = 728
        heightConstraint?.constant = 90
        adSize = kGADAdSizeLeaderboard
        let publisher = DatabaseManager.SharedInstance.getAppPublisher()
        if let ipadLeaderboard = publisher?.adFullPageLandscapeIPad {
            adUnitID = ipadLeaderboard
        }
        load(request)
    }
    
    func setupViewForIPadPortrait() {
        let request = GADRequest()
        if Strings.IsTestAds {
            request.testDevices = [kGADSimulatorID]
        }
        widthConstraint?.constant = 728
        heightConstraint?.constant = 90
        adSize = kGADAdSizeLeaderboard
        let publisher = DatabaseManager.SharedInstance.getAppPublisher()
        if let ipadLeaderboard = publisher?.adBannerPortraitIPad {
            adUnitID = ipadLeaderboard
        }
        load(request)
    }
    
    func setupViewForIPhonePortrait() {
        widthConstraint?.constant = 300
        heightConstraint?.constant = 50
    }
    
    /*
     * MARK: NOTIFICATIONS
    */
    
    func deviceOrientationDidChange(_ notification: Foundation.Notification) {
        setupView()
    }
    
    /*
     * MARK: AD DELEGATE
    */
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        log.verbose("")
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        log.error("Failed: \(error.localizedDescription)")
    }
    
}
