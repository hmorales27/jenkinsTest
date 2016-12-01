//
//  JSONHelper.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 11/7/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class JSONHelper {
    static let bundle = Bundle(identifier: "com.elsevier.jbsm.swift.JBSM-UnitTests")
    static var app: [String: AnyObject]? {
        guard let path = bundle?.path(forResource: "App", ofType: ".json") else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
            return json
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static var journal: [String: AnyObject]? {
        guard let path = bundle?.path(forResource: "Journal", ofType: ".json") else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
            return json
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static var topArticles:[String:AnyObject]?{
        guard let path = bundle?.path(forResource: "TopArticles", ofType: ".json") else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
            return json
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
