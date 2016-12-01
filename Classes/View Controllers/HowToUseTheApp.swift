//
//  HowToUseTheApp.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 4/27/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class HowToUseTheAppItem: UIViewController {
    
    let imageView: UIImageView = UIImageView()
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
    }
    
    func setupSubviews() {
        view.addSubview(imageView)
    }
    
    func setupAutoLayout() {
        constrain(imageView) { (imageV) in
            guard let superview = imageV.superview else {
                return
            }
            imageV.top == superview.top
            imageV.right == superview.right
            imageV.bottom == superview.bottom
            imageV.left == superview.left
        }
    }
}

class HowToUseTheAppController: JBSMViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // MARK: - Properties -
    
    fileprivate var _prepared = false
    
    let headlineView = HeadlineView()
    let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let pageCounter = UIPageControl()
    
    var index = 0
    var controllers: [HowToUseTheAppItem] = []
    
    var previousVC: HowToUseTheAppItem? {
        get {
            if (index - 1) >= 0 {
                return controllers[index - 1]
            }
            return nil
        }
    }
    var currentVC: HowToUseTheAppItem? {
        get {
            if index >= 0 && index < controllers.count {
                return controllers[index]
            }
            return nil
        }
    }
    var nextVC: HowToUseTheAppItem? {
        get {
            if (index + 1) < controllers.count {
                return controllers[index + 1]
            }
            return nil
        }
    }
    
    // MARK: - Initializers -
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.preferredContentSize = CGSize(width: 707, height: 583 + 44)
        
        headlineView.update("Getting Started with Articles")
        headlineView.titleLabel.textAlignment = NSTextAlignment.center
        
        view.backgroundColor = UIColor.colorWithHexString("DADADA")
        
        pageCounter.numberOfPages = 3
        pageCounter.currentPage = 0
        pageCounter.pageIndicatorTintColor = AppConfiguration.NavigationBarColor
        
        if screenType == .mobile {
            let itemOne = HowToUseTheAppItem(image: UIImage(named: "HowTo-iPhone-Navigation")!)
            controllers.append(itemOne)
            let itemTwo = HowToUseTheAppItem(image: UIImage(named: "HowTo-iPhone-Action")!)
            controllers.append(itemTwo)
            let itemFour = HowToUseTheAppItem(image: UIImage(named: "HowTo-iPhone-AddNotes")!)
            controllers.append(itemFour)
        } else {
            let itemOne = HowToUseTheAppItem(image: UIImage(named: "HowTo-iPad-Navigation")!)
            controllers.append(itemOne)
            let itemTwo = HowToUseTheAppItem(image: UIImage(named: "HowTo-iPad-Action")!)
            controllers.append(itemTwo)
            let itemFour = HowToUseTheAppItem(image: UIImage(named: "HowTo-iPad-AddNotes")!)
            controllers.append(itemFour)
        }
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if _prepared == false {
            prepare()
            _prepared = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        update()
    }
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupView()
        setupPager()
        setupNavigationBar()
    }
    
    func setupSubviews() {
        view.addSubview(pageController.view)
        view.addSubview(headlineView)
        view.addSubview(pageCounter)
    }
    
    func setupAutoLayout() {
        constrain(pageController.view, headlineView, pageCounter) { (view, headline, counter) in
            guard let superview = view.superview else {
                return
            }
            headline.top == superview.top
            headline.right == superview.right
            headline.left == superview.left
            
            view.top == headline.bottom + 8
            view.right == superview.right
            view.left == superview.left
            
            counter.top == view.bottom
            counter.right == superview.right
            counter.bottom == superview.bottom
            counter.left == superview.left
        }
        
        if screenType == .tablet {
            headlineView.layoutConstraints.height?.constant = 0
            title = "Getting Started with Articles"
        }
    }
    
    func setupView() {
        
    }
    
    func setupPager() {
        addChildViewController(pageController)
        pageController.didMove(toParentViewController: self)
        pageController.delegate = self
        pageController.dataSource = self
        pageController.setViewControllers([controllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    // MARK: - Prepare -
    
    func prepare() {
        
    }
    
    // MARK: - Update -
    
    func update() {
        
    }
    
    // MARK: - Page Controller -
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pageWithViewController(pendingViewControllers[0])
    }
    
    func pageWithViewController(_ viewController: UIViewController) {
        guard let pendingVC = viewController as? HowToUseTheAppItem else {
            return
        }
        if pendingVC == previousVC {
            pageBackward(pendingVC)
        } else {
            pageForward(pendingVC)
        }
    }
    
    func pageForward(_ viewController: UIViewController) {
        index += 1
        pageCounter.currentPage = pageCounter.currentPage + 1
        pageController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
    }
    
    func pageBackward(_ viewController: UIViewController) {
        index -= 1
        pageCounter.currentPage = pageCounter.currentPage - 1
        pageController.setViewControllers([viewController], direction: .reverse, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return previousVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == true {
            setupNavigationBar()
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        var leftItem: UIBarButtonItem?
        var rightItem: UIBarButtonItem?
        
        if previousVC != .none {
            leftItem = UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(backBarButtonItemClicked(_:)))
        }
        if nextVC != .none {
            rightItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextBarButtonItemClicked(_:)))
        } else {
            rightItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
        }
        
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.rightBarButtonItem = rightItem
    }
    
    func backBarButtonItemClicked(_ sender: UIBarButtonItem) {
        pageBackward(previousVC!)
        setupNavigationBar()
    }
    
    func nextBarButtonItemClicked(_ sender: UIBarButtonItem) {
        pageForward(nextVC!)
        setupNavigationBar()
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
