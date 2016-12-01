//
//  MediaViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/11/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class MediaViewController: UIViewController {
    
    var media: Media!
    
    init(media: Media) {
        self.media = media
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func dismissViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
