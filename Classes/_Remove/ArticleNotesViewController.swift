//
//  ArticleNotesViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/11/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class ArticleNotesViewController: UIViewController {
    
    let tableView = UITableView()
    let article: Article
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    func setup() {
        
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
    }
    
    func setupAutoLayout() {
        let subviews = [
            tableView
        ]
        constrain(subviews) { (views) in
            let tableV = views[0]
            guard let superview = tableV.superview else {
                return
            }
            tableV.top == superview.top
            tableV.right == superview.right
            tableV.bottom == superview.bottom
            tableV.left == superview.left
        }
    }
    
}
