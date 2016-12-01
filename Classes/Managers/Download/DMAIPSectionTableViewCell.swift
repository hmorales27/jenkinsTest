//
//  DMAIPSectionTableViewCell.swift
//  Lancet
//
//  Created by Sharkey, Justin (ELS-CON) on 6/5/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class DMAIPSectionTableViewCell: UITableViewCell, DMDeleteButtonDelegate {
    
    static let Identifier = "DMAIPSectionTableViewCell"
    
    let articleTitleLabel : UILabel = UILabel()
    let progressView      : UIProgressView = UIProgressView(progressViewStyle: UIProgressViewStyle.bar)
    let cancelButton      : DMDeleteButton = DMDeleteButton()
    
    weak var article      : Article?
    var supplement        : Bool = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupSubviews()
    }
    
    func setupSubviews() {
        contentView.addSubview(articleTitleLabel)
        contentView.addSubview(progressView)
    }
    
    func setupAutoLayout() {
        let subviews = [
            articleTitleLabel,
            progressView,
            cancelButton
        ]
        constrain(subviews) { (views) in
            let articleTitleL = views[0]
            let progressV = views[1]
            let cancelB = views[2]
            
            guard let superview = articleTitleL.superview else {
                return
            }
            
            articleTitleL.top == superview.top + Config.Padding.Default
            articleTitleL.right == superview.right - Config.Padding.Default
            articleTitleL.left == superview.left + Config.Padding.Default
            
            cancelB.top == articleTitleL.bottom + Config.Padding.Default
            cancelB.right == superview.right - Config.Padding.Default
            cancelB.bottom == superview.bottom - Config.Padding.Default
            
            progressV.right == cancelB.left - Config.Padding.Default
            progressV.left == superview.left + Config.Padding.Default
            progressV.centerY == cancelB.centerY
        }
    }
    
    func update() {
        
    }
    
    func reset() {
        
    }
    
    func deleteButtonWasClicked() {
        
    }
    
}
