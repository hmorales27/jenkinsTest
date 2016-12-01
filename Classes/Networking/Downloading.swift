//
//  Downloading.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/3/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation
import Alamofire

class Downloading: SessionDelegate {
    
    static let shared = Downloading()
    
    var backgroundManager: Alamofire.SessionManager!

    
    override init() {
        super.init()
        let session = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: "something"))
        self.backgroundManager = Alamofire.SessionManager(session: session, delegate: self)
        
    }
    
    func something() {

    }
    
    
}
