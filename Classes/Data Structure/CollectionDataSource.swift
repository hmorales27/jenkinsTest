/*
 * CollectionDataSource
 *
 * Created 6/18/2016
 *
 */

@objc protocol CollectionItemProtocol {
    var itemSequence: String { get }
    var itemType: String { get }
    
    var itemHasNotes: Bool { get }
    var itemIsBookmarked: Bool { get }
    var itemOrderNumber: Int { get }
    var itemIsDownloaded: Bool { get }
    var itemIsOA: Bool { get }
}

protocol CollectionDataSourceDelegate: class {
    func collectionDataSourceAllSectionsCollapsed()
    func collectionDataSourceAllSectionsExpanded()
    func collectionDataSourceExpandSection(_ section: CollectionSection, atIndex index: Int)
    func collectionDataSourceCollapseSection(_ section: CollectionSection, atIndex index: Int)
    func collectionDataSourceNeedsTableViewRefresh()
}

enum CollectionItemType {
    case article
    case issue
}

// MARK: - Collection Data Source -

class CollectionDataSource : IteratorProtocol, Sequence {
    
    typealias Element = CollectionSection
    
    fileprivate var sections : [Element] = []
    
    var activeSections : [Element] {
        
        if _showOnlyStarredArticles || _showOnlyArticlesWithNotes || _showOnlyOAIssues || _showOnlyDownloadedIssues {
            var _sections: [Element] = []
            for section in sections {
                if section.expandedCount > 0 {
                    _sections.append(section)
                }
            }
            return _sections
        }
        return sections
    }
    
    fileprivate var items: [CollectionItemProtocol] = []
    var allArticles: [Article] {
        var articles: [Article] = []
        for item in allItems {
            if let article = item.article {
                articles.append(article)
            }
        }
        return articles
    }
    var allIssues: [Issue] {
        var issues: [Issue] = []
        for item in allItems {
            if let issue = item.issue {
                issues.append(issue)
            }
        }
        return issues
    }
    
    fileprivate var mapper : [String: Element] = [:]
    fileprivate var index : Int = 0
    
    fileprivate var _showOnlyArticlesWithNotes = false
    var showOnlyArticlesWithNotes: Bool {
        get {
            return _showOnlyArticlesWithNotes
        }
        set(show) {
            _showOnlyArticlesWithNotes = show
            needsRefresh = true
            for section in sections {
                section.showOnlyArticlesWithNotes = show
            }
        }
    }
    
    fileprivate var _showOnlyStarredArticles = false
    var showOnlyStarredArticles: Bool {
        get {
            return _showOnlyStarredArticles
        }
        set(show) {
            _showOnlyStarredArticles = show
            needsRefresh = true
            for section in sections {
                section.showOnlyStarredArticles = show
            }
        }
    }
    
    fileprivate var _showOnlyOAIssues = false
    var showOnlyOAIssues: Bool {
        get {
            return _showOnlyOAIssues
        }
        set(show) {
            _showOnlyOAIssues = show
            needsRefresh = true
            for section in sections {
                section.showOnlyOAIssues = show
            }
        }
    }
    
    fileprivate var _showOnlyDownloadedIssues = false
    var showOnlyDownloadedIssues: Bool {
        get {
            return _showOnlyDownloadedIssues
        }
        set(show) {
            _showOnlyDownloadedIssues = show
            needsRefresh = true
            for section in sections {
                section.showOnlyDownloadedIssues = show
            }
        }
    }
    
    fileprivate var _showOnlyNonDownloadedArticles = false
    var showOnlyNonDownloadedArticles: Bool {
        get {
            return _showOnlyNonDownloadedArticles
        }
        set(show) {
            _showOnlyNonDownloadedArticles = show
            needsRefresh = true
            for section in sections {
                section.showOnlyNonDownloadedArticles = show
            }
        }
    }
    
    var needsRefresh = false
    
    var numberOfArticles: Int {
        var count = 0
        for section in activeSections { count += section.count }
        return count
    }
    
    weak var dataSourceDelegate: CollectionDataSourceDelegate?
    
    var allItems: [CollectionItem] {
        var articles: [CollectionItem] = []
        for sequence in self {
            for item in sequence {
                articles.append(item)
            }
        }
        return articles
    }
    
    var count : Int { return activeSections.count }
    var itemCount: Int { return items.count }
    var isEmpty : Bool { return activeSections.isEmpty }
    
    var selectedAIPArticles: [Article] {
        var selectedAIPs: [Article] = []
        for section in sections {
            for item in section {
                if item.selectedAIP == true {
                    if let article = item.item as? Article {
                        selectedAIPs.append(article)
                    }
                }
            }
        }
        return selectedAIPs
    }
    
    func clearSelectedAIPs() {
        for section in sections {
            for item in section {
                if item.selectedAIP == true {
                    item.selectedAIP = false
                }
            }
        }
    }
    
