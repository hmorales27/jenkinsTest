//
//  VideosViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/17/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
import QuickLook

private let CellIdentifier = "OtherTableViewCell"
private var CellSize = CGSizeMake(360, 169 + 100)

class OthersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CellSize
        flowLayout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16)
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        return flowLayout
    }()
    
    var videos:[Media] = []
    
    // MARK: Initializers
    
    init(medias: [Media]) {
        super.init(nibName: nil, bundle: nil)
        videos = medias
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
        title = "Others"
        
        view.backgroundColor = UIColor.veryLightGray()
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.registerClass(OtherCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = UIColor.veryLightGray()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupAutoLayout()
        setupNavigationBar()
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
    
    // MARK: TableView
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let media = videos[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! OtherCollectionViewCell
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.setup(audio: media)
        cell.media = media
        cell.viewController = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = videos.count
        return count
    }
    
    func setupNavigationBar() {
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .Plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
        navigationItem.leftBarButtonItem = closeBarButtonItem
    }
    
    func closeBarButtonItemClicked(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return sizeForCell()
    
    func sizeForCell() -> CGSize {
        let cvWidth = collectionView.frame.width
        let paddingWidth: CGFloat = 16
        var numberOfCells: CGFloat = 1
        
        if cvWidth >= 1023 {
            numberOfCells = 3
        } else if cvWidth >= 694 {
            numberOfCells = 2
        } else if cvWidth >= 768 {
            numberOfCells = 3
        } else if cvWidth >= 667 {
            numberOfCells = 4
        } else if cvWidth >= 568 {
            numberOfCells = 4
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
    
        return CGSize(width: cellWidth, height: (cellWidth * (2/3)) + 30)

    }
}

extension OthersViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
        return videos.count
    }
    
    
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return videos[index].pathURL
    }
}
