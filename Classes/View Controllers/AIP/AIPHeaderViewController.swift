//
//  AIPHeaderView.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 5/1/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

protocol AIPHeaderDelegate: class {
    func aipHeaderDidClickDownloadMultipleArticles()
    func aipHeaderEditDeselectAll()
    func aipHeaderSelectFirstArticles(_ count: Int)
    func aipHeaderDownloadSelected(_ indexPaths: [IndexPath])
    func aipHeaderSelectAllShouldHide(_ selectedCount: Int) -> Bool
    func aipHeaderDownloadArticles(_ articles: [Article])
}

class AIPHeaderViewController: JBSMViewController {
    
    weak var normalHeightConstraint: NSLayoutConstraint?
    weak var editHeightConstraint: NSLayoutConstraint?
    
    weak var journal: Journal?
    
    let aipNormalContainer = UIView()
    
    let aipLabel = UILabel()
    let aipTotalLabel = UILabel()
    let aipCountLabel = UILabel()
    let aipDescriptionLabel = UILabel()
    
    let aipDownloadMultipleButton = UIButton(type: .custom)
    
    let aipMobileDownloadMultipleButton = UIButton(type: .custom)
    
    let aipEditContainer = UIView()
    
    let aipEditLabel = UILabel()
    
    //let aipDownloadSelectedLabel = UILabel()
    
    let aipEditSelectButton = UIButton(type: .custom)
    let aipEditDeselectButton = UIButton(type: .custom)
    let aipEditSelectedLabel = UILabel()
    let aipEditDownloadSelectedButton = UIButton(type: .custom)
    
    let spinner = JBSMActivityView()
    
    var selectedIndexPaths: [IndexPath]?
    
    let separatorView = UIView()
    
    weak var delegate: AIPHeaderDelegate?
    weak var aipVC: AIPVC?
    
    let countLabel = UIView()
    weak var countLabelHeight: NSLayoutConstraint?
    
    weak var viewHeightConstraint: NSLayoutConstraint?
    
