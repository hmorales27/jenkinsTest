//
//  TextSizeViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/12/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

enum TextSizeType: Int {
    case small = 0
    case smallMedium = 1
    case medium = 2
    case mediumLarge = 3
    case large = 4
}

protocol TextSizeViewControllerDelegate: class {
    func textSizeShouldUpdateToSize(_ textSize: TextSizeType)
}



class TextSizeViewController: UIViewController, TextSizeButtonDelegate {
    
    weak var delegate: TextSizeViewControllerDelegate?
    
    let smallButton = TextSizeButton(type: .small)
    let smallMediumButton = TextSizeButton(type: .smallMedium)
    let mediumButton = TextSizeButton(type: .medium)
    let mediumLargeButton = TextSizeButton(type: .mediumLarge)
    let largeButton = TextSizeButton(type: .large)
    
    var selectedButton: TextSizeButton {
        switch fontSize {
        case .small:
            return smallButton
        case .smallMedium:
            return smallMediumButton
        case .medium:
            return mediumButton
        case .mediumLarge:
            return mediumLargeButton
        case .large:
            return largeButton
        }
    }
    
    func buttonForSizeType(_ size: TextSizeType) -> TextSizeButton {
        switch size {
        case .small:
            return smallButton
        case .smallMedium:
            return smallMediumButton
        case .medium:
            return mediumButton
        case .mediumLarge:
            return mediumLargeButton
        case .large:
            return largeButton
        }
    }
    
    var fontSize:TextSizeType = .small
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        if let value = UserDefaults.standard.value(forKey: Strings.TextSize.UserDefaultsKey) as? Int {
            if let type = TextSizeType(rawValue: value) {
                fontSize = type
            }
        }
        
        switch fontSize {
        case .small:
            smallButton.updateAsSelected()
        case .smallMedium:
            smallMediumButton.updateAsSelected()
        case .medium:
            mediumButton.updateAsSelected()
        case .mediumLarge:
            mediumLargeButton.updateAsSelected()
        case .large:
            largeButton.updateAsSelected()
        }
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setup() {
        smallButton.delegate = self
        smallMediumButton.delegate = self
        mediumButton.delegate = self
        mediumLargeButton.delegate = self
        largeButton.delegate = self
        
        //view.backgroundColor = UIColor.whiteColor()
        title = "Font"
        
        setupSubviews()
        setupAutLayout()
    }
    
    func setupSubviews() {
        view.addSubview(smallButton)
        view.addSubview(smallMediumButton)
        view.addSubview(mediumButton)
        view.addSubview(mediumLargeButton)
        view.addSubview(largeButton)
    }
    
    func setupAutLayout() {
        
        let subviews = [
            smallButton,
            smallMediumButton,
            mediumButton,
            mediumLargeButton,
            largeButton
        ]
        
        constrain(subviews) { (views) in
            
            let small = views[0]
            let smallMedium = views[1]
            let medium = views[2]
            let mediumLarge = views[3]
            let large = views[4]
            
            guard let superview = small.superview else {
                return
            }
            
            small.left == superview.left
            small.centerY == superview.centerY
            
            smallMedium.left == small.right
            smallMedium.centerY == superview.centerY
            
            medium.left == smallMedium.right
            medium.centerY == superview.centerY
            
            mediumLarge.left == medium.right
            mediumLarge.centerY == superview.centerY
            
            large.right == superview.right
            large.left == mediumLarge.right
            large.centerY == superview.centerY
        }
    }
    
    // MARK: - Text Size Button Delegate -
    
    func userDidSelectType(_ type: TextSizeType) {
        selectedButton.updateAttributedString()
        let button = buttonForSizeType(type)
        button.updateAsSelected()
        self.fontSize = type
        UserDefaults.standard.setValue(fontSize.rawValue, forKey: Strings.TextSize.UserDefaultsKey)
        delegate?.textSizeShouldUpdateToSize(type)
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Font.DidChange), object: fontSize.rawValue)
    }
}

protocol TextSizeButtonDelegate: class {
    func userDidSelectType(_ type: TextSizeType)
}

class TextSizeButton: UILabel {
    
    var type: TextSizeType
    var delegate: TextSizeButtonDelegate?
    
    let underlineView = UILabel()
    
    init(type: TextSizeType) {
        self.type = type
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidSelectType))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        updateAttributedString()
        backgroundColor = UIColor.white
        textAlignment = .center
        
        setupSubviews()
        underlineView.backgroundColor = UIColor.gray
        underlineView.isHidden = true
        
        setupAutoLayout()
        
    }
    
    func setupSubviews() {
        addSubview(underlineView)
    }
    
    func setupAutoLayout() {
        constrain(self, underlineView) { (view, underline) in
            view.width == 40
            view.height == 40
            
            underline.bottom == view.bottom - 8
            underline.height == 2
            underline.width == 20
            underline.centerX == view.centerX
        }
    }
    
    func updateAttributedString() {
        switch type {
        case .small:
            attributedText = NSAttributedString(string: "A", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
        case .smallMedium:
            attributedText = NSAttributedString(string: "A", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
        case .medium:
            attributedText = NSAttributedString(string: "A", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        case .mediumLarge:
            attributedText = NSAttributedString(string: "A", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)])
        case .large:
            attributedText = NSAttributedString(string: "A", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
        }
        underlineView.isHidden = true
    }
    
    func updateAsSelected() {
        
        var fontSize: CGFloat = 12
        switch type {
        case .small:
            fontSize = 12
        case .smallMedium:
            fontSize = 14
        case .medium:
            fontSize = 16
        case .mediumLarge:
            fontSize = 18
        case .large:
            fontSize = 20
        }
        let attributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize)
        ]
        
        attributedText = NSAttributedString(string: "A", attributes: attributes)
        underlineView.isHidden = false
    }
    
    func userDidSelectType() {
        delegate?.userDidSelectType(type)
    }
    
}
