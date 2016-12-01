//
//  UserConfig.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 4/27/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

class UserConfig {
    
    fileprivate struct Strings {
        static let ShowHowToUseTheApp = "ShowHowToUseTheApp"
        static let ShowGoToBookmarks = "ShowGoToBookmarks"
    }
    
    static let MainInstance = UserConfig()
    
    fileprivate let plistPath = DocumentDirectoryPath + "UserConfig.json"
    fileprivate var plist: [String: AnyObject] = [:]
    
    init() {
        if FileSystemManager.sharedInstance.pathExists(plistPath) == false {
            create()
        } else {
            plist = NSDictionary(contentsOfFile: plistPath) as! [String: AnyObject]
        }
    }
    
    var ShowHowToUseTheApp: Bool {
        get {
            return plist[Strings.ShowHowToUseTheApp] as! Bool
        }
        set(_bool) {
            plist[Strings.ShowHowToUseTheApp] = _bool as AnyObject?
            save()
        }
    }
    
    var ShowGoToBookmarks: Bool {
        get {
            return plist[Strings.ShowGoToBookmarks] as! Bool
        }
        set(_bool) {
            plist[Strings.ShowGoToBookmarks] = _bool as AnyObject?
            save()
        }
    }
    
    fileprivate func save() {
        NSDictionary(dictionary: plist).write(toFile: plistPath, atomically: true)
    }
    
    func create() {
        plist[Strings.ShowHowToUseTheApp] = true as AnyObject?
        plist[Strings.ShowGoToBookmarks] = true as AnyObject?
        save()
    }
    
}
