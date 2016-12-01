//
//  SupplementMediaController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/13/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let IconSize: CGFloat = 52

protocol SupplementMediaControllerDelegate: class {
    func supplementMediaControllerActive(_ active: Bool)
    func supplementMediaControllerDidSelectType(_ type: DisplayFileType, withMedia media: [Media])
}

class SupplementMediaController: NSObject {
    
    // Settings
    
    let backgroundEnabled = false
    
    // Views
    
    weak var parentView: UIView?
    
    let actionButton = SupplementMediaActionButton()
    let backgroundView = UIView()
    
    let figureButton = SMFigureButton()
    let tableButton = SMTableButton()
    let audioButton = SMAudioButton()
    let videoButton = SMVideoButton()
    let otherButton = SMOtherButton()
    
    let openMultiAccess = "Open article multimedia"
    let closeMultiAccess = "Close article multimedia"
    
    // Data
    
    weak var article: Article?
    
    // Delegate
    
    weak var delegate: SupplementMediaControllerDelegate?
    
    // Other
    
    var figures: [Media] = []
    var hasFigures: Bool {
        return figures.count > 0 ? true : false
    }
    
    var tables: [Media] = []
    var hasTables: Bool {
        return tables.count > 0 ? true : false
    }
    
    var audios: [Media] = []
    var hasAudios: Bool {
        return audios.count > 0 ? true : false
    }
    
    var videos: [Media] = []
    var hasVideos: Bool {
        return videos.count > 0 ? true : false
    }
    
    var others: [Media] = []
    var hasOthers: Bool {
        return others.count > 0 ? true : false
    }
    
    var shouldShowActionButton: Bool {
        if hasFigures || hasTables || hasAudios || hasVideos || hasOthers {
            return true
        }
        return false
    }
    
    var active = false
    
    // MARK: - Initializers -
    
