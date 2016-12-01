//
//  DMDeleteButton.swift
//  Lancet
//
//  Created by Sharkey, Justin (ELS-CON) on 6/5/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let DMDeleteButtonHeight: CGFloat = 24 - (Config.Padding.Small * 2)

protocol DMDeleteButtonDelegate: class {
    func deleteButtonWasClicked()
}

class DMDeleteButton: UIView {
    
    let deleteImageView = UIImageView()
    weak var delegate: DMDeleteButtonDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        
        layer.cornerRadius = (DMDeleteButtonHeight + (Config.Padding.Small * 2)) / 2
        clipsToBounds = true
        backgroundColor = UIColor.veryLightGray()
        
        deleteImageView.image = UIImage(named: "Delete")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelButtonWasClicked))
        addGestureRecognizer(tapGesture)
    }
    
    func setupSubviews() {
        addSubview(deleteImageView)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            deleteImageView
        ]
        
        constrain(subviews) { (views) in
            
            let deleteIV = views[0]
            
            guard let superview = deleteIV.superview else {
                return
            }
            
            deleteIV.top == superview.top + Config.Padding.Small
            deleteIV.right == superview.right - Config.Padding.Small
            deleteIV.bottom == superview.bottom - Config.Padding.Small
            deleteIV.left == superview.left + Config.Padding.Small
            
            deleteIV.height == DMDeleteButtonHeight
            deleteIV.width == DMDeleteButtonHeight
        }
    }
    
    func cancelButtonWasClicked() {
        delegate?.deleteButtonWasClicked()
    }
}
