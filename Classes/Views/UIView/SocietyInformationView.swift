//
//  SocietyInformationView.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 4/21/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

protocol SocietyInformationViewDelegate: class {
    func societyInformationLinkClicked(url: URL)
}

class SocietyInformationView: JBSMView, SocialDelegate {
    
    let titleLabel = UILabel()
    let facebookButton = FacebookButton()
    let twitterButton = TwitterButton()
    let aboutTitleLabel = UILabel()
    let aboutLabel = UILabel()
    
    weak var bottomConstraint: NSLayoutConstraint?
    
    weak var delegate: SocietyInformationViewDelegate?
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        setupView()
        setupSubviews()
        setupAutolayout()
    }
    
    func setupView() {
        titleLabel.text = "Connect with Us"
        titleLabel.font = AppConfiguration.DefaultBoldTitleFont
        
        aboutTitleLabel.text = "About"
        aboutTitleLabel.font = AppConfiguration.DefaultBoldTitleFont
        
        facebookButton.isHidden = true
        twitterButton.isHidden = true
        
        let publisher = DatabaseManager.SharedInstance.getAppPublisher()
        if let facebookLink = publisher?.societyFacebookURL {
            facebookButton.linkURL = facebookLink
            facebookButton.isHidden = false
            facebookButton.delegate = self
        }
        if let twitterLink = publisher?.societyTwitterURL {
            twitterButton.linkURL = twitterLink
            twitterButton.isHidden = false
            twitterButton.delegate = self
        }
        
        aboutLabel.numberOfLines = 0
    }
    
    @objc fileprivate func linkClicked(_ sender: JBSMButton) {
        guard let link = sender.linkURL, let url = URL(string: link) else {
            return
        }
        delegate?.societyInformationLinkClicked(url: url)
    }
    
    func socialViewWasClicked(_ sender: SocialView) {
        guard let linkURL = sender.linkURL else {
            return
        }
        guard let url = NSURL(string: linkURL) else {
            return
        }
        delegate?.societyInformationLinkClicked(url: url as URL)
    }
    
    func setupSubviews() {
        addSubview(titleLabel)
        addSubview(facebookButton)
        addSubview(twitterButton)
        addSubview(aboutTitleLabel)
        addSubview(aboutLabel)
    }
    
    func setupAutolayout() {
        let subviews = [
            titleLabel,
            facebookButton,
            twitterButton,
            aboutTitleLabel,
            aboutLabel
        ]
        constrain(subviews) { (views) in
            let titleL = views[0]
            let facebookB = views[1]
            let twitterB = views[2]
            let aboutTitleL = views[3]
            let aboutLabel = views[4]
            
            guard let superview = titleL.superview else { return }
            
            titleL.top == superview.top + Config.Padding.Default
            titleL.right == superview.right - Config.Padding.Default
            titleL.left == superview.left + Config.Padding.Default
            
            facebookB.top == titleL.bottom + Config.Padding.Default
            facebookB.left == superview.left + Config.Padding.Default
            
            twitterB.left == facebookB.right + Config.Padding.Default
            twitterB.centerY == facebookB.centerY
            
            aboutTitleL.top == facebookB.bottom + Config.Padding.Default
            aboutTitleL.right == superview.right - Config.Padding.Default
            aboutTitleL.left == superview.left + Config.Padding.Default
            
            aboutLabel.top == aboutTitleL.bottom + Config.Padding.Default
            aboutLabel.right == superview.right - Config.Padding.Default
            aboutLabel.left == superview.left + Config.Padding.Default
            
        }
    }
    
    func setup(_ publisher: Publisher, delegate: SocietyInformationViewDelegate) {
        guard publisher.isSocietyInfoAvailable == true else { return }
        
        self.delegate = delegate
        
        aboutLabel.text = publisher.desc
        
        if let facebook = publisher.societyFacebookURL {
            if facebook != "" {
                facebookButton.isHidden = false
                facebookButton.setLink(link: facebook)
            } else {
                facebookButton.isHidden = true
            }
        } else {
            facebookButton.isHidden = true
        }
        
        if let twitter = publisher.societyTwitterURL {
            if twitter != "" {
                twitterButton.isHidden = false
                twitterButton.setLink(link: twitter)
            } else {
                twitterButton.isHidden = true
            }
        } else {
            twitterButton.isHidden = true
        }
        
        if let links = publisher.links?.allObjects as? [Link] {
            if let _delegate = delegate as? JBSMButtonDelegate {
                addLinks(links, delegate: _delegate)
            }
        }
    }
    
    func addLinks(_ links: [Link], delegate: JBSMButtonDelegate) {
        
        var lastView: UIView = aboutLabel
        
        for link in links {
            
            let label = JBSMButton()
            label.setTitle(link.title, for: UIControlState())
            label.linkURL = link.url
            label.delegate = delegate
            
            label.setTitleColor(AppConfiguration.PrimaryColor, for: UIControlState())
            label.titleLabel?.font = AppConfiguration.DefaultBoldFont
            label.titleLabel?.numberOfLines = 0
            label.titleLabel?.textAlignment = NSTextAlignment.left
            label.contentHorizontalAlignment = .left
            
            addSubview(label)
            
            constrain(lastView, label, block: { (lastView, label) in
                
                guard let superview = label.superview else { return }
                
                label.top == lastView.bottom + Config.Padding.Default
                label.right == superview.right - Config.Padding.Default
                label.left == superview.left + Config.Padding.Default
                
            })
            
            lastView = label
        }
        
    }
    
}
