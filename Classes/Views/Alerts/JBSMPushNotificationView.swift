//
//  JBSMPushNotification.swift
//  AlertView
//
//  Created by Morales Hernandez, Humberto (ELS-PHI) on 11/8/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

typealias voidBlock = (() -> ())

public enum JBSMPushNotificationViewType {
    case light, dark
}

class JBSMPushNotificationView: UIView {
    
    open var image:UIImage?
    open var onTapBlock:voidBlock?
    open var onDismissBlock:voidBlock?
    open var animationDuration = 0.3
    open var hasShadow = true {
        didSet {
            setShadows()
        }
    }
    open var dismissOnTap = true
    open var type = JBSMPushNotificationViewType.dark {
        didSet {
            refreshUI()
        }
    }
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let statusBarSize = UIApplication.shared.statusBarFrame.size
    private let kNotificationHeight:CGFloat = 80.0
    
    open let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppConfiguration.DefaultBoldFont
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    open let detailLabel: UILabel = {
        let label = UILabel()
        label.font = AppConfiguration.DefaultSmallFont
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    open let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    //MARK: - Initializers
    
    public init(title:String? = nil, subTitle:String? = nil, onTapBlock:voidBlock? = nil, onDismissBlock:voidBlock? = nil, backgroundColor:UIColor? = nil, image: UIImage? = nil) {
        super.init(frame: CGRect(x: 0, y: -kNotificationHeight, width: statusBarSize.width, height: kNotificationHeight))
        self.titleLabel.text = title
        self.detailLabel.text = subTitle
        self.onTapBlock = onTapBlock
        self.onDismissBlock = onDismissBlock
        self.backgroundColor = backgroundColor
        self.image = image
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(_ view:UIView? = UIView.getMainWindow()) {
        guard let view = view else {
            print("Error: could not retrieve main window")
            return
        }
        view.addSubview(self)
        UIView.animate(withDuration: animationDuration, delay: 0, options: .allowUserInteraction, animations: {[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.frame = CGRect(x: 0, y: 0, width: strongSelf.statusBarSize.width, height: strongSelf.kNotificationHeight)
        }) { [weak self] finished in
            guard let strongSelf = self else {
                return
            }
            let deadLine =  DispatchTime.now() + DispatchTimeInterval.milliseconds(1000 * 3)
            performOnMainThread(deadLine: deadLine, tasks: { 
                strongSelf.dismiss()
            })
        }
    }
    
    internal func dismiss(){
        UIView.animate(withDuration: animationDuration, delay: 0, options: .allowUserInteraction, animations: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.frame = CGRect(x: 0, y: -(strongSelf.kNotificationHeight), width: strongSelf.statusBarSize.width, height: strongSelf.kNotificationHeight)
            }, completion: { [weak self] finished in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.removeFromSuperview()
                strongSelf.onDismissBlock?()
            })
    }
    
    //MARK: - UI Setup
    
    private func setupUI(){
        addSubviews()
        setupAutoLayout()
        addGestureRecognizer()
        setShadows()
        addImage()
    }
    
    private func addGestureRecognizer() {
        if let _ = onTapBlock {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
            addGestureRecognizer(tapGesture)
        }
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe))
        swipeGesture.direction = .up
        addGestureRecognizer(swipeGesture)
    }
    
    private func setShadows() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = hasShadow ? 0.5 : 0.0
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 4
    }
    
    private func addSubviews(){
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(imageView)
    }
    
    private func addImage(){
        if let image = image {
            imageView.image = image
            imageView.layer.cornerRadius = 5
            imageView.clipsToBounds = true
        }
    }
    
    private func setupAutoLayout(){
        constrain(self, titleLabel, detailLabel, imageView) { (view, titleLabel, detailLabel, imageView) in
            imageView.height == view.height / 2
            imageView.width == imageView.height
            imageView.left == view.left + 8
            imageView.centerY == view.centerY
            
            titleLabel.top == imageView.top
            titleLabel.width == view.width
            titleLabel.height == imageView.height / 2
            titleLabel.left == imageView.right + 8
            
            detailLabel.top == titleLabel.bottom
            detailLabel.width == view.width
            detailLabel.height == imageView.height / 2
            detailLabel.left == imageView.right + 8
        }
    }
    
    internal func refreshUI(){
        var color:UIColor?
        switch type {
        case .dark:
            color = UIColor.white
        case .light:
            color = UIColor.black
        }
        titleLabel.textColor = color
        detailLabel.textColor = color
    }
    
    // MARK: - Gestures
    
    internal func onTap() {
        onTapBlock?()
        if dismissOnTap {
            dismiss()
        }
    }
    
    internal func onSwipe() {
        dismiss()
    }
}
