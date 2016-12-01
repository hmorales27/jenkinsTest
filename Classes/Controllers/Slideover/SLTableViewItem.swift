/*
    SLTableViewItem
*/

class SLTableViewItem {
    
    // MARK: - Properties -
    
    let title: String
    let type: SLTableViewItemType
    var accessibilityLabel: String?
    
    // MARK: - Initializers -
    
    init(title: String, type: SLTableViewItemType) {
        self.title = title
        self.type = type
    }
}

class SLSearchTableViewItem: SLTableViewItem {
    init() {
        super.init(title: "Search", type: .search)
    }
}
