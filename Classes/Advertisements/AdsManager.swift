//
// AdsManager.swift
// JBSM
//

import Foundation
//import GoogleMobileAds

/**
This class is responsible for everything that has to do with Ads.
*/

open class AdsManager {
  
  /**
  Declairs whether we are in testing mode.
  */
  static var Testing:Bool = false
  
  let adUnitId = "ca-app-pub-3940256099942544/2934735716"
  var isTesting:Bool = {
    return AdsManager.Testing
    }()
  
  init() {
    
  }
  
  /**
  Sets up the Ad Banner View
  */
  
  /*public func setupBannerView(adView: GADBannerView, controller: UIViewController) {
    adView.adUnitID = adUnitId
    
    adView.rootViewController = controller
    if let c = controller as? GADBannerViewDelegate {
      adView.delegate = c
    }
    
    let request = GADRequest()
    if isTesting == true {
      request.testDevices = [kGADSimulatorID]
    }
    adView.loadRequest(request)
  }*/
}
