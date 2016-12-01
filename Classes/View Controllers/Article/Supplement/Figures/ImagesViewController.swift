//
//  ImagesViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/5/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

private let CellIdentifier = "ImageTableViewCell"
private let CellSize = CGSize(width: 360, height: 169 + 100)

class ImagesViewController: JBSMViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionView: UICollectionView!
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CellSize
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        return flowLayout
    }()
    
    var figures:[Media] = []
    
    // MARK: Initializers
    
    init(figures: [Media]) {
        super.init(nibName: nil, bundle: nil)
        self.figures = figures.sorted(by: {
            $0.sequence.int32Value < $1.sequence.int32Value
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: Setup
    
    func setup() {
        setupCollectionView()
        setupSubviews()
        setupAutoLayout()
        setupNavigationBar()
        setupView()
    }
    
    func setupSubviews() {
        view.addSubview(collectionView)
    }
    
    func setupAutoLayout() {
        constrain(collectionView) { (collectionView) -> () in
            guard let superview = collectionView.superview else {
                return
            }
            collectionView.left == superview.left
            collectionView.top == superview.top
            collectionView.right == superview.right
            collectionView.bottom == superview.bottom
        }
    }
    
    func setupView() {
        view.backgroundColor = UIColor.black
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
    }
    
    // MARK: TableView
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let figure = figures[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.configure(figure)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return figures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let cvWidth = collectionView.frame.width
        let paddingWidth: CGFloat = 8
        var numberOfCells: CGFloat = 1
        
        if cvWidth >= 1023 {
            numberOfCells = 4
        } else if cvWidth >= 694 {
            numberOfCells = 3
        } else if cvWidth >= 768 {
            numberOfCells = 3
        } else if cvWidth >= 667 {
            numberOfCells = 3
        } else if cvWidth >= 568 {
            numberOfCells = 3
        } else if cvWidth >= 507 {
            numberOfCells = 3
        } else if cvWidth >= 464 {
            numberOfCells = 2
        }else {
            numberOfCells = 2
        }
        
        let numberOfPadding = numberOfCells + 1
        let spaceForCells = cvWidth - (numberOfPadding * paddingWidth)
        let cellWidth = spaceForCells / numberOfCells
        
        return CGSize(width: cellWidth, height: cellWidth + 22 + 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let figureVC = ImagePageController(figures: figures, index: (indexPath as NSIndexPath).row)
        figureVC.shouldShowBackButton = true
        navigationController?.pushViewController(figureVC, animated: true)
    }
    
    override func setupNavigationBar() {
        title = "Figures"
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
        navigationItem.leftBarButtonItem = closeBarButtonItem
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Layout -
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}
