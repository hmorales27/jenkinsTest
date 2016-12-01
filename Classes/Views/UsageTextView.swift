//
//  UsageTextView.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/10/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class UsageTextView: UITextView {

    /*  Could be useful to make this a class method returning CGRect (or CGSize) object
        so that the returned object could be used for determining footer height for the
        assoc. tableView
    */
    
    //  Wasn't sure how/where to put this in Strings, so it's here for now.
    let usageViewText = "* Multimedia includes Videos, Audio and Other Files.<p><p><b>Deleting articles from previous app versions</b><p>Usage sizes shown and the “Delete” function do not include articles saved to your Reading List, articles with notes, or content downloaded in previous app versions (v1-3). You must remove articles from your Reading List before they can be deleted. You must remove notes from articles before these articles can be deleted.<p><p><b>Viewing storage for articles from previous app versions</b><p>To see full storage space used by the app including content downloaded before version 4 see your device Settings > General > Usage > App Name. You can delete previous issues downloaded before version 4 from the “All Issues” screen.<p><p><b>Removing articles in your Reading List</b><p>Please remove articles from your Reading List using the edit function.<p><p><b>Removing articles containing notes</b><p>Please remove notes using the Notes List edit function."
    
    
    func frameInContainingView(_ view: UIView) {
        
        let fixedWidth = view.bounds.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        frame = newFrame;
    }
    
    class func formattedStringForString(_ string: String) -> NSAttributedString? {
        
        let fontName = "Helvetica"
        let fontSize = 16
        let formattedString = string + "<style>body{font-family: '\(fontName)'; font-size:\(fontSize)px;}</style>"
        
        let encodedData = formattedString.data(using: String.Encoding.utf8)
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject,
        ]
        
        guard let data = encodedData else {
            
            return nil
        }
        
        do {
            let attributedString = try NSAttributedString.init(data: data, options: attributedOptions, documentAttributes: nil)
            return attributedString
        } catch {
            log.warning("could not format attributed string for string '\(string)'")
        }
        return nil
    }
}
