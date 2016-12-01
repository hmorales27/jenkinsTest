//
//  BrandImageView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/14/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let DefaultSocietyIPadPortraitImageName = "DefaultSocietyLogo-Portrait"
private let DefaultSocietyIPadLandscapeImageName = "DefaultSocietyLogo-Landscape"
private let DefaultSocietyIPhonePortraitImageName = "DefaultSocietyLogo-Phone"

private let DefaultBrandLogoLandscape = "DefaultBrandLogo-Landscape"
private let DefaultBrandLogoPortrait = "DefaultBrandLogo-Portrait"
private let DefaultBrandLogoPhone = "DefaultBrandLogo-Phone"

class BrandImageView: JBSMImageView {
    
    let society: Bool
    
    lazy var defaultBrandLogoLandscape: UIImage = {
        if self.society == true {
            return UIImage(named: DefaultSocietyIPadLandscapeImageName)!
        } else {
            return UIImage(named: DefaultBrandLogoLandscape)!
        }
    }()
    
    lazy var defaultBrandLogoPortrait: UIImage = {
        if self.society == true {
            return UIImage(named: DefaultSocietyIPadPortraitImageName)!
        } else {
            return UIImage(named: DefaultBrandLogoPortrait)!
        }
    }()
    
    lazy var defaultBrandLogoPhone: UIImage = {
        if self.society == true {
            return UIImage(named: DefaultSocietyIPhonePortraitImageName)!
        } else {
            return UIImage(named: DefaultBrandLogoPhone)!
        }
    }()
    
    // MARK: - Initializers -
    
    init(society: Bool) {
        self.society = society
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.society = true
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup -
    
    override func setup() {
        super.setup()
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        constrain(self) { (view) -> () in
            //layoutConstraints.height = (view.height == 0)
        }
    }
    
    fileprivate func setupImageForIPadLandscape() {
        image = defaultBrandLogoLandscape
        if let heightConstraint = self.layoutConstraints.height {
            self.removeConstraint(heightConstraint)
        }
        constrain(self) { (view) in
            guard let _image = image else {
                return
            }
            layoutConstraints.height?.constant = _image.size.height
            layoutConstraints.width?.constant = _image.size.width
        }
    }
    
    fileprivate func setupImageForIPadPortrait() {
        image = defaultBrandLogoPortrait
        if let heightConstraint = layoutConstraints.height {
            self.removeConstraint(heightConstraint)
        }
        constrain(self) { (view) in
            guard let _image = image else {
                return
            }
            layoutConstraints.height?.constant = _image.size.height
            layoutConstraints.width?.constant = _image.size.width
        }
    }
    
    fileprivate func setupImageForIPhonePortrait() {
        image = defaultBrandLogoPhone
        if let heightConstraint = layoutConstraints.height {
            self.removeConstraint(heightConstraint)
        }
        constrain(self) { (view) in
            guard let _image = image else {
                return
            }
            layoutConstraints.height?.constant = _image.size.height
            layoutConstraints.width?.constant = _image.size.width
        }
    }
    
    // MARK: - Update -
    
    func update(screenType type: ScreenType) {
        switch type {
        case .mobile:
            setupImageForIPhonePortrait()
        case .tablet:
            switch OrientationType.CurrentOrientation() {
            case .portrait:
                setupImageForIPadPortrait()
            case .landscape:
                setupImageForIPadLandscape()
            default:
                break
            }
        }
    }
    
    func update(_ size: CGSize) {
        if size.width >= 960 {
            setupImageForIPadLandscape()
        } else if size.width >= 728 {
            setupImageForIPadPortrait()
        } else {
            setupImageForIPhonePortrait()
        }
    }
    
    // MARK: - Deprecated -
    
    @available(*, deprecated: 0.2)
    func deviceOrientationDidChange() {
        setupImage(device: UI_USER_INTERFACE_IDIOM(), orientation: JBSMDevice().currentOrientation())
    }
    
    @available(*, deprecated: 0.2)
    func setupImage(device: UIUserInterfaceIdiom, orientation: UIDeviceOrientation) {
        if device == UIUserInterfaceIdiom.pad {
            if orientation == .landscapeLeft || orientation == .landscapeRight {
                setupImageForIPadLandscape()
            } else {
                setupImageForIPadPortrait()
            }
        } else {
            setupImageForIPhonePortrait()
        }
    }
}
