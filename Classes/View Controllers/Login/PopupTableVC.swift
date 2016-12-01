//
//  PopupTableVC.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/26/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

private let CellIdentifier = "cell"

class PopupTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableData = ["Send Message","Add to Contacts","Copy"]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        return cell!
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return tableData.count
    }
}
