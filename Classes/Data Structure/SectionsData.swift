//
//  JBSMCollectionData.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 4/19/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

@objc protocol SectionDataProtocol: class {
    func sectionKey() -> String
    func downloadable() -> Bool
    func downloaded() -> Bool
    func openArchive() -> Bool
    func sectionColor() -> UIColor?
}

protocol SectionDataDelegate: class {
    func sectionDataDidToggleCollapse(_ collapse: Bool)
}

enum SectionDataType {
    case allItems
    case onDevice
    case openArchive
}

class SectionsData: SectionDataCollapseButtonDelegate {
    
    var allItems: [SectionDataProtocol] = []
    
    var sections: [Section] {
        switch type {
        case .allItems:
            return allItemsSection
        case .onDevice:
            return downloadSections
        case .openArchive:
            return openArchiveSections
        }
    }
    
    var mapper: [String: [SectionDataProtocol]] {
        switch type {
        case .allItems:
            return allItemsMapper
        case .onDevice:
            return downloadMapper
        case .openArchive:
            return openArchiveMapper
        }
    }
    
    var allItemsSection: [Section] = []
    fileprivate var allItemsMapper: [String: [SectionDataProtocol]] = [:]
    
    var downloadSections: [Section] = []
    fileprivate var downloadMapper: [String: [SectionDataProtocol]] = [:]
    
    var openArchiveSections: [Section] = []
    fileprivate var openArchiveMapper: [String: [SectionDataProtocol]] = [:]
    
    var type: SectionDataType = .allItems
    
    var allSectionsCollapsed: Bool {
        for section in sections {
            if section.collapsed == false {
                return false
            }
        }
        return true
    }
    
    weak var delegate: SectionDataDelegate?
    
    weak fileprivate var _collapseButton: CollapseButton?
    var collapseButton: CollapseButton? {
        get {
            return _collapseButton
        }
        set(button) {
            _collapseButton = button
            _collapseButton?.delegate = self
        }
    }
    
    func sectionDataCollapseButtonDidToggle(collapse: Bool) {
        if collapse == true {
            delegate?.sectionDataDidToggleCollapse(true)
        } else {
            delegate?.sectionDataDidToggleCollapse(false)
        }
    }
    
    var collapseFirstSection = false
    
    var itemCount: Int {
        return allItems.count
    }
    
    init(items: [SectionDataProtocol]) {
        self.allItems = items
        sort()
    }
    
    fileprivate func sort() {
        for item in allItems {
            
            let key = item.sectionKey()
            
            if allItemsMapper[key] == nil {
                allItemsMapper[key] = []
                let section = Section(name: key)
                section.color = item.sectionColor()
                allItemsSection.append(section)
            }
            allItemsMapper[key]?.append(item)
            
            if item.downloadable() == true {
                if item.downloaded() == true {
                    if downloadMapper[key] == nil {
                        downloadMapper[key] = []
                        let section = Section(name: key)
                        section.color = item.sectionColor()
                        downloadSections.append(section)
                    }
                    downloadMapper[key]?.append(item)
                }
            }
            
            if item.openArchive() == true {
                if openArchiveMapper[key] == nil {
                    openArchiveMapper[key] = []
                    let section = Section(name: key)
                    section.color = item.sectionColor()
                    openArchiveSections.append(section)
                }
                openArchiveMapper[key]?.append(item)
            }
        }
        if allItemsSection.count > 0 {
            allItemsSection[0].collapsed = collapseFirstSection
        }
        if downloadSections.count > 0 {
            downloadSections[0].collapsed = collapseFirstSection
        }
        if openArchiveSections.count > 0 {
            openArchiveSections[0].collapsed = collapseFirstSection
        }
    }
    
    func toggleCollapseForSection(_ section: Int) {
        if sections[section].collapsed == true {
            sections[section].collapsed = false
        } else {
            sections[section].collapsed = true
        }
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func sectionForIndex(_ index: Int) -> String {
        return sections[index].name
    }
    
    func numberOfItemsForSection(_ index: Int) -> Int {
        if sections[index].collapsed == true {
            return 0
        }
        let section = sections[index].name
        return mapper[section]!.count
    }
    
    func itemsForSection(_ index: Int) -> [SectionDataProtocol] {
        if sections[index].collapsed == true {
            return []
        }
        let section = sections[index].name
        return mapper[section]!
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> SectionDataProtocol? {
        let section = sections[(indexPath as NSIndexPath).section]
        let items = mapper[section.name]!
        return items[(indexPath as NSIndexPath).row]
    }
    
    func collapseAll(collapse: Bool) {
        if collapse {
            for section in sections {
                section.collapsed = true
            }
        } else {
            for section in sections {
                section.collapsed = false
            }
        }
    }
}
