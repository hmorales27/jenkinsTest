//
//  StoryboardHelper.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/16/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

class StoryboardHelper {
    
    class func Articles() -> ArticlesViewController {
        let storyboard = UIStoryboard(name: "Articles", bundle: nil)
        let articlesVC = storyboard.instantiateInitialViewController() as! ArticlesViewController
        return articlesVC
    }
}
