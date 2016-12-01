//
//  SocialView.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 9/26/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

protocol SocialDelegate: class {
    func socialViewWasClicked(_ sender: SocialView)
}

class SocialView: JBSMView {
    
    var linkURL: String?
    var delegate: SocialDelegate?
    
    override init() {

        super.init()
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(socialViewWasClicked(_:)))
        
        
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func socialViewWasClicked(_ recognizer: UITapGestureRecognizer) {
        
        delegate?.socialViewWasClicked(self)
    }
}
