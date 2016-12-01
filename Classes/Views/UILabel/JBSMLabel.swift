//
//  JBSMLabel.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/13/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class JBSMLabel: UILabel {
    
    var constraint = JBSMLayoutConstraints()
    var selected = false
    
    let selectionView = UIView()
    
    // Deprecated
    
    @available(*, deprecated: 0.2)
    var topConstraint: NSLayoutConstraint? {
        get {
            return constraint.top
        }
        set(_constraint) {
            constraint.top = _constraint
        }
    }
    
    @available(*, deprecated: 0.2)
    var rightConstraint: NSLayoutConstraint? {
        get {
            return constraint.right
        }
        set(_constraint) {
            constraint.right = _constraint
        }
    }
    
    @available(*, deprecated: 0.2)
    var bottomConstraint: NSLayoutConstraint? {
        get {
            return constraint.bottom
        }
        set(_constraint) {
            constraint.bottom = _constraint
        }
    }
    
    @available(*, deprecated: 0.2)
    var leftConstraint: NSLayoutConstraint? {
        get {
            return constraint.left
        }
        set(_constraint) {
            constraint.left = _constraint
        }
    }
    
    // MARK: - Initializers -
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    func setGestureAction(_ gesture: UITapGestureRecognizer){
        isUserInteractionEnabled = true
        addGestureRecognizer(gesture)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup -
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        font = AppConfiguration.DefaultFont
        textColor = AppConfiguration.DefaultColor
        
        setupSubviews()
        setupSelectionView()
        setupAutoLayout()
    }
    
    func setupSubviews() {
        
        addSubview(selectionView)
    }
    
    func setupSelectionView() {
        
        selectionView.backgroundColor = UIColor.init(red: 0.000, green: 0.478, blue: 1.000, alpha: 1.0)
        selectionView.isHidden = true
    }
    
    func setupAutoLayout() {
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        
        selectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
        selectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0).isActive = true
        selectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0).isActive = true
        selectionView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1).isActive = true
    }
    
    
    //  MARK: - Update -
    
    func updateForSelection() {
        
        if selected {
            textColor = UIColor.init(red: 0.000, green: 0.478, blue: 1.000, alpha: 1.0)
        } else {
            textColor = UIColor.darkGray
        }
        
        if !USE_NEW_UI {
            selectionView.isHidden = !selected
        }
    }
}
