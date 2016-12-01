//
//  PushNotesTableCell.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 6/28/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class PushNotesTableCell: UITableViewCell {
    
    static let cellID = "PushCell"
    let statusLabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //  TODO: Increase (minimum?) cell height
        
        setup()
        setupSubviews()
        setupAutoLayout()
    }
    
    fileprivate func setupSubviews() {
        self.addSubview(statusLabel)
    }
    
    fileprivate func setupAutoLayout() {
        constrain(statusLabel) { (statusLabel)  -> () in
            guard let superview = statusLabel.superview else {
                return
            }
            
            statusLabel.centerY == superview.centerY
            statusLabel.width == 78
            statusLabel.height == 18
            statusLabel.right == superview.right - Config.Padding.Double
        }
    }
    
    fileprivate func setup() {
        textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        statusLabel.textAlignment = NSTextAlignment.left
        statusLabel.textColor = UIColor.darkGray
        statusLabel.font = UIFont.systemFont(ofSize: 15)
    }
}
