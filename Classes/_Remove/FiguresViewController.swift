//
//  FiguresViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 12/16/15.
//  Copyright © 2015 Elsevier, Inc. All rights reserved.
//

import UIKit

private let CellIdentifier = "FiguresCollectionViewCell"

class FiguresViewController: JBSMViewController {
    
    @IBOutlet weak var collectionView: UICollectionView?
    var collectionViewData:[Media] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setup(figures: [Media]) {
        self.collectionViewData = figures
    }
}

extension FiguresViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! FiguresCollectionViewCell
        return cell
    }
}