    var isEditingMode = false
    
    
    // MARK: - Initializers -
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        
    }
    
    // MARK: - Setup -
    
    func setup() {
        
        countLabel.backgroundColor = UIColor.colorWithHexString("686868")

        setupSubviews()
        setupAutoLayout()

        
        // Normal Container
        
        aipNormalContainer.backgroundColor = UIColor.colorWithHexString("686868")
        separatorView.backgroundColor = UIColor.lightGray
        
        aipLabel.font = UIFont.systemFontOfSize(18, weight: .Bold)
        aipLabel.textColor = UIColor.white
        
        aipTotalLabel.font = UIFont.systemFontOfSize(18, weight: .Bold)
        aipTotalLabel.textColor = UIColor.colorWithHexString("343434")
        aipTotalLabel.isAccessibilityElement = false
        
        aipDescriptionLabel.font = UIFont.italicSystemFontOfSize(16, weight: .Regular)
        aipDescriptionLabel.textColor = UIColor.white
        aipDescriptionLabel.numberOfLines = 0
        
        let defaultFont = UIFont.systemFontOfSize(16, weight: .Regular)
        let defaultTextColor = UIColor.colorWithHexString("1D1D1D")
        
        aipCountLabel.font = defaultFont
        aipCountLabel.textColor = defaultTextColor
        
        //aipDownloadSelectedLabel.font = defaultFont
        aipCountLabel.textColor = defaultTextColor
        
        aipDownloadMultipleButton.setTitle("Download Multiple Articles", for: UIControlState())
        aipDownloadMultipleButton.accessibilityLabel = "Download multiple articles"
        aipDownloadMultipleButton.titleLabel?.font = UIFont.systemFontOfSize(16, weight: .Bold)
        aipDownloadMultipleButton.layer.cornerRadius = 4.0
        aipDownloadMultipleButton.setTitleColor(UIColor.white, for: UIControlState())
        aipDownloadMultipleButton.backgroundColor = UIColor.black
        aipDownloadMultipleButton.addTarget(self, action: #selector(downloadMultipleButtonClicked(_:)), for: .touchUpInside)
        
        aipMobileDownloadMultipleButton.setImage(UIImage(named: "Download"), for: UIControlState())
        aipMobileDownloadMultipleButton.accessibilityLabel = "Download multiple articles"
        aipMobileDownloadMultipleButton.tintColor = UIColor.white
        aipMobileDownloadMultipleButton.addTarget(self, action: #selector(downloadMultipleButtonClicked(_:)), for: .touchUpInside)
        
        // Select Container
        
        aipEditContainer.isHidden = true
        aipEditContainer.backgroundColor = UIColor.colorWithHexString("686868")
        
        aipEditLabel.font = UIFont.systemFontOfSize(18, weight: .Bold)
        aipEditLabel.textColor = UIColor.white
        
        aipEditSelectButton.setTitle("Select", for: UIControlState())
        aipEditSelectButton.titleLabel?.font = UIFont.systemFontOfSize(14, weight: .Bold)
        aipEditSelectButton.layer.cornerRadius = 4.0
        aipEditSelectButton.setTitleColor(UIColor.darkGray, for: UIControlState())
        aipEditSelectButton.backgroundColor = UIColor.veryLightGray()
        aipEditSelectButton.addTarget(self, action: #selector(editSelectButtonWasClicked(_:)), for: .touchUpInside)
        
        aipEditDeselectButton.setTitle("Deselect All", for: UIControlState())
        aipEditDeselectButton.titleLabel?.font = UIFont.systemFontOfSize(14, weight: .Bold)
        aipEditDeselectButton.layer.cornerRadius = 4.0
        aipEditDeselectButton.setTitleColor(UIColor.darkGray, for: UIControlState())
        aipEditDeselectButton.backgroundColor = UIColor.veryLightGray()
        aipEditDeselectButton.addTarget(self, action: #selector(editDeselectButtonWasClicked(_:)), for: .touchUpInside)
        aipEditDeselectButton.isHidden = true
        
        aipEditSelectedLabel.text = ""
        aipEditSelectedLabel.isHidden = true
        
        aipEditDownloadSelectedButton.setTitle("Download Selected", for: UIControlState())
        aipEditDownloadSelectedButton.titleLabel?.font = UIFont.systemFontOfSize(14, weight: .Bold)
        aipEditDownloadSelectedButton.layer.cornerRadius = 4.0
        aipEditDownloadSelectedButton.setTitleColor(UIColor.white, for: UIControlState())
        aipEditDownloadSelectedButton.backgroundColor = UIColor.black
        aipEditDownloadSelectedButton.addTarget(self, action: #selector(editDownloadSelectedButtonWasClicked(_:)), for: .touchUpInside)
        aipEditDownloadSelectedButton.isHidden = true
        
        spinner.updateForAnimation()
    }
    
    func editSelectButtonWasClicked(_ sender: UIBarButtonItem) {
        
        guard let aips = aipVC?.tableVC.allAIPs else { return }
        let count = aips.count
        
        let alertVC = UIAlertController(title: "Select Most Recent Articles", message: nil, preferredStyle: .alert)
        
        // Twenty Five
        var twentyFiveText = ""
        var twentyFiveCount = 0
        if count <= 25 {
            twentyFiveText = "\(count) Articles"
            twentyFiveCount = count
        } else {
            twentyFiveText = "25 Articles"
            twentyFiveCount = 25
        }
        alertVC.addAction(UIAlertAction(title: twentyFiveText, style: .default, handler: { (action) in
            self.aipVC?.tableVC.selectArticles(twentyFiveCount)
        }))
        
        // Fifty
        if count > 25 {
            var fiftyText = ""
            var fiftyCount = 0
            if count <= 50 {
                fiftyText = "\(count) Articles"
                fiftyCount = count
            } else {
                fiftyText = "50 Articles"
                fiftyCount = 50
            }
            alertVC.addAction(UIAlertAction(title: fiftyText, style: .default, handler: { (action) in
                self.aipVC?.tableVC.selectArticles(fiftyCount)
            }))
        }
        
        // One Hundred
        if count > 50 {
            var oneHundredText = ""
            var oneHundredCount = 0
            if count <= 100 {
                oneHundredText = "\(count) Articles"
                oneHundredCount = count
            } else {
                oneHundredText = "100 Articles"
                oneHundredCount = 100
            }
            alertVC.addAction(UIAlertAction(title: oneHundredText, style: .default, handler: { (action) in
                self.aipVC?.tableVC.selectArticles(oneHundredCount)
            }))
        }
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        aipVC?.present(alertVC, animated: true, completion: nil)
    }
    
    func editDeselectButtonWasClicked(_ sender: UIBarButtonItem) {
        updateEditContainer(numberOfSelected: 0)
        delegate?.aipHeaderEditDeselectAll()
    }
    
    func editDownloadSelectedButtonWasClicked(_ sender: UIBarButtonItem) {
        guard NETWORK_AVAILABLE else {
            Alerts.NoNetwork().present(from: self)
            return
        }

        guard let indexPaths = self.selectedIndexPaths else { return }
        delegate?.aipHeaderDownloadSelected(indexPaths)
    }

    func updateForEditing(editing: Bool) {
        performOnMainThread {
            self.isEditingMode = editing
            if editing == true {
                self.aipNormalContainer.isHidden = true
                self.aipEditContainer.isHidden = false
                self.aipVC?.tableVC.dataSource.showOnlyNonDownloadedArticles = true
                self.viewHeightConstraint?.constant = 80
            } else {
                self.aipNormalContainer.isHidden = false
                self.aipEditSelectButton.isHidden = false
                self.aipEditContainer.isHidden = true
                self.aipVC?.tableVC.dataSource.showOnlyNonDownloadedArticles = false
                self.viewHeightConstraint?.constant = 60
            }
            self.updateEditContainer(numberOfSelected: 0)
            self.aipVC?.tableVC.tableView.reloadData()
        }
    }
    
    func downloadMultipleButtonClicked(_ sender: UIBarButtonItem) {
        
        guard NETWORK_AVAILABLE else {
            if let vc = aipVC {
                Alerts.NoNetwork().present(from: vc)
            }
            return
        }
        
        if let _delegate = delegate {
            updateForEditing(editing: true)
            _delegate.aipHeaderDidClickDownloadMultipleArticles()
        }
    }
    
    func setupSubviews() {
        
        aipLabel.translatesAutoresizingMaskIntoConstraints = false
        aipTotalLabel.translatesAutoresizingMaskIntoConstraints = false
        aipCountLabel.translatesAutoresizingMaskIntoConstraints = false
        //aipDownloadSelectedLabel.translatesAutoresizingMaskIntoConstraints = false
        aipDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        //countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        switch screenType {
        case .mobile:
            
            view.addSubview(countLabel)
            view.addSubview(aipNormalContainer)
            aipNormalContainer.addSubview(aipLabel)
            aipNormalContainer.addSubview(aipCountLabel)
            aipNormalContainer.addSubview(aipMobileDownloadMultipleButton)
            aipNormalContainer.addSubview(spinner)
            
            view.addSubview(aipEditContainer)
            aipEditContainer.addSubview(aipEditLabel)
            aipEditContainer.addSubview(aipEditSelectButton)
            aipEditContainer.addSubview(aipEditDeselectButton)
            aipEditContainer.addSubview(aipEditDownloadSelectedButton)
            countLabel.addSubview(aipEditSelectedLabel)
            
        case .tablet:
            
            view.addSubview(aipNormalContainer)
            aipNormalContainer.addSubview(aipLabel)
            aipNormalContainer.addSubview(aipTotalLabel)
            aipNormalContainer.addSubview(aipCountLabel)
            aipNormalContainer.addSubview(aipDescriptionLabel)
            aipNormalContainer.addSubview(aipDownloadMultipleButton)
            aipNormalContainer.addSubview(spinner)
            
            view.addSubview(aipEditContainer)
            aipEditContainer.addSubview(aipEditLabel)
            aipEditContainer.addSubview(aipEditSelectButton)
            aipEditContainer.addSubview(aipEditDeselectButton)
            aipEditContainer.addSubview(aipEditSelectedLabel)
            aipEditContainer.addSubview(aipEditDownloadSelectedButton)
        }
        
        view.addSubview(separatorView)
    }
    
    func setupAutoLayout() {
        
        switch screenType {
        case .mobile:
            setupAutoLayoutForMobile()
        case .tablet:
            setupAutoLayoutForTablet()
        }
        
        constrain(separatorView) { (view) in
            guard let superview = view.superview else {
                return
            }
            view.right  == superview.right
            view.bottom == superview.bottom
            view.left   == superview.left
            view.height == 1
        }
    }
    
    func setupAutoLayoutForMobile() {
        
        let containerSubviews = [
            aipNormalContainer,
            aipEditContainer,
            countLabel
        ]
        
        constrain(containerSubviews) { (subviews) in
            
            let normalContainer = subviews[0]
            let editContainer = subviews[1]
            let countLabel = subviews[2]
            
            guard let superview = normalContainer.superview else {
                return
            }
            
            self.viewHeightConstraint = (superview.height == 60)
            
            countLabel.top == superview.top
            countLabel.right == superview.right
            countLabel.left == superview.left
            countLabelHeight = (countLabel.height == 0)
            
            normalContainer.top == countLabel.bottom
            normalContainer.right == superview.right
            normalContainer.bottom == superview.bottom
            normalContainer.left == superview.left
            
            editContainer.top == countLabel.bottom
            editContainer.right == superview.right
            editContainer.bottom == superview.bottom
            editContainer.left == superview.left
        }
        
        let subviews = [
            aipLabel,
            aipCountLabel,
            aipMobileDownloadMultipleButton,
            spinner
        ]
        
        constrain(subviews) { (views) in
            
            let aipL = views[0]
            let aipCountL = views[1]
            let downloadButton = views[2]
            let spinner = views[3]
            
            guard let superview = aipL.superview else {
                return
            }
            
            aipL.top         == superview.top    + Config.Padding.Default
            aipL.left        == superview.left   + Config.Padding.Default
            
            aipCountL.top    == aipL.bottom      + Config.Padding.Small
            aipCountL.bottom == superview.bottom - Config.Padding.Default
            aipCountL.left   == spinner.right   + Config.Padding.Small
            
            downloadButton.right == superview.right - Config.Padding.Double
            downloadButton.centerY == superview.centerY
            
            self.spinner.layoutConstraints.width = (spinner.width == 25)
            
            spinner.left == superview.left + Config.Padding.Default
            spinner.centerY ==  aipCountL.centerY
            
        }
        
        
        
        let editSubviews = [
            aipEditSelectButton,
            aipEditDeselectButton,
            aipEditDownloadSelectedButton,
            aipEditSelectedLabel,
            countLabel,
            aipEditLabel
        ]
        
        constrain(editSubviews) { (subviews) in
            
            let aipEditSelectB = subviews[0]
            let aipEditDeselectB = subviews[1]
            let aipEditDownloadSelectedB = subviews[2]
            let aipEditDownloadSelectedL = subviews[3]
            let countL = subviews[4]
            let aipEditL = subviews[5]
            
            guard let superview = aipEditSelectB.superview else {
                return
            }
            
            //aipEditSelectB.centerY           == superview.centerY
            aipEditSelectB.left              == superview.left         + Config.Padding.Default
            aipEditSelectB.width             == 54
            aipEditSelectB.height            == 32
            aipEditSelectB.bottom == superview.bottom - Config.Padding.Default
            
            aipEditDeselectB.left            == aipEditSelectB.right   + Config.Padding.Default
            //aipEditDeselectB.centerY         == aipEditSelectB.centerY
            aipEditDeselectB.width           == 92
            aipEditDeselectB.height          == 32
            aipEditDeselectB.bottom == superview.bottom - Config.Padding.Default
            
            aipEditDownloadSelectedB.right   == superview.right - Config.Padding.Default
            aipEditDownloadSelectedB.height  == 32
            //aipEditDownloadSelectedB.centerY == aipEditSelectB.centerY
            aipEditDownloadSelectedB.width   == 144
            aipEditDownloadSelectedB.bottom == superview.bottom - Config.Padding.Default
            
            aipEditDownloadSelectedL.left == countL.left + Config.Padding.Default
            aipEditDownloadSelectedL.right == countL.right - Config.Padding.Default
            //aipEditDownloadSelectedL.top == countL.top + Config.Padding.Default
            aipEditDownloadSelectedL.bottom == countL.bottom
            
            aipEditL.top == superview.top + Config.Padding.Default
            aipEditL.right == superview.right - Config.Padding.Default
            //aipEditL.bottom == superview.bottom - Config.Padding.Default
            aipEditL.left == superview.left + Config.Padding.Default
        }
    }
    
    func setupAutoLayoutForTablet() {
        
        let containerSubviews = [
            aipNormalContainer,
            aipEditContainer
        ]
        
        constrain(containerSubviews) { (subviews) in
            
            let normalContainer = subviews[0]
            let editContainer = subviews[1]
            
            guard let superview = normalContainer.superview else {
                return
            }
            
            superview.height == 100
            
            normalContainer.top == superview.top
            normalContainer.right == superview.right
            normalContainer.bottom == superview.bottom
            normalContainer.left == superview.left
            
            editContainer.top == superview.top
            editContainer.right == superview.right
            editContainer.bottom == superview.bottom
            editContainer.left == superview.left
        }
        
        let subviews = [
            aipLabel,
            aipTotalLabel,
            aipCountLabel,
            aipDescriptionLabel,
            aipDownloadMultipleButton,
            spinner
        ]
        
        constrain(subviews) { (views) in
            
            let aipL                 = views[0]
            let aipTotalL            = views[1]
            let aipCountL            = views[2]
            let aipDescriptionL      = views[3]
            let aipDownloadMultipleB = views[4]
            let spinner              = views[5]
            
            guard let superview = aipL.superview else {
                return
            }
            
            aipL.top                    == superview.top    + Config.Padding.Double
            aipL.left                   == superview.left   + Config.Padding.Double
            
            aipTotalL.top               == superview.top    + Config.Padding.Double
            aipTotalL.left              == aipL.right       + Config.Padding.Small
            
            aipDescriptionL.bottom      == superview.bottom - Config.Padding.Double
            aipDescriptionL.left        == superview.left   + Config.Padding.Double
            aipDescriptionL.right       == aipDownloadMultipleB.left - Config.Padding.Small
            
            aipCountL.top               == superview.top    + Config.Padding.Double
            aipCountL.right             == superview.right  - Config.Padding.Double
            
            aipDownloadMultipleB.right  == superview.right  - Config.Padding.Double
            aipDownloadMultipleB.bottom == superview.bottom - Config.Padding.Double
            aipDownloadMultipleB.width  == 230
            aipDownloadMultipleB.height == 32
            
            self.spinner.layoutConstraints.width = (spinner.width == 25)

            spinner.centerY             == aipCountL.centerY
            spinner.right               == aipDownloadMultipleB.left - Config.Padding.Default
        }
        
        let editSubviews = [
            aipEditLabel,
            aipEditSelectButton,
            aipEditDeselectButton,
            aipEditSelectedLabel,
            aipEditDownloadSelectedButton,
            //aipDownloadSelectedLabel
        ]
        
        constrain(editSubviews) { (subviews) in
            let aipEditL = subviews[0]
            let aipEditSelectB = subviews[1]
            let aipEditDeselectB = subviews[2]
            let aipEditSelectL = subviews[3]
            let aipEditDownloadSelectedB = subviews[4]
            //let aipEditDownloadSelectedL = subviews[5]
            guard let superview = aipEditL.superview else {
                return
            }
            
            aipEditL.top                     == superview.top          + Config.Padding.Double
            aipEditL.left                    == superview.left         + Config.Padding.Double
            
            aipEditSelectB.bottom            == superview.bottom       - Config.Padding.Double
            aipEditSelectB.left              == superview.left         + Config.Padding.Double
            aipEditSelectB.width             == 80
            aipEditSelectB.height            == 32
            
            aipEditDeselectB.left            == aipEditSelectB.right   + Config.Padding.Double
            aipEditDeselectB.height          == 32
            aipEditDeselectB.centerY         == aipEditSelectB.centerY
            aipEditDeselectB.width           == 120
            
            aipEditDownloadSelectedB.right   == superview.right - Config.Padding.Double
            aipEditDownloadSelectedB.height  == 32
            aipEditDownloadSelectedB.centerY == aipEditSelectB.centerY
            aipEditDownloadSelectedB.width   == 180
            
            aipEditSelectL.right             == aipEditDownloadSelectedB.left - Config.Padding.Double
            aipEditSelectL.centerY           == aipEditSelectB.centerY
            aipEditSelectL.height            == aipEditSelectB.height
            
        }
    }
    
    // MARK: - Update -
    
    func update(journal: Journal) {
 
        let aips = aipsForJournal(journal)
        let downloaded = updateDownloadedCountForJournal(journal: journal)
        
        let total = aips.count
        
        var articleDownloading = false
        
        
        //  Insert function call to return number of AIPs downloading.
        
        
        for article in aips {
            articleDownloading = article.downloadInfo.fullTextDownloadStatus == .downloading && articleDownloading == false ? true : articleDownloading
        }

        aipLabel.accessibilityLabel = "\(total) articles in Articles In Press"
        aipCountLabel.accessibilityLabel = "\(downloaded) of \(total) Articles Downloaded"
        
        aipDownloadMultipleButton.accessibilityLabel = "Download Multiple Articles"
        aipEditDownloadSelectedButton.accessibilityLabel = "Download Selected Articles"
        
        switch screenType {
        case .mobile:
            if let aipTitle = journal.aipTitle { updateAIPLabel(aipTitle) }
        case .tablet:
            if let aipTitle = journal.aipTitle { updateAIPLabel(aipTitle) }
            updateAIPTotalLabel(countOfAIPs: total)
            updateAIPDescriptionLabel(journal.aipDescription!)
        }
        
        updateAIPCountLabel(journal)

        
        aipEditLabel.text = "\(total - downloaded) of \(total) Articles Not Downloaded"
        let downloadButton = screenType == .mobile ? aipMobileDownloadMultipleButton : aipDownloadMultipleButton
                
        if total > 0 && downloaded < total {
            
            downloadButton.isHidden = false
            downloadButton.isEnabled = !articleDownloading
        }
        else {
            downloadButton.isHidden = true
        }
        
        articleDownloading == true ? spinner.startAnimating() : spinner.stopAnimating()
        spinner.updateForAnimation()
    }
    
    func updateAIPLabel(_ text: String) {
        aipLabel.text = text + ":"
    }
    
    func updateAIPTotalLabel(countOfAIPs count: Int) {
        aipTotalLabel.text = "\(count) Articles"
    }
    
    func updateAIPDescriptionLabel(_ description: String) {
        aipDescriptionLabel.text = description
        aipDescriptionLabel.accessibilityLabel = description
    }
    
    func updateAIPCountLabel(_ journal: Journal) {
        
        let aips = aipsForJournal(journal)
        let downloaded = updateDownloadedCountForJournal(journal: journal)
        
        let total = aips.count
        
        aipCountLabel.text = "\(downloaded) of \(total) Articles Downloaded"
    }

    func updateEditLabels(_ indexPaths: [NSIndexPath]) {
        self.selectedIndexPaths = indexPaths as [IndexPath]?
        performOnMainThread { 
            self.updateEditContainer(numberOfSelected: indexPaths.count)
        }
        
    }
    
    func updateEditContainer(numberOfSelected selected: Int) {
        switch selected {
        case 0:
            aipEditSelectedLabel.text = "0 Articles Selected"
        case 1:
            aipEditSelectedLabel.text = "1 Article Selected"
        default:
            aipEditSelectedLabel.text = "\(selected) Articles Selected"
        }
        
        if isEditingMode == true {
            switch screenType {
            case .mobile:
                switch selected {
                case 0:
                    countLabelHeight?.constant = 0
                    viewHeightConstraint?.constant = 80
                default:
                    countLabelHeight?.constant = 24
                    viewHeightConstraint?.constant = 80 + 24
                }
            default:
                countLabelHeight?.constant = 0
                viewHeightConstraint?.constant = 80
            }
        } else {
            countLabelHeight?.constant = 0
            viewHeightConstraint?.constant = 60
        }
        
        if selected == 0 {
            aipEditDeselectButton.isHidden = true
            aipEditSelectedLabel.isHidden = true
            aipEditDownloadSelectedButton.isHidden = true
        } else {
            aipEditDeselectButton.isHidden = false
            aipEditSelectedLabel.isHidden = false
            aipEditDownloadSelectedButton.isHidden = false
            
        }
        
        if let shouldHide = delegate?.aipHeaderSelectAllShouldHide(selected) {
            
            aipEditSelectButton.isHidden = shouldHide
        }
    }
    
    //  MARK: - Update data -
    
    func aipsForJournal(_ journal: Journal) -> [Article] {
        return DatabaseManager.SharedInstance.getAips(journal: journal)
    }
    
    
    func updateDownloadedCountForJournal(journal: Journal) -> Int {
        
        var downloaded = 0
        
        let aips = aipsForJournal(journal)
        
        for article in aips {
            if article.downloadInfo.fullTextDownloadStatus == .downloaded {
                downloaded += 1
            }
        }
        
        return downloaded
    }
    
    
}
