//
//  IssueNotesButton.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/21/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

protocol IssueNotesDelegate: class {
    
    func notesButtonWasClicked(_ button: IssueNotesButton)
}


class IssueNotesButton: JBSMView {
    
    let noteImageView = UIImageView(image: UIImage(named: "NoteIcon")!)
    let countLabel = UILabel()
    var tapView: UIView?
    
    var selected = false
    var isIphone = false
    
    weak var issueHeader: ArticlesHeaderView?
    weak var delegate: IssueNotesDelegate?
    
    override init() {
        super.init()
        setup()
    }
    
    func initForScreenType(_ screenType: ScreenType) {
    
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        setupView()
        setupSubviews()
        setupAutoLayout()
    }
    
    func setupView() {
        backgroundColor = UIColor.veryLightGray()
        layer.cornerRadius = 4.0
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1.0
        
        
        if let rootVC = UIApplication.shared.windows[0].rootViewController {
            isIphone = rootVC.view.frame.width < 768 ? true : false
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapView(_:)))
        
        if isIphone == true {
            
            tapView = UIView()
            //  tapView?.backgroundColor = UIColor.yellowColor()
            tapView?.addGestureRecognizer(tapGesture)
        }
        else if isIphone == false {
            addGestureRecognizer(tapGesture)
            
        }
        countLabel.font = UIFont.systemFontOfSize(16, weight: SystemFontWeight.Bold)
    }
    
    func setupSubviews() {
        addSubview(noteImageView)
        addSubview(countLabel)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            noteImageView,
            countLabel
        ]
        
        if isIphone == true {
            guard let _tapView = tapView else {
                
                return
            }
            addSubview(_tapView)
        }
        
        constrain(subviews) { (views) in
            
            let noteIV = views[0]
            let countL = views[1]
            
            guard let superview = noteIV.superview else {
                return
            }
            layoutConstraints.width = (superview.width == 60)
            
            noteIV.top    == superview.top    + Config.Padding.Small
            noteIV.bottom == superview.bottom - Config.Padding.Small
            noteIV.left   == superview.left   + Config.Padding.Default
            
            countL.top    == superview.top    + Config.Padding.Small
            countL.right  == superview.right  - Config.Padding.Default
            countL.bottom == superview.bottom - Config.Padding.Small
        }
        
        if isIphone == true {
            guard let _tapView = tapView else {
                
                return
            }
            constrain(_tapView) { (tapV) in

                guard let superview = tapV.superview else {
                    
                    return
                }
                tapV.left   == superview.left
                tapV.right  == superview.right + Config.Padding.Default
                tapV.top    == superview.top - Config.Padding.Double
                tapV.bottom == superview.bottom + Config.Padding.Default
            }
        }
    }
    
    func userDidTapView(_ recognizer: UITapGestureRecognizer) {
        
        delegate?.notesButtonWasClicked(self)
    }
}
