//
//  SLTableViewCell.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/1/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

protocol SLSearchTableViewCellDelegate: class {
    func userDidSearch(text: String)
}

class SLSearchTableViewCell: UITableViewCell, UISearchBarDelegate {
    static let Identifier = "SLSearchTableViewCell"
    
    weak var delegate: SLSearchTableViewCellDelegate?
    
    //let titleLabel = UILabel()
    let bottomSeparator = UIView()
    let searchTextField = UISearchBar()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        
        searchTextField.delegate = self
        
        bottomSeparator.backgroundColor = UIColor.gray
        
        searchTextField.placeholder = "Search"
        
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
    }
    
    func setupSubviews() {
        contentView.addSubview(searchTextField)
        contentView.addSubview(bottomSeparator)
    }
    
    func setupAutoLayout() {
        
        constrain(searchTextField, bottomSeparator) { (searchTF, bottomS) in
            
            guard let superview = searchTF.superview else {
                return
            }
            
            searchTF.top    == superview.top
            searchTF.right  == superview.right
            searchTF.bottom == superview.bottom
            searchTF.left   == superview.left
            
            bottomS.right == superview.right
            bottomS.bottom == superview.bottom
            bottomS.left == superview.left
            bottomS.height == 1
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            delegate?.userDidSearch(text: text)
        }
    }

}

class SLTableViewCell: UITableViewCell {
    
    static let Identifier = "SLTableViewCell"
    
    let countView = NumberOfDownloadsIcon()
    
    let titleLabel = UILabel()
    let bottomSeparator = UIView()
    
    let freeLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupFreeLabel()
        
        titleLabel.textColor = UIColor.white
        titleLabel.font = AppConfiguration.DefaultBoldFont
        
        bottomSeparator.backgroundColor = UIColor.gray
        
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        countView.isHidden = true
    }
    
    func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(bottomSeparator)
        contentView.addSubview(countView)
        contentView.addSubview(freeLabel)
    }
    
    func setupFreeLabel() {
        freeLabel.isHidden = true
        freeLabel.text = "FREE"
        freeLabel.backgroundColor = UIColor.red
        freeLabel.textColor = UIColor.white
        freeLabel.font = UIFont.systemFontOfSize(14, weight: .Semibold)
        freeLabel.textAlignment = .center
        freeLabel.isAccessibilityElement = false
    }
    
    func setupAutoLayout() {
        
        constrain(titleLabel, bottomSeparator, countView, freeLabel) { (titleL, bottomS, countV, freeL) in
            
            guard let superview = titleL.superview else {
                return
            }
            
            titleL.top    == superview.top    + Config.Padding.Default
            titleL.right  == superview.right  - Config.Padding.Default
            titleL.bottom == superview.bottom - Config.Padding.Default
            titleL.left   == superview.left   + Config.Padding.Default
            //titleL.height >= 28
            
            countV.centerY == superview.centerY
            countV.right == superview.right - Config.Padding.Default
            
            freeL.centerY == superview.centerY
            freeL.right == superview.right - Config.Padding.Default
            freeL.width == 44
            freeL.height == 18
            
            bottomS.right == superview.right
            bottomS.bottom == superview.bottom
            bottomS.left == superview.left
            bottomS.height == 1
        }
    }
    
}
