/*
 * E: NextPreviousToolbarDelegate
 * P: NextPreviousToolbarType
 * C: NextPreviousToolbar
*/

import UIKit
import Cartography

protocol ArticleNavigationDelegate: class {
    func articleNavigationToolbar(_ toolbar: ArticleNavigationToolbar, didSelectType type: ArticleNavigationType)
}

enum ArticleNavigationType {
    case next
    case previous
}

class ArticleNavigationToolbar: UIToolbar {
    
    var articleNavigationDelegate: ArticleNavigationDelegate?
    var screenType: ScreenType
    
    lazy var previousBarButtonItem: UIBarButtonItem = {
        var item: UIBarButtonItem
        if self.screenType == .mobile {
            item = UIBarButtonItem(image: UIImage(named: "NavigationPreviousiPhone"), style: .plain, target: self, action: #selector(previousBarButtonItemClicked(_:)))
        } else {
            item = UIBarButtonItem(image: UIImage(named: "NavigationPreviousiPad"), style: .plain, target: self, action: #selector(previousBarButtonItemClicked(_:)))
        }
        item.tintColor = Config.Colors.ArticleNavigationArrowColor
        item.accessibilityLabel = "Previous Article"
        return item
    }()
    
    lazy var nextBarButtonItem: UIBarButtonItem = {
        var item: UIBarButtonItem
        if self.screenType == .mobile {
            item = UIBarButtonItem(image: UIImage(named: "NavigationNextiPhone"), style: .plain, target: self, action: #selector(nextBarButtonItemClicked(_:)))
        } else {
            item = UIBarButtonItem(image: UIImage(named: "NavigationNextiPad"), style: .plain, target: self, action: #selector(nextBarButtonItemClicked(_:)))
        }
        item.tintColor = Config.Colors.ArticleNavigationArrowColor
        item.accessibilityLabel = "Next Article"
        return item
    }()
    
    lazy var titleBarButtonItem: UIBarButtonItem = {
        var item = UIBarButtonItem(title: .none, style: .plain, target: self, action: nil)
        item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: UIControlState())
        item.isEnabled = false
        return item
    }()
    
    // MARK: - Initializers -
    
    init(screenType: ScreenType) {
        self.screenType = screenType
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup -
    
    func setup() {
        
        barTintColor = Config.Colors.ArticleNavigationBarBackgroundColor
        let firstSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let lastSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        items = [previousBarButtonItem, firstSeparator, titleBarButtonItem, lastSeparator, nextBarButtonItem]
        
        let topSeparator = UIView()
        topSeparator.backgroundColor = Config.Colors.TableViewSeparatorColor
        addSubview(topSeparator)
        
        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = Config.Colors.TableViewSeparatorColor
        addSubview(bottomSeparator)
        
        constrain(topSeparator, bottomSeparator) { (topS, bottomS) in
            
            guard let superview = topS.superview else { return }
            
            topS.top == superview.top
            topS.right == superview.right
            topS.left == superview.left
            topS.height == 1
            
            bottomS.right == superview.right
            bottomS.bottom == superview.bottom
            bottomS.left == superview.left
            bottomS.height == 1
        }
        
    }
    
    // MARK: - Selectors -
    
    func nextBarButtonItemClicked(_ sender: UIBarButtonItem) {
        articleNavigationDelegate?.articleNavigationToolbar(self, didSelectType: .next)
    }
    
    func previousBarButtonItemClicked(_ sender: UIBarButtonItem) {
        articleNavigationDelegate?.articleNavigationToolbar(self, didSelectType: .previous)
    }
    
}
