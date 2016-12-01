//
//  SLNavigationProtocol.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/14/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

protocol SLTableViewItemTypeProtocol: class {
    func slTableViewNavigateWithType(_ type: SLTableViewItemType)
    func slTableViewReloadSection(_ section: Int)
    func slTableViewNavigateWithType(_ type: SLTableViewItemType, text: String)
}