    init(arrayLiteral sections: Element...) {
        for section in sections {
            put(section)
        }
    }
    
    init(items: [CollectionItemProtocol]) {
        for item in items {
            add(item: item)
        }
    }
    
    func add(item: CollectionItemProtocol) {
        items.append(item)
        if let section = mapper[item.itemSequence] {
            add(item, toSection: section)
        } else {
            let section = CollectionSection(title: item.itemSequence)
            mapper[item.itemSequence] = section
            section.sectionIndex = count
            put(section)
            add(item, toSection: section)
        }
    }
    
    fileprivate func add(_ item: CollectionItemProtocol, toSection section: CollectionSection) {
        let _item = CollectionItem(item: item)
        section.put(_item)
        if needsRefresh == false {
            needsRefresh = true
        }
    }
    
    func updateItemWithItem(_ item: CollectionItemProtocol, inSection section: CollectionSection) {
        let _item = CollectionItem(item: item)
        section.updateWithNewItem(_item)
    }
    
    subscript(section: Int) -> CollectionSection {
        return activeSections[section]
    }
    
    func next() -> Element? {
        guard index < count else {
            index = 0
            return nil
        }
        let response = activeSections[index]
        index += 1
        return response
    }
    
    func put(_ section: Element) {
        sections.append(section)
    }
    
    func remove(section _section: Element) -> Bool {
        var _index = 0
        for section in sections {
            if section.identifier == _section.identifier {
                sections.remove(at: index)
                return true
            }
            _index += 1
        }
        return false
    }
    
    func contains(section _section: Element) -> Bool {
        for section in sections {
            if section.identifier == _section.identifier {
                return true
            }
        }
        return false
    }
    
    func update(items: [CollectionItemProtocol]) {
        for item in items {
            update(item: item)
        }
    }
    
    func update(item: CollectionItemProtocol) {
        
        if let section = mapper[item.itemSequence] {
            if !section.contains(item: CollectionItem(item: item)) {
                add(item, toSection: section)
            }
        } else {
            let section = newSection(item.itemSequence)
            add(item, toSection: section)
            mapper[item.itemSequence] = section
            put(section)
        }
    }
    
    func indexOf(section _section: CollectionSection) -> Int? {
        var index = 0
        for section in activeSections {
            if section.identifier == _section.identifier {
                return index
            }
            index += 1
        }
        return nil
    }
    
    func newSection(_ title: String) -> CollectionSection {
        let section = CollectionSection(title: title)
        section.sectionIndex = sections.count
        return section
    }
}

extension CollectionDataSource {
    
    // MARK: COLLAPSE
    
    var allSectionsCollapsed: Bool {
        get {
            for section in activeSections {
                if section.collapsed == false { return false }
            }
            return true
        }
    }
    
    var allSectionsExpanded: Bool {
        get {
            for section in activeSections {
                if section.collapsed == true { return false }
            }
            return true
        }
    }
    
    func collapseAll() {
        for section in activeSections {
            section.collapsed = true
        }
        dataSourceDelegate?.collectionDataSourceAllSectionsCollapsed()
    }
    
    func collapse(section: CollectionSection) {
        if let index = indexOf(section: section) {
            collapse(atIndex: index)
        }
    }
    
    func collapse(atIndex index: Int) {
        guard activeSections.count > index else {
            dataSourceDelegate?.collectionDataSourceNeedsTableViewRefresh()
            return
        }
        activeSections[index].collapsed = true
        dataSourceDelegate?.collectionDataSourceCollapseSection(sections[index], atIndex: index)
    }
    
    // MARK: EXPAND
    
    func expandAll() {
        for section in activeSections {
            section.collapsed = false
        }
        dataSourceDelegate?.collectionDataSourceAllSectionsExpanded()
    }
    
    func expand(section: CollectionSection) {
        if let index = indexOf(section: section) {
            expand(atIndex: index)
        }
    }
    
    func expand(atIndex index: Int) {
        guard activeSections.count > index else {
            dataSourceDelegate?.collectionDataSourceNeedsTableViewRefresh()
            return
        }
        activeSections[index].collapsed = false
        dataSourceDelegate?.collectionDataSourceExpandSection(activeSections[index], atIndex: index)
    }
}

// MARK: - Collection Sections -

class CollectionSection: IteratorProtocol, Sequence {
    
    typealias Element = CollectionItem
    
    var identifier: String {
        get {
            return ""
        }
    }
    
    var sectionIndex: Int?
    var innerIndex = 0
    fileprivate var expandedCount: Int {
        return activeItems.count
    }
    var count: Int {
        if collapsed == true {
            return 0
        }
        return activeItems.count
    }
    
    var color: UIColor? {
        guard items.count > 0 else { return nil }
        guard let article = items[0].article else { return nil }
        guard let color = article.sectionColor() else { return nil }
        return color
    }
    
