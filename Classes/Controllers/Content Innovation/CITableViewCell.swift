//
//  CITableViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/10/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class CITableViewCell: UITableViewCell {
    
    let ciTitleLabel = UILabel()
    
    let ciImageView = UIImageView()
    let ciImageBackground = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupTitleLabel()
        setupImageView()
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
    }
    
    func setupSubviews() {
        contentView.addSubview(ciTitleLabel)
        contentView.addSubview(ciImageBackground)
        ciImageBackground.addSubview(ciImageView)
    }
    
    func setupAutoLayout() {
        constrain(ciTitleLabel, ciImageView, ciImageBackground) { (ciTitleLabel, ciImageView, ciImageBackground) -> () in
            guard let superview = ciTitleLabel.superview else {
                return
            }
            
            ciTitleLabel.top == superview.top
            ciTitleLabel.bottom == superview.bottom
            ciTitleLabel.left == superview.left + 8
            
            ciImageBackground.left == ciTitleLabel.right + 8
            ciImageBackground.top == superview.top + 8
            ciImageBackground.right == superview.right - 8
            ciImageBackground.bottom == superview.bottom - 8
            ciImageBackground.width == 40
            ciImageBackground.height == 40
            
            ciImageView.width == 32
            ciImageView.height == 32
            ciImageView.centerX == ciImageBackground.centerX
            ciImageView.centerY == ciImageBackground.centerY
        }
    }
    
    func setupTitleLabel() {
        ciTitleLabel.textAlignment = .right
        ciTitleLabel.textColor = UIColor.white
    }
    
    func setupImageView() {
        ciImageBackground.backgroundColor = UIColor.white
    }
    
    // MARK: - Update -
    
    func update(_ widget: CIWidget) {
        updateTitleLabel(widget.widgetName)
        updateImageView(widget.widgetIconName)
    }
    
    func updateImageView(_ imageName: String) {
        let path = CachesDirectoryPath + "appimages/" + imageName
        if let image = UIImage(contentsOfFile: path) {
            ciImageView.image = image
        } else {
            ciImageView.image = UIImage(named: "DefaultCI")
        }
    }
    
    func updateTitleLabel(_ title: String) {
        ciTitleLabel.text = title
    }
    
    // MARK: - Reset -
    
    override func prepareForReuse() {
        reset()
    }
    
    func reset() {
        ciImageView.image = nil
        ciTitleLabel.text = nil
    }
    
}
