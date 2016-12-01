/*
 * ArticleUtilityToolbarDelegate
 * ArticleUtilityToolbarType
 * ArticleUtilityToolbar
*/

import UIKit
import Cartography

protocol ArticleUtilityToolbarDelegate {
    func articleUtilityToolbar(_ toolbar: ArticleUtilityToolbar, didSelectButton button: UIBarButtonItem, ofType type: ArticleUtilityToolbarType)
}

enum ArticleUtilityToolbarType {
    case bookmark
    case share
    case fontSize
    case pdf
    case info
}

class ArticleUtilityToolbar: UIToolbar {
    
    var utilityDelegate: ArticleUtilityToolbarDelegate?
    
    var starred = false
    
    lazy var bookmarkBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "Starred-Active"), style: .plain, target: self, action: #selector(bookmarkBarButtonItemClicked(_:)))
        item.accessibilityLabel = Accessibility.Article.UtilityToolbar.Bookmark
        return item
    }()
    
    lazy var shareBookmarkBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "Share"), style: .plain, target: self, action: #selector(shareBarButtonItemClicked(_:)))
        item.accessibilityLabel = Accessibility.Article.UtilityToolbar.Share
        return item
    }()
    
    lazy var fontSizeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "Change Text"), style: .plain, target: self, action: #selector(fontSizeBarButtonItemClicked(_:)))
        item.accessibilityLabel = Accessibility.Article.UtilityToolbar.FontSize
        return item
    }()
    
    lazy var pdfBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "ArticleToolbar_PDF"), style: .plain, target: self, action: #selector(pdfBarButtonItemClicked(_:)))
        item.accessibilityLabel = Accessibility.Article.UtilityToolbar.PDF
        return item
    }()
    
    // MARK: - Initializers -
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -

    func setup() {
        let firstSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let bookmarkShareSeparator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        bookmarkShareSeparator.width = 16
        let shareTextSizeSeparator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        shareTextSizeSeparator.width = 16
        let pdfStarSeparator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        pdfStarSeparator.width = 16
        
        items = [
            firstSeparator,
            pdfBarButtonItem,
            shareTextSizeSeparator,
            fontSizeBarButtonItem,
            bookmarkShareSeparator,
            shareBookmarkBarButtonItem,
            pdfStarSeparator,
            bookmarkBarButtonItem
        ]
    }
    
    func update(_ article: Article) {
        if article.downloadInfo.fullTextDownloadStatus != .downloaded {
            pdfBarButtonItem.isEnabled = false
            pdfBarButtonItem.isAccessibilityElement = false
        } else {
            pdfBarButtonItem.isEnabled = true
            pdfBarButtonItem.isAccessibilityElement = true
        }
        updateStarredButton(article.starred.boolValue)
    }
    
    func updateStarredButton(_ starred: Bool) {
        if starred == true {
            bookmarkBarButtonItem.image = UIImage(named: "Starred-Active")
            bookmarkBarButtonItem.tintColor = UIColor.darkGoldColor()
            bookmarkBarButtonItem.accessibilityLabel = "Article has been added to reading list. Double-tap to remove it."
            self.starred = true
            
        } else {
            bookmarkBarButtonItem.image = UIImage(named: "Starred-Inactive")
            bookmarkBarButtonItem.tintColor = AppConfiguration.ToolbarItemTintColor
            bookmarkBarButtonItem.accessibilityLabel = "Add To Reading List"
            self.starred = false
        }
    }
    
    func infoButtonClicked(_ sender: UIBarButtonItem) {
        utilityDelegate?.articleUtilityToolbar(self, didSelectButton: sender, ofType: .info)
    }
    
    // MARK: - Selectors -
    
    func bookmarkBarButtonItemClicked(_ sender: UIBarButtonItem) {
        utilityDelegate?.articleUtilityToolbar(self, didSelectButton: sender, ofType: .bookmark)
        updateStarredButton(!starred)
    }
    
    func shareBarButtonItemClicked(_ sender: UIBarButtonItem) {
        utilityDelegate?.articleUtilityToolbar(self, didSelectButton: sender, ofType: .share)
    }
    
    func fontSizeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        utilityDelegate?.articleUtilityToolbar(self, didSelectButton: sender, ofType: .fontSize)
    }
    
    func pdfBarButtonItemClicked(_ sender: UIBarButtonItem) {
        utilityDelegate?.articleUtilityToolbar(self, didSelectButton: sender, ofType: .pdf)
    }
    
}