    let title: String
    
    var collapsed = false
    var collapsable = true
    
    fileprivate var items: [Element] = []
    
    var activeItems: [Element] {
        
        if showOnlyArticlesWithNotes || showOnlyStarredArticles || showOnlyOAIssues || showOnlyDownloadedIssues || showOnlyNonDownloadedArticles {
            
            var articlesSet = Set<CollectionItem>([])
            var articlesArray : [CollectionItem] = []
            
            for item in items {
                
                if showOnlyArticlesWithNotes {
                    if item.itemHasNotes {
                        articlesSet.insert(item)
                    }
                }
                if showOnlyStarredArticles {
                    if item.itemIsBookmarked {
                        articlesSet.insert(item)
                    }
                }
                if showOnlyOAIssues {
                    if item.itemIsOA {
                        articlesSet.insert(item)
                    }
                }
                if showOnlyDownloadedIssues {
                    if item.itemIsDownloaded {
                        articlesSet.insert(item)
                    }
                }
                
                if showOnlyNonDownloadedArticles {
                    
                    if !item.itemIsDownloaded {
                        articlesArray.append(item)
                    }
                }
            }
            
            let array = Array(articlesSet)
            
            if showOnlyNonDownloadedArticles {
                
               return reorder(articlesArray)
            } else {
            
                return reorder(array)
            }
        }
        
        return items
    }
    
    fileprivate var showOnlyArticlesWithNotes = false
    fileprivate var showOnlyStarredArticles = false
    
    fileprivate var showOnlyOAIssues = false
    fileprivate var showOnlyDownloadedIssues = false
    
    fileprivate var showOnlyNonDownloadedArticles = false
    
    // MARK: INITIALIZERS
    
    init(arrayLiteral _elements: Element...) {
        title = _elements.count > 0 ? _elements[0].itemSequence : ""
        for element in _elements {
            items.append(element)
        }
    }
    
    init(items: [Element]) {
        self.title = items.count > 0 ? items[0].itemSequence : ""
        self.items = items
    }
    
    init(item: Element) {
        self.title = item.itemSequence
        put(item)
    }
    
    init(title: String) {
        self.title = title
    }
    
    // MARK: METHODS
    
    subscript(item: Int) -> CollectionItem {
        return activeItems[item]
    }
    
    func next() -> Element? {
        guard innerIndex < activeItems.count else {
            innerIndex = 0
            return nil
        }
        let response = activeItems[innerIndex]
        innerIndex += 1
        return response
    }
    
    func put(_ item: Element) {
        items.append(item)
        items = reorder(items)
    }
    
    fileprivate func reorder(_ items: [Element]) -> [Element] {
        guard items.count > 0 else { return [] }
        return items.sorted(by: {
            if $1.issue != .none {
                return $1.itemOrderNumber < $0.itemOrderNumber
            } else {
                return $1.itemOrderNumber > $0.itemOrderNumber
            }
            
        })
    }
    
    @discardableResult func updateWithNewItem(_ itemsitem: Element) -> Bool {
        
        var _index = 0
        for _itemsitem in items {
            if itemsitem.itemSequence == _itemsitem.itemSequence {
                items.remove(at: _index)
                items.insert(itemsitem, at: _index)
                return true
            }
            _index += 1
        }
        return false
    }
    
    func remove(_ itemsitem: Element) -> Bool {
        var _index = 0
        for _itemsitem in items {
            if itemsitem.itemSequence == _itemsitem.itemSequence {
                items.remove(at: _index)
                return true
            }
            _index += 1
        }
        return false
    }
    
    func contains(item _item: Element) -> Bool {
        for item in items {
            if _item == item {
                return true
            }
        }
        return false
    }
}

class CollectionItem: Hashable, Equatable {
    
    var item: CollectionItemProtocol
    
    var article: Article? {
        return item as? Article
    }
    var issue: Issue? {
        return item as? Issue
    }
    
    var expandAuthorList = false
    
    var selectedAIP: Bool = false
    
    var hashValue: Int {
        if item is Article {
            return itemOrderNumber
        } else if let issue = item as? Issue {
            return Int(issue.issueId!)
        }
        return 0
    }
    
    var itemHasNotes: Bool {
        return item.itemHasNotes
    }
    var itemIsBookmarked: Bool {
        return item.itemIsBookmarked
    }
    var itemIsDownloaded: Bool {
        return item.itemIsDownloaded
    }
    var itemIsOA: Bool {
        return item.itemIsOA
    }
    var itemSequence: String {
        return item.itemSequence
    }
    var itemOrderNumber: Int {
        return item.itemOrderNumber
    }
    
    init(item: CollectionItemProtocol) {
        self.item = item
    }
    
}

func ==(lhs: CollectionItem, rhs: CollectionItem) -> Bool {
    if lhs.item === rhs.item {
        return true
    }
    return false
}
