//
//  CIAvailabilityView.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/22/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CIColor = UIColor(red: 0.20, green: 0.28, blue: 0.56, alpha: 1.0)
private let ButtonSize = CGSize(width: 40, height: 40)
private var LabelPadding: CGFloat = 0

protocol CIAvailabilityViewDelegate: class {
    func ciAvailabilityViewWasSelected()
}

class CIAvailabilityView: UIView {
    
    var delegate: CIAvailabilityViewDelegate?
    var ciManager: CIManager?
    
    let container = UIView()
    let button = UIButton(type: UIButtonType.custom)
    let label = UILabel()
    weak var timer: Timer?
    
    var labelSize: CGFloat = 0
    
    fileprivate var labelLeftConstraint: NSLayoutConstraint?
    fileprivate var labelRightConstraint: NSLayoutConstraint?
    
    // MARK: Initializers
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup() {
        addSubViews()
        setupContainer()
        setupButton()
        setupLabel()
        setupAutoLayout()
    }
    
    func addSubViews() {
        addSubview(container)
        container.addSubview(label)
        container.addSubview(button)
        isHidden = true
    }
    
    func setupContainer() {
        container.backgroundColor = UIColor.colorWithHexString("E4EDF9")
    }
    
    func setupButton() {
        button.setImage(UIImage(named: "CIButton")!, for: UIControlState())
        button.tintColor = CIColor
        button.backgroundColor = UIColor.colorWithHexString("E4EDF9")
        button.accessibilityLabel = "Open list of article enhancements"
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.addTarget(self, action: #selector(ciAvailabilityViewWasClicked(_:)), for: .touchUpInside)
    }
    
    func setupLabel() {
        label.text =  "Open List of Article Enhancements"
        label.backgroundColor = CIColor
        label.textColor = UIColor.white
        label.clipsToBounds = true
        label.textAlignment = NSTextAlignment.center
        label.accessibilityElementsHidden = true
        label.font = UIFont.systemFont(ofSize: 16)
    }
    
    func setupAutoLayout() {
        constrain(container, button, label) { (container, button, label) -> () in
            guard let superview = container.superview else {
                return
            }
            
            superview.width == ButtonSize.width
            superview.height == ButtonSize.height
            
            container.left == superview.left
            container.top == superview.top
            container.right == superview.right
            container.bottom == superview.bottom
            
            button.left == superview.left
            button.top == superview.top
            button.right == superview.right
            button.bottom == superview.bottom
            
            labelLeftConstraint = (label.left == superview.left + LabelPadding)
            label.top == superview.top + LabelPadding
            labelRightConstraint = (label.right == superview.right - LabelPadding)
            label.bottom == superview.bottom - LabelPadding
        }
    }
    
    // MARK: Methods
    
    //  This may be getting called before button gets put onscreen. I'm pretty sure it is.
    func showButtonWithText(_ text: NSString) {
        
        labelSize = text.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)]).width
        
        self.isHidden = false
        self.label.text = text as String
        self.label.accessibilityLabel = text as String
        
        if let widgetModel = ciManager?.response?.widgetModel {
            guard let widgetName = widgetModel.first?.widgetName else { return }
            button.accessibilityLabel = widgetModel.count == 1 ? "Open " + widgetName : button.accessibilityLabel
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(removeAvailabilityLabel), userInfo: nil, repeats: false)
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.labelLeftConstraint?.constant = -(self.labelSize + (16 * 2))
            self.labelRightConstraint?.constant = -ButtonSize.width
            self.layoutIfNeeded()
            
            }) { (finished) -> Void in
                
        }
    }
    
    func removeAvailabilityLabel() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.labelLeftConstraint?.constant = 0
            self.labelRightConstraint?.constant = 0
            self.layoutIfNeeded()
            
            }) { (finished) -> Void in
        }
    }
    
    func reset() {
        timer?.invalidate()
        UIView.animate(withDuration: 0.0, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.labelLeftConstraint?.constant = 0
            self.labelRightConstraint?.constant = 0
            self.layoutIfNeeded()
            }, completion: nil)
    }
    
    func ciAvailabilityViewWasClicked(_ sender: AnyObject) {
        reset()
        delegate?.ciAvailabilityViewWasSelected()
    }
    
    func hideContentInnovationButton() {
        isHidden = true
        reset()
    }
}
