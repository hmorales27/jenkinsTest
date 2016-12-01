//
//  TopArticlesMasterVC.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 11/7/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation


class TopArticlesMasterVC: ArticlesFullListVC {
    
    let tableContainer = UIView()
    let headerView = ArticlesHeaderView()
    var tableVC: TopArticlesTableVC?

    
    //  MARK: - Initializers -
    
    override init(journal: Journal) {
        super.init(journal: journal)
        currentJournal = journal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    //  MARK: - Lifecycle -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !NETWORK_AVAILABLE || !NETWORKING_ENABLED {
            
            Alerts.NoNetwork().present(from: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    //  MARK: - Setup -
    
    override func setup() {
        super.setup()
        
        guard let journal = currentJournal else { return }
        
        performOnMainThread {
            self.tableContainer.layer.masksToBounds = true
        }
        
        tableVC = TopArticlesTableVC.init(journal: journal)
        
        guard  let _tableVC = tableVC else {
            return
        }
        
        self.addChildViewController(_tableVC)
        
        tableVC?.didMove(toParentViewController: self)
        tableVC?.delegate = self
        tableVC?.loadTableViewData()
        
        setupSubviews()
        setupAutoLayout()
        setupHeaderView()
    }
    
    func setupSubviews() {
        performOnMainThread { [weak self] in
            
            guard let strongSelf = self, let _view = strongSelf.view, let _tableVC = strongSelf.tableVC else { return }

            _view.addSubview(strongSelf.headerView)
            _view.addSubview(strongSelf.tableContainer)
            
            strongSelf.tableContainer.addSubview(_tableVC.view)

            strongSelf.moveSliderToFront()
            strongSelf.advertisementVC.view.backgroundColor = Config.Colors.SingleJournalBackgroundColor
        }
    }
    
    func setupAutoLayout() {
        guard let _view = view else { return }
        
        performOnMainThread { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let _headerView = strongSelf.headerView
            
            _headerView.topAnchor.constraint(equalTo: _view.topAnchor, constant: 0.0).isActive = true
            
            _headerView._setupTopArtAutoLayout(screenType: strongSelf.screenType)
            
            let leadingAnchor = _view.leadingAnchor
            let trailingAnchor = _view.trailingAnchor
            let heightAnchor = _view.heightAnchor
            
            let _tableContainer = strongSelf.tableContainer
            let topArticlesView = strongSelf.tableVC?.view
            
            _headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
            _headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0).isActive = true
            _headerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1).isActive = true
            
            _headerView.issueDateLabel.topAnchor.constraint(equalTo: _headerView.topAnchor, constant:0.0).isActive = true
            _headerView.issueDateLabel.trailingAnchor.constraint(equalTo: _headerView.trailingAnchor, constant:0.0).isActive = true
            _headerView.issueDateLabel.leadingAnchor.constraint(equalTo: _headerView.leadingAnchor, constant:16.0).isActive = true
            _headerView.issueDateLabel.heightAnchor.constraint(equalTo: _headerView.heightAnchor, constant:0.0).isActive = true
  
            //  TODO: Set this to false for *every* view that uses NSLayoutAnchor.****
            strongSelf.tableContainer.translatesAutoresizingMaskIntoConstraints = false
            strongSelf.tableVC?.view.translatesAutoresizingMaskIntoConstraints = false
            
            strongSelf.tableContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
            strongSelf.tableContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0).isActive = true
            strongSelf.tableContainer.topAnchor.constraint(equalTo: _headerView.bottomAnchor, constant: 0.0).isActive = true
            
            topArticlesView?.leadingAnchor.constraint(equalTo: _tableContainer.leadingAnchor, constant: 0.0).isActive = true
            topArticlesView?.trailingAnchor.constraint(equalTo: _tableContainer.trailingAnchor, constant: 0.0).isActive = true
            topArticlesView?.topAnchor.constraint(equalTo: _headerView.bottomAnchor, constant: 0.0).isActive = true
            topArticlesView?.bottomAnchor.constraint(equalTo: _tableContainer.bottomAnchor, constant: 0.0).isActive = true
            
            strongSelf.setupAdBannerLayout()
        }
    }
    
    func setupHeaderView() {
        
        let tempLabel = headerView.issueDateLabel
        tempLabel.text = Strings.TopArticles.MostReadTitle
        tempLabel.textColor = .white
        tempLabel.textAlignment = .left
        tempLabel.font = AppConfiguration.DefaultBoldTitleFont
        
        headerView.setup(screenType: screenType)
        headerView.showDownloadOrDeleteButton()
        headerView.backgroundColor = AppConfiguration.HeaderBackgroundColor
        
        let headerImage = headerView.coverImageView
        let collapseButton = headerView.collapseButton
        
        let headerViews = [headerView.downloadButton, headerView.spinnerView,
                                                    headerImage, collapseButton]
        
        for view in headerViews {
            switch view {
            case headerImage:
                view.isHidden = true
            case collapseButton:
                view.isHidden = true
            default:
                view.isHidden = true
            }
        }
    }
    
    private func setupAdBannerLayout() {
        advertisementVC.view.topAnchor.constraint(equalTo: tableContainer.bottomAnchor, constant: 0.0).isActive = true
        advertisementVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        advertisementVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        advertisementVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
    }
}


extension TopArticlesMasterVC: TopArticleTableVcDelegate {
    
    func didSelectArticleAt(indexPath: IndexPath) {
        guard let article = tableVC?.articleForIndexPath(indexPath: indexPath),
            
            // let article = articleForIndexPath(indexPath),
            
            let topArticles = tableVC?.tableViewData else { return }
        
        didSelectArticleFromArticles(article, articles: topArticles)
    }
    
    func didSelectViewAllTopArticles() {}
}


