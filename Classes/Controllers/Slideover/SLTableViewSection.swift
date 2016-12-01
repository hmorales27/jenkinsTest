/*
    SLTableViewSection
*/

class SLTableViewSection {
    
    // MARK: - Properties -
    
    let title: String?
    var items: [SLTableViewItem] = []
    var collapsable = false
    var accessibilityLabel: String?
    
    var collapsed = true
    
    // MARK: - Initializers -
    
    init(title: String?) {
        self.title = title
    }
    
    // MARK: - Functions -
    
    func addItem(_ title: String, type: SLTableViewItemType) {
        items.append(SLTableViewItem(title: title, type: type))
    }
    
    func addItem(_ item: SLTableViewItem) {
        items.append(item)
    }
}
