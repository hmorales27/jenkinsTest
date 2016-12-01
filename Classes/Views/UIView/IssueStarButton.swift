//
//  IssueStarButton.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/21/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography


protocol IssueStarDelegate: class {
    
    func starButtonWasClicked(_ button: IssueStarredButton)
}


class IssueStarredButton: JBSMView {
    
    let starImageView = UIImageView()
    let countLabel = UILabel()
    var tapView: UIView?
    
    var selected = false
    var isIphone = false
    
    weak var issueHeader: ArticlesHeaderView?
    weak var viewController: IssuesViewController?
    weak var delegate: IssueStarDelegate?
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        setupView()
        setupSubviews()
        setupAutoLayout()
        
        starImageView.tintColor = UIColor.darkGoldColor()
        
        countLabel.font = UIFont.systemFontOfSize(16, weight: SystemFontWeight.Bold)
    }
    
    func setupView() {
        backgroundColor = UIColor.veryLightGray()
        layer.cornerRadius = 4.0
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1.0
        
        // Default - Inactive
        if let image = UIImage(named: "Starred-Active") {
            starImageView.image = image
        }
        
        //  This is kinda convoluted, might replace by just seeing if I can run something off of keyWindow.view's width
        //  or something along those lines.
        if let rootVC = UIApplication.shared.windows[0].rootViewController {
            isIphone = rootVC.view.frame.width < 768 ? true : false
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapView(_:)))

        if isIphone == true {
            
            tapView = UIView()
//            tapView?.backgroundColor = UIColor.yellowColor()
            tapView?.addGestureRecognizer(tapGesture)
        }
        else if isIphone == false {
            addGestureRecognizer(tapGesture)

        }
        countLabel.font = UIFont.systemFontOfSize(16, weight: SystemFontWeight.Bold)
    }
    
    func setupSubviews() {
        addSubview(starImageView)
        addSubview(countLabel)
        
        if isIphone == true {
            guard let _tapView = tapView else {
                
                return
            }
            addSubview(_tapView)
        }
    }
    
    func setupAutoLayout() {
        
        var subviews = [
            starImageView,
            countLabel
        ]
        
        if isIphone == true {
            
            guard let _tapView = tapView else {
                
                return
            }
            subviews.append(_tapView)
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
            noteIV.width  == 22
            noteIV.height == 22
            
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
                tapV.left   == superview.left - Config.Padding.Small
                tapV.right  == superview.right
                tapV.top    == superview.top - Config.Padding.Double
                tapV.bottom == superview.bottom + Config.Padding.Default
            }
        }
    }
    
    func userDidTapView(_ recognizer: UITapGestureRecognizer) {

        delegate?.starButtonWasClicked(self)
    }
    
    func setActive(_ active: Bool) {
        if active == false {
            backgroundColor = UIColor.veryLightGray()
            countLabel.textColor = UIColor.darkGray
            selected = false
        } else {
            backgroundColor = UIColor.blue
            countLabel.textColor = UIColor.white
            selected = true
        }
        issueHeader?.issueVC?.dataSource.showOnlyStarredArticles = selected
    }
}
