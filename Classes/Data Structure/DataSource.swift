//
//  DataSource.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/23/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

/******************************
 *                            *
 * Data Source                *
 *                            *
 *****************************/

public class DataSource<T> {
    typealias Section = DataSourceSection<T>
    typealias Item = DataSourceItem<T>
    
    typealias ElementType = T
    
    internal var elements = [Section]()
    
    private(set) public var items: [DataSourceItem<T>] = []
    
    private(set) public var count: Int = 0
    private(set) public var itemCount: Int = 0
    
    public init() { }
    
    public func add(item: T, sectionIdentifier: String) {
        var newItem: Item
        if let section = findSection(identifier: sectionIdentifier) {
            newItem = section.add(item: item)
        } else {
            let newSection = createSection(identifier: sectionIdentifier)
            newItem = newSection.add(item: item)
            elements.append(newSection)
            count += 1
        }
        items.append(newItem)
        itemCount += 1
    }
    
    private func createSection(identifier: String) -> Section {
        return Section(identifier: identifier)
    }
    
    private func findSection(identifier: String) -> Section? {
        for element in elements {
            if element.identifier == identifier {
                return element
            }
        }
        return nil
    }
    
    public subscript(index: Int) -> DataSourceSection<T> {
        return elements[index]
    }
}

extension DataSource: CustomStringConvertible {
    public var description: String {
        var s = "[ "
        for element in elements {
            s += " [ \(element.identifier) - \(element.count) ] "
        }
        s += " ]"
        return s
    }
}

extension DataSource where T: Article {
    public func add(article: Article) {
        add(item: article as! T, sectionIdentifier: article.articleType ?? "")
    }
    
    public func filter(predicate: (T) -> Bool) -> DataSource<T> {
        let newDataSource = DataSource<T>()
        for element in elements {
            for item in element.elements {
                if predicate(item.value) {
                    newDataSource.add(article: item.value)
                }
            }
        }
        return newDataSource
    }
}



/******************************
 *                            *
 * Data Source Section        *
 *                            *
 *****************************/

public class DataSourceSection<T> {
    typealias Item = DataSourceItem<T>
    
    fileprivate var elements = [Item]()
    public var identifier: String
    
    public var count: Int {
        return elements.count
    }
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    fileprivate func add(item: T) -> Item {
        let newItem = Item(value: item)
        elements.append(newItem)
        return newItem
    }
}

/******************************
 *                            *
 * Data Source Item           *
 *                            *
 *****************************/

public class DataSourceItem<T> {
    
    let value: T
    
    public init(value: T) {
        self.value = value
    }
}