    override init() {
        super.init()
        figureButton.button.addTarget(self, action: #selector(didClickMediaButton(_:)), for: .touchUpInside)
        tableButton.button.addTarget(self, action: #selector(didClickMediaButton(_:)), for: .touchUpInside)
        audioButton.button.addTarget(self, action: #selector(didClickMediaButton(_:)), for: .touchUpInside)
        videoButton.button.addTarget(self, action: #selector(didClickMediaButton(_:)), for: .touchUpInside)
        otherButton.button.addTarget(self, action: #selector(didClickMediaButton(_:)), for: .touchUpInside)
        
        let labels = [figureButton.label, tableButton.label, audioButton.label, videoButton.label, otherButton.label]
        
        for label in labels {
            
            label.addTarget(self, action: #selector(didClickMediaLabel(_:)), for: .touchUpInside)

        }
    }

    // MARK: - Setup -

    func setup(_ parentView: UIView) {
        self.parentView = parentView
        
        setupSubviews()
        setupAutoLayout()
        setupActionButton()
        setupBackgroundView()
        
        setupFigureButton()
        setupTableButton()
        setupAudioButton()
        setupVideoButton()
        setupOtherButton()
        
        actionButton.accessibilityLabel = openMultiAccess
    }
    
    func setupSubviews() {
        parentView?.addSubview(backgroundView)
        
        parentView?.addSubview(figureButton)
        parentView?.addSubview(tableButton)
        parentView?.addSubview(audioButton)
        parentView?.addSubview(videoButton)
        parentView?.addSubview(otherButton)
        
        parentView?.addSubview(actionButton)
    }
    
    func setupActionButton() {
        actionButton.delegate = self
        actionButton.accessibilityLabel = "Article Media"
    }
    
    func setupFigureButton() {
        figureButton.accessibilityLabel = "Figures"
        figureButton.isAccessibilityElement = false
    }
    
    func setupTableButton() {
        tableButton.accessibilityLabel = "Tables"
        tableButton.isAccessibilityElement = false
    }
    
    func setupAudioButton() {
        audioButton.accessibilityLabel = "Audio"
        audioButton.isAccessibilityElement = false
    }
    
    func setupVideoButton() {
        videoButton.accessibilityLabel = "Videos"
        videoButton.isAccessibilityElement = false
    }
    
    func setupOtherButton() {
        otherButton.accessibilityLabel = "Other Files"
        otherButton.isAccessibilityElement = false
    }
    
    func setupAutoLayout() {
        constrain(actionButton, backgroundView) { (actionButton, backgroundView) -> () in
            guard let superview = actionButton.superview else {
                return
            }
            
            backgroundView.top == superview.top
            backgroundView.right == superview.right
            backgroundView.bottom == superview.bottom + 88
            backgroundView.left == superview.left
            
            actionButton.width == IconSize
            actionButton.height == IconSize
            actionButton.right == superview.right - 16
            actionButton.bottom == superview.bottom - 16
        }
        
        constrain(actionButton, figureButton) { (action, figure) -> () in
            figureButton.bottomConstraint = (figure.bottom == action.bottom)
            figureButton.centerXConstraint = (figure.centerX == action.centerX)
        }
        constrain(actionButton, tableButton) { (action, table) -> () in
            tableButton.bottomConstraint = (table.bottom == action.bottom)
            tableButton.centerXConstraint = (table.centerX == action.centerX)
        }
        constrain(actionButton, audioButton) { (action, audio) -> () in
            audioButton.bottomConstraint = (audio.bottom == action.bottom)
            audioButton.centerXConstraint = (audio.centerX == action.centerX)
        }
        constrain(actionButton, videoButton) { (action, video) -> () in
            videoButton.bottomConstraint = (video.bottom == action.bottom)
            videoButton.centerXConstraint = (video.centerX == action.centerX)
        }
        constrain(actionButton, otherButton) { (action, other) -> () in
            otherButton.bottomConstraint = (other.bottom == action.bottom)
            otherButton.centerXConstraint = (other.centerX == action.centerX)
        }
    }
    
    func setupBackgroundView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        backgroundView.isHidden = true
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectActionButton(_:)))
        //backgroundView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Update -
    
    func update(_ article: Article) {
        reset()
        if article.downloadInfo.fullTextDownloadStatus == .downloaded {
            updateLists(article.allMedia)
            updateActionButton()
        }
    }

    func updateLists(_ medias: [Media]) {
        for media in medias {
            if let type = media.type {
                if let type = MediaFileType.TypeFromString(type) {
                    switch type {
                    case .Image:
                        figures.append(media)
                    case .Table:
                        tables.append(media)
                    case .Audio:
                        audios.append(media)
                    case .Video:
                        videos.append(media)
                    case .Document, .Spreadsheet, .Presentation, .PDF, .Other:
                        others.append(media)
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func updateActionButton() {
        if shouldShowActionButton {
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }
    
    func showBackgroundView(_ show: Bool) {
        if backgroundEnabled {
            if show {
                backgroundView.isHidden = false
            } else {
                backgroundView.isHidden = true
            }
        }
    }
    
    func showMediaButtons() {
        
        actionButton.setImage(UIImage(named: "Close"), for: UIControlState())
        actionButton.accessibilityLabel = closeMultiAccess
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            var padding: CGFloat = 4
            let additional: CGFloat = 52
            padding += additional
            if self.hasFigures {
                self.figureButton.bottomConstraint?.constant = -padding
                self.figureButton.isHidden = false
                self.figureButton.isAccessibilityElement = true
                padding += additional
            }
            if self.hasTables {
                self.tableButton.bottomConstraint?.constant = -padding
                self.tableButton.isHidden = false
                self.tableButton.isAccessibilityElement = true
                padding += additional
            }
            if self.hasAudios {
                self.audioButton.bottomConstraint?.constant = -padding
                self.audioButton.isHidden = false
                self.audioButton.isAccessibilityElement = true
                padding += additional
            }
            if self.hasVideos {
                self.videoButton.bottomConstraint?.constant = -padding
                self.videoButton.isHidden = false
                self.videoButton.isAccessibilityElement = true
                padding += additional
            }
            if self.hasOthers {
                self.otherButton.bottomConstraint?.constant = -padding
                self.otherButton.isHidden = false
                self.otherButton.isAccessibilityElement = true
                padding += additional
            }
            self.parentView?.layoutIfNeeded()
            self.parentView?.updateConstraintsIfNeeded()
        }) 
    }
    
    func hideMediaButtons() {
        
        actionButton.setImage(UIImage(named: "Paperclip"), for: UIControlState())
        actionButton.accessibilityLabel = openMultiAccess
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            
            self.figureButton.bottomConstraint?.constant = 0
            self.tableButton.bottomConstraint?.constant = 0
            self.audioButton.bottomConstraint?.constant = 0
            self.videoButton.bottomConstraint?.constant = 0
            self.otherButton.bottomConstraint?.constant = 0
            
            self.parentView?.layoutIfNeeded()
            self.parentView?.updateConstraintsIfNeeded()
        }) 
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            
            
            }, completion: { (success) -> Void in
                self.figureButton.isHidden = true
                self.figureButton.isAccessibilityElement = false
                self.tableButton.isHidden = true
                self.tableButton.isAccessibilityElement = false
                self.audioButton.isHidden = true
                self.audioButton.isAccessibilityElement = false
                self.videoButton.isHidden = true
                self.videoButton.isAccessibilityElement = false
                self.otherButton.isHidden = true
                self.otherButton.isAccessibilityElement = false
        }) 
    }
    
    func didClickMediaButton(_ button: UIButton) {
        let superView = button.superview as! SMButton

        guard let type = superView._type else {
            return
        }
        switch type {
        case .Figure:
            delegate?.supplementMediaControllerDidSelectType(.Figure, withMedia: figures)
        case .Table:
            delegate?.supplementMediaControllerDidSelectType(.Table, withMedia: tables)
        case .Audio:
            delegate?.supplementMediaControllerDidSelectType(.Audio, withMedia: audios)
        case .Video:
            delegate?.supplementMediaControllerDidSelectType(.Video, withMedia: videos)
        case .Other:
            delegate?.supplementMediaControllerDidSelectType(.Other, withMedia: others)
        }
    }
    
    func didClickMediaLabel(_ button: UIButton) {
        
        didClickMediaButton(button)
    }
    
    
    // MARK: - Reset -
    
    func reset() {
        active = false
        actionButton.isHidden = true
        showBackgroundView(false)
        article = nil
        hideMediaButtons()
        
        figures = []
        tables = []
        audios = []
        videos = []
        others = []
    }
    
}

extension SupplementMediaController: SupplementMediaActionButtonDelegate {
    
    func supplementMediaActionButtonWasClicked() {
        if active {
            active = false
            delegate?.supplementMediaControllerActive(false)
            showBackgroundView(false)
            hideMediaButtons()
            
        } else {
            active = true
            delegate?.supplementMediaControllerActive(true)
            showBackgroundView(true)
            showMediaButtons()
        }
    }
}

// MARK: - Supplement Media Action Button -

protocol SupplementMediaActionButtonDelegate: class {
    func supplementMediaActionButtonWasClicked()
}

class SupplementMediaActionButton: UIButton {
    
    var delegate: SupplementMediaActionButtonDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(UIImage(named: "Paperclip"), for: UIControlState())
        tintColor = UIColor.white
        layer.cornerRadius = IconSize / 2
        backgroundColor = UIColor(red: 0.20, green: 0.28, blue: 0.56, alpha: 1.0)
        isHidden = true
        addTarget(self, action: #selector(buttonWasSelected), for: .touchUpInside)
    }
    
    func buttonWasSelected() {
        delegate?.supplementMediaActionButtonWasClicked()
    }
    
}

// MARK: - SMButton -

class SMButton: UIView {
    
    var topConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    var leftConstraint: NSLayoutConstraint?
    
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    var centerXConstraint: NSLayoutConstraint?
    var centerYConstraint: NSLayoutConstraint?
    
    let button = UIButton(type: .custom)
    
    //  nameButton
    let label = UIButton(type: .custom)
    
    var _type: DisplayFileType?
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupView()
        setupLabel()
    }
    
    func setupSubviews() {
        addSubview(button)
        addSubview(label)
    }
    
    func setupAutoLayout() {
        constrain(self, button, label) { (view, button, label) -> () in
            widthConstraint = (view.width == 44)
            heightConstraint = (view.height == 44)
            
            button.top    == view.top
            button.right  == view.right
            button.bottom == view.bottom
            button.left   == view.left
            
            label.width == widthForLabel()
            label.left == view.left - (widthForLabel() + 8)
            label.height == 34
            label.centerY == view.centerY
        }
    }
    
    func setupView() {
        button.backgroundColor = UIColor(red: 0.20, green: 0.28, blue: 0.56, alpha: 1.0)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 22
    }
    
    func setImage(_ image: UIImage?, forState state: UIControlState) {
        button.setImage(image, for: state)
    }
    
    func setupLabel() {
        
        label.setTitle(titleForLabel(), for: UIControlState())
        label.backgroundColor = UIColor.black
        label.setTitleColor(UIColor.white, for: UIControlState())
        label.titleLabel!.font =  UIFont.systemFont(ofSize: 16)
        
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
    }
    
    func titleForLabel() -> String {
        return "Media"
    }
    
    func widthForLabel() -> CGFloat {
        return titleForLabel().size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)]).width + 16
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pointForTargetView = label.convert(point, from: self)
        if label.bounds.contains(pointForTargetView) {
            return label.hitTest(pointForTargetView, with: event)
        }
        return super.hitTest(point, with: event)
    }
}

