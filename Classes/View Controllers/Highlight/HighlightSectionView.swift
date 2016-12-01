/*
 * HighlightSectionView
*/

import UIKit
import Cartography

protocol HighlightSectionViewDelegate: class {
    func displayTypeWasSelected(displayType: HighlightDisplayType)
    func highlightSectionViewDidSelectViewAll()
}

class HighlightSectionView: UIView {
    
    weak var delegate: HighlightSectionViewDelegate?
    
    let latestIssueLabel = JBSMLabel()
    let topArticleLabel = JBSMLabel()
    
    let viewAllButton = UIButton(type: .custom)
    let gradientLayer = ViewsHelper.HighlightSeparatorGradient()
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupView()
        setupLabels()
        
        setupBorders()
    }
    
    func setupSubviews() {
        layer.addSublayer(gradientLayer)
        
        addSubview(latestIssueLabel)
        addSubview(topArticleLabel)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            latestIssueLabel, // 0
            topArticleLabel  // 1
        ]
        
        constrain(subviews) { (views) in
            
            let latestIssueL = views[0]
            let topArticleL = views[1]
            
            guard let superview = latestIssueL.superview else {
                return
            }
            
            let labelTop = superview.top
            let labelBottom = superview.bottom
            
            latestIssueL.top == labelTop
            latestIssueL.bottom == labelBottom
            latestIssueL.left == superview.left
            
            
            topArticleL.top == labelTop
            topArticleL.bottom == labelBottom
            topArticleL.left == superview.centerX
            
            if USE_NEW_UI {
                latestIssueL.width == superview.width * 0.5
                topArticleL.width == superview.width * 0.5
                
                superview.height == 60
            } else {
                latestIssueL.width == superview.width * 0.4
                topArticleL.width == superview.width * 0.4

                superview.height == 44
            }
        }
    }
    
    func setupView() {
        backgroundColor = USE_NEW_UI ? UIColor.white : UIColor.veryLightGray()
    }
    
    func setupBorders() {
        
        let bottomView = UIView()
        bottomView.backgroundColor = USE_NEW_UI ? UIColor.lightGray : UIColor.gray
        addSubview(bottomView)
        constrain(bottomView) { (view) in
            guard let superview = view.superview else {
                return
            }
            
            view.right == superview.right
            view.bottom == superview.bottom
            view.left == superview.left
            view.height == 1
        }
    }
    
    func setupLatestIssue() {
        
        let latestIssue = "Latest Issue"
        latestIssueLabel.text = latestIssue
        latestIssueLabel.accessibilityLabel = "\(latestIssue). Heading"
        latestIssueLabel.font = AppConfiguration.DefaultBoldTitleFont
    }

    func setupLabels() {
        let labels = [latestIssueLabel, topArticleLabel]
        
        for label in labels {
            
            label.text = label == latestIssueLabel ? "Latest Issue"  :
                          label == topArticleLabel ? "Top Articles"  : ""
            
            label.textColor = UIColor.darkGray
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.labelWasTapped(recognizer:)))
            
            recognizer.numberOfTapsRequired = 1
            
            label.addGestureRecognizer(recognizer)
            label.isUserInteractionEnabled = true
            
            label.textAlignment = .center
            
            if USE_NEW_UI {
                label.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                label.layer.borderWidth = 0.5
                label.font = AppConfiguration.DefaultTitleFont
                
            } else {
                
                label.font = AppConfiguration.DefaultBoldTitleFont
            }
        }
        
        latestIssueLabel.selected = true
        latestIssueLabel.updateForSelection()
    }


    func setupViewAllButton() {
        viewAllButton.setTitle("View All", for: UIControlState())
        viewAllButton.setTitleColor(UIColor.steelBlue(), for: UIControlState())
        viewAllButton.titleLabel?.font = AppConfiguration.DefaultBoldTitleFont
        viewAllButton.addTarget(self, action: #selector(viewAllButtonWasClicked(_:)), for: .touchUpInside)
        viewAllButton.accessibilityLabel = "View All Articles"
        viewAllButton.accessibilityTraits = UIAccessibilityTraitButton
    }
    
    func labelWasTapped(recognizer: UITapGestureRecognizer) {
        
        guard let label = recognizer.view as? JBSMLabel else { return }

        label.selected = true
        
        if label == latestIssueLabel {
            delegate?.displayTypeWasSelected(displayType: .LatestIssue)
            
        } else if label == topArticleLabel {
            delegate?.displayTypeWasSelected(displayType: .TopArticles)
        }
        
        let labels = [latestIssueLabel, topArticleLabel]
        
        for _label in labels {
            
            if _label != label {
                _label.selected = false
            }
            
            _label.updateForSelection()
        }
    }
    
    
    func viewAllButtonWasClicked(_ sender: UIButton) {
        delegate?.highlightSectionViewDidSelectViewAll()
    }
}


extension JBSMLabel {
    
    override func drawText(in rect: CGRect) {
        
        if superview is HighlightSectionView {
            let insets = UIEdgeInsetsMake(0, Config.Padding.Double, 0, 0)
            super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        
        } else {
            super.drawText(in: rect)
        }
    }
    
}

