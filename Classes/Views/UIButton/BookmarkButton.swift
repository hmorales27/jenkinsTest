//
//  BookmarkButton.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/13/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let StarredInactiveImage = "Starred-Inactive"
private let StarredActiveImage = "Starred-Active"

class BookmarkButton: JBSMButton {
    
    weak var article: Article?
    
    weak var cell: ArticleTableViewCell?
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func setup() {
        super.setup()
        
        setImage(UIImage(named: StarredInactiveImage), for: UIControlState())
        setImage(UIImage(named: StarredActiveImage), for: UIControlState.selected)
        backgroundColor = UIColor.veryLightGray()
        
        self.accessibilityLabel = "Add to Reading List"
        
        if USE_NEW_UI {
            constrain(self) { (view) -> () in
                view.height == 36
                view.width == 48
            }
            
        } else {
            layer.cornerRadius = 4.0
            
            constrain(self) { (view) -> () in
                view.height == 36
                view.width == 44
            }
        }

        
        addTarget(self, action: #selector(buttonWasClicked(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func update(_ article: Article) {
        self.article = article
        setActive(article.starred.boolValue)
    }
    
    func setActive(_ active: Bool) {
        if active {
            tintColor = UIColor.darkGoldColor()
            isSelected = true
            self.accessibilityLabel = "Article has been added to reading list. Double-tap to remove it."
        } else {
            tintColor = UIColor.gray
            isSelected = false
            self.accessibilityLabel = "Add to Reading List"
        }
    }
    
    func reset() {
        article = nil
    }
    
    override func buttonWasClicked(_ sender: UIButton) {
        guard let article = self.article else { return }
        
        DatabaseManager.SharedInstance.performChangesAndSave { () -> () in
            article.toggleStarred()
            performOnMainThread({ 
                self.cell?.issueVC?.updateHeaderView()
                if article.starred.boolValue == false {
                    self.cell?.issueVC?.collectionDataSourceNeedsTableViewRefresh()
                }
                self.setActive(article.starred.boolValue)
            })
        }

    }
}
