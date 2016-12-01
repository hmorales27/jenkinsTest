//
//  ImageCollectionViewCell.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/5/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

import Cartography




class ImageCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let kFigureRegex = "(?:figcaption)(?:[^>]+>)(?:<[^<>]*>)*([^<>]+)"
    // MARK: Initializers
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup() {
        setupView()
        setupSubviews()
        setupAutoLayout()
        titleLabel.textColor = UIColor.white
    }
    
    func setupSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }
    
    func setupAutoLayout() {
        constrain(imageView, titleLabel) { (imageView, titleLabel) -> () in
            guard let superview = imageView.superview else {
                return
            }
            imageView.left == superview.left
            imageView.top == superview.top
            imageView.right == superview.right
            
            titleLabel.top == imageView.bottom + 4
            titleLabel.right == superview.right
            titleLabel.bottom == superview.bottom - 4
            titleLabel.left == superview.left
            titleLabel.height == 22
        }
    }
    
    func setupView() {
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1.0
        
        titleLabel.textAlignment = NSTextAlignment.center
    }
    func getFigureText(html: String) -> String? {
        //return html.capturedGroups(withRegex: kFigureRegex)[0]
        return nil
    }
    func configure(_ figure: Media) {
        imageView.image = UIImage(contentsOfFile: figure.pathString)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.clipsToBounds = true
        titleLabel.text = getFigureText(html: figure.caption) ?? ""
    }
    
    // MARK: Reset
    
    override func prepareForReuse() {
        reset()
    }
    
    fileprivate func reset() {
        imageView.image = nil
    }
}