// MARK: - SMAudioButton -

class SMAudioButton: SMButton {
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        setupImage()
        _type = .Audio
    }
    
    func setupImage() {
        self.setImage(UIImage(named: "Audio"), forState: UIControlState())
    }
    
    override func titleForLabel() -> String {
        return "Audios"
    }
}

// MARK: - SMFigureiButton -

class SMFigureButton: SMButton {
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        setupImage()
        _type = .Figure
    }
    
    func setupImage() {
        self.setImage(UIImage(named: "Figures"), forState: UIControlState())
    }
    
    override func titleForLabel() -> String {
        return "Figures"
    }
}

// MARK: - SMOtherButton -

class SMOtherButton: SMButton {
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        setupImage()
        _type = .Other
    }
    
    func setupImage() {
        self.setImage(UIImage(named: "Other"), forState: UIControlState())
    }
    
    override func titleForLabel() -> String {
        return "Other Files"
    }
}

// MARK: - SMTableButton -

class SMTableButton: SMButton {
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        setupImage()
        _type = .Table
    }
    
    func setupImage() {
        self.setImage(UIImage(named: "Table"), forState: UIControlState())
    }
    
    override func titleForLabel() -> String {
        return "Tables"
    }
}

// MARK: - SMideoButton -

class SMVideoButton: SMButton {
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        setupImage()
        _type = .Video
    }
    
    func setupImage() {
        self.setImage(UIImage(named: "Video"), forState: UIControlState())
    }
    
    override func titleForLabel() -> String {
        return "Videos"
    }
}
