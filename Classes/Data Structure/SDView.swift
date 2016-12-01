//
//  View.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/12/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import Cartography

protocol SectionDataViewDelegate: class {
    func sectionViewDidToggleCollapseForIndex(_ index: Int)
    func sectionViewDidToggleCollapseAll(_ collapse: Bool)
}

protocol CollectionSectionViewDelegate: class {
    func sectionViewDidCollapseAll()
    func sectionViewDidExpandAll()
    func sectionViewDidCollapseAtIndex(_ index: Int)
    func sectionViewDidExpandAtIndex(_ index: Int)
    
}

extension SectionsData {
    class View: UIView {
        
        weak var delegate: SectionDataViewDelegate?
        weak var viewDelegate: CollectionSectionViewDelegate?
        
        fileprivate var section: Int?
        
        var collapsable = true
        
        static let Identifier = "SectionsData.HeaderView"
        
        fileprivate let titleLabel = UILabel()
        fileprivate let collapseButton = UIButton(type: .custom)
        
        fileprivate let topSeparatorView = UIView()
        fileprivate let bottomSeparatorView = UIView()
        
        fileprivate var collapseButtonWidthConstraint: NSLayoutConstraint?
        fileprivate var collapseButtonLeftConstraint: NSLayoutConstraint?
        
        fileprivate let sectionColor = UIView()
        
        override init(frame: CGRect) {
            super.init(frame: CGRect.zero)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        fileprivate func setup() {
            setupView()
            setupSubviews()
            setupAutoLayout()
            setupTitleLabel()
            setupCollapseButton()
            setupSeparatorViews()
            
            titleLabel.isAccessibilityElement = false
            collapseButton.isAccessibilityElement = false
            topSeparatorView.isAccessibilityElement = false
            bottomSeparatorView.isAccessibilityElement = false
            isAccessibilityElement = true
        }
        
        fileprivate func setupView() {
            backgroundColor = UIColor.colorWithHexString("D8D8D8")
        }
        
        fileprivate func setupSubviews() {
            addSubview(sectionColor)
            addSubview(collapseButton)
            addSubview(topSeparatorView)
            addSubview(bottomSeparatorView)
            addSubview(titleLabel)
        }
        
        fileprivate func setupAutoLayout() {
            
            let subviews = [
                topSeparatorView,
                titleLabel,
                bottomSeparatorView,
                collapseButton,
                sectionColor
            ]
            
            constrain(subviews) { (views) in
                let topSeparatorV    = views[0]
                let titleL           = views[1]
                let bottomSeparatorV = views[2]
                let collapseB        = views[3]
                let sectionColor     = views[4]
                
                guard let superview = titleL.superview else {
                    return
                }
                
                //superview.height >= 22 + (Config.Padding.Default * 2)
                
                sectionColor.top == superview.top
                sectionColor.left == superview.left
                sectionColor.bottom == superview.bottom
                sectionColor.width == Config.Padding.Default + 11
                
                topSeparatorV.top == superview.top
                topSeparatorV.right == superview.right
                topSeparatorV.left == superview.left
                topSeparatorV.height == 1
                
                collapseButtonLeftConstraint = (collapseB.left == superview.left + Config.Padding.Default)
                collapseB.centerY == superview.centerY
                collapseB.height == 22
                collapseButtonWidthConstraint = (collapseB.width == 22)
                
                titleL.right == superview.right - Config.Padding.Default
                titleL.left == collapseB.right + Config.Padding.Default
                titleL.centerY == superview.centerY
                
                bottomSeparatorV.right == superview.right
                bottomSeparatorV.bottom == superview.bottom
                bottomSeparatorV.left == superview.left
                bottomSeparatorV.height == 1
            }
        }
        
        fileprivate func setupTitleLabel() {
            titleLabel.textColor = UIColor.colorWithHexString("6B6C6C")
            titleLabel.font = AppConfiguration.DefaultBoldTitleFont
        }
        
        fileprivate func setupCollapseButton() {
            let collapsedImage = UIImage(named: "Button_Collapsed")!
            let expandedImage = UIImage(named: "Button_Expanded")!
            
            collapseButton.setImage(collapsedImage, for: .selected)
            collapseButton.setImage(expandedImage, for: UIControlState())
            collapseButton.isUserInteractionEnabled = false
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(collapseButtonWasClicked(_:)))
            self.addGestureRecognizer(tapGesture)
        }
        
        fileprivate func setupSeparatorViews() {
            topSeparatorView.backgroundColor = UIColor.gray
            bottomSeparatorView.backgroundColor = UIColor.gray
        }
        
        // MARK: - Update -
        
        func update(_ title: String, section: Int, collapsed: Bool = false) {
            self.collapseButton.isSelected = collapsed
            self.titleLabel.text = title
            self.section = section
            
            if collapsable == true {
                collapseButtonLeftConstraint?.constant = Config.Padding.Default
                collapseButtonWidthConstraint?.constant = 22
            } else {
                collapseButtonLeftConstraint?.constant = 0
                collapseButtonWidthConstraint?.constant = 0
            }
            updateAccessibility(title: title, collapsed: collapsed)
        }
        
        func update(_ title: String, section: Int, color: UIColor?, collapsed: Bool = false) {
            self.collapseButton.isSelected = collapsed
            self.titleLabel.text = title
            self.section = section
            
            if collapsable == true {
                collapseButtonLeftConstraint?.constant = Config.Padding.Default
                collapseButtonWidthConstraint?.constant = 22
            } else {
                collapseButtonLeftConstraint?.constant = 0
                collapseButtonWidthConstraint?.constant = 0
            }
            
            if let _color = color {
                sectionColor.backgroundColor = _color
                sectionColor.isHidden = false
            } else {
                sectionColor.isHidden = true
            }
            updateAccessibility(title: title, collapsed: collapsed)
        }
        
        func updateAccessibility(title: String, collapsed: Bool) {
            var accessibility = "\(title) section "
            if collapsed == true {
                accessibility += "collapsed"
            } else {
                accessibility += "expanded"
            }
            self.accessibilityLabel = accessibility
        }
        
        // MARK: - Reuse -
        
        func reset() {
            titleLabel.text = nil
            collapseButton.isSelected = false
            delegate = nil
            section = nil
            sectionColor.backgroundColor = UIColor.clear
        }
        
        // Other
        
        @objc fileprivate func collapseButtonWasClicked(_ sender: UIView) {
            guard collapsable == true, let sectionIndex = section else {
                return
            }
            if collapseButton.isSelected == true {
                collapseButton.isSelected = false
                viewDelegate?.sectionViewDidExpandAtIndex(sectionIndex)
                delegate?.sectionViewDidToggleCollapseForIndex(sectionIndex)
            } else {
                collapseButton.isSelected = true
                viewDelegate?.sectionViewDidCollapseAtIndex(sectionIndex)
                delegate?.sectionViewDidToggleCollapseForIndex(sectionIndex)
            }
        }
    }
}

