//
//  ImageViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/7/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography
import MessageUI

class ImagePageController: JBSMViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIDocumentInteractionControllerDelegate, EmailInfoDelegate {
    
    // MARK: VIEWS
    
    let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    // MARK: DATA
    
    var figures: [Media]
    
    // MARK: FIGURES
    
    var previousFigure: Media? {
        if previousIndex >= 0 {
            return figures[index - 1]
        }
        return nil
    }
    var currentFigure: Media {
        return figures[index]
    }
    var nextFigure: Media? {
        if nextIndex < figures.count {
            return figures[ index + 1]
        }
        return nil
    }
    
    // MARK: VIEW CONTROLLERS
    
    var previousVC: ImageViewController?
    var currentVC: ImageViewController!
    var nextVC: ImageViewController?
    var docController: UIDocumentInteractionController?

    
    // MARK: INDEX
    
    var previousIndex: Int {
        return index - 1
    }
    var index: Int
    var nextIndex: Int {
        return index + 1
    }
    
    // MARK: SETTINGS
    
    var shouldShowBackButton: Bool = false
    
    // MARK: - Initializers -
    
    init(figures: [Media], index: Int) {
        self.figures = figures
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    
    // MARK: - Setup -
    
    func setup() {
        setupSubviews()
        setupAutoLayout()
        setupView()
        setupPageController()
    }
    
    func shareBarButtonItemClicked(_ sender: UIBarButtonItem) {
        
        let figure = self.figures[self.index]
        var path = figure.pathString
        path = path.replacingOccurrences(of: ".jpg", with: "_lrg.jpg")
        
        if figure.shareable == true {
            
            let url = figure.pathURL
            let provider = EmailInfoProvider()
            provider.delegate = self

            let postItems = [provider, url] as [Any]
            
            let avc = UIActivityViewController(activityItems: postItems, applicationActivities: nil)
            if MFMailComposeViewController.canSendMail() == false {
                avc.excludedActivityTypes = [UIActivityType.mail]
            }

            avc.setValue("Recommended Figure from \(figure.article.journal.journalTitle!)", forKey: "subject")
            
            avc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            avc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up

            present(avc, animated: true, completion: nil)
        } 
    }
    
    func setupSubviews() {
        view.addSubview(pageController.view)
    }
    
    func setupAutoLayout() {
        constrain(pageController.view) { (pgView) in
            guard let superview = pgView.superview else {
                return
            }
            pgView.top    == superview.top
            pgView.right  == superview.right
            pgView.bottom == superview.bottom
            pgView.left   == superview.left
        }
    }
    
    func setupView() {
        view.backgroundColor = UIColor.black
    }
    
    func messageBodyForFigure(_ figure: Media) -> String {
        
        var body = "<html><body>"
        body += figure.article.emailBody
        if let desc = figure.caption {
            body += "<br />\(desc)<br />"
        }
        body += "</body></html>"
        return body
    }
    
    func emailBody() -> String {
        
        return messageBodyForFigure(figures[self.index])
    }
    
    // MARK: - Update -
    
    func update() {
        
        //  Something going wrong here?***
        title = "\(index + 1) of \(figures.count)"
    }
    
    // MARK: - Pager Controller -
    
    func setupPageController() {
        
        addChildViewController(pageController)
        pageController.didMove(toParentViewController: self)
        pageController.delegate = self
        pageController.dataSource = self
        
        if let _previousFigure = previousFigure {
            previousVC = ImageViewController(figure: _previousFigure)
        }
        currentVC = ImageViewController(figure: currentFigure)
        currentVC.delegate = self
        
        if let _nextFigure = nextFigure {
            nextVC = ImageViewController(figure: _nextFigure)
        }
        
        pageController.setViewControllers([currentVC], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pageWithViewController(pendingViewControllers[0])
        update()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return previousVC
    }
    
    func pageWithViewController(_ viewController: UIViewController) {
        
        if viewController == previousVC {
            pageBackward()
        } else if viewController == nextVC {
            pageForward()
        } else {
            log.error("Attempting to Present a VC that's not recognized")
        }
    }
    
    func pageForward() {
        
        previousVC = currentVC
        previousVC?.delegate = nil
        
        currentVC = nextVC
        currentVC.delegate = self
        
        
        nextVC = nil
        index += 1
        if let nextFigure = self.nextFigure {
            nextVC = ImageViewController(figure: nextFigure)
        }
        pageController.setViewControllers([currentVC], direction: .forward, animated: true, completion: nil)
    }
    
    func pageBackward() {
        nextVC = currentVC
        nextVC?.delegate = nil
        
        currentVC = previousVC
        currentVC.delegate = self
        
        previousVC = nil
        index -= 1
        if let previousFigure = self.previousFigure {
            previousVC = ImageViewController(figure: previousFigure)
        }
        pageController.setViewControllers([currentVC], direction: .reverse, animated: true, completion: nil)
    }

    
    // MARK: - Navigation Bar -
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        closeBarButtonItem.accessibilityLabel = "close figure"
        navigationItem.leftBarButtonItem = shouldShowBackButton ? backBarButtonItem : closeBarButtonItem
        
        let shareBarButtonItem = UIBarButtonItem(image: UIImage(named: "Share"), style: .plain, target: self, action: #selector(shareBarButtonItemClicked(_:)))
        shareBarButtonItem.accessibilityLabel = "share figure"
        
        navigationItem.rightBarButtonItem = shareBarButtonItem
        guard MFMailComposeViewController.canSendMail() else {
            shareBarButtonItem.isEnabled = false
            return
        }
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func backBarButtonItemClicked(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}

//  MARK:  ImageController Delegate implementation

extension ImagePageController: ImageControllerDelegate {
    
    func pagerShouldEnableSwipe(_ enableSwipe: Bool) {
        
        for view in pageController.view.subviews {
            
            guard let scrollView = view as? UIScrollView else { continue }
            
            scrollView.isScrollEnabled = enableSwipe
        }
    }
}


//  MARK: ImageControllerDelegate Protocol

protocol ImageControllerDelegate: class {
    
    func pagerShouldEnableSwipe(_ enableSwipe: Bool)
}


//  MARK: ImageViewController (class)

class ImageViewController: JBSMViewController, UIScrollViewDelegate {
    
    let imageView = UIImageView()
    let imageBackgroundView = JBSMScrollView()
    let captionView = JBSMWebView()
    
    weak var figure: Media?
    weak var delegate: ImageControllerDelegate?
    
    var initialScale: CGFloat?
    
    var minZoomScale: CGFloat?
    let maxZoomScale: CGFloat = 2.0
    
    let padding: CGFloat = 0
    
    var captionViewHeightConstraint: NSLayoutConstraint?

    init(figure: Media) {
        super.init(nibName: nil, bundle: nil)
        self.figure = figure
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        view.backgroundColor = UIColor.black
        
        guard let figure = self.figure else {
            return
        }

        setupSubviews()
        setupCaptionView()
        setupAutoLayout()
        setupNavigationBar()
        
        updateCaption(figure.caption)
        setupImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let figure = self.figure else {
            return
        }
        updateImage(figure.pathString)
    }
    
    func setupSubviews() {
        view.addSubview(imageBackgroundView)
        view.addSubview(captionView)
        if imageBackgroundView.subviews.contains(imageView) == false {
            imageBackgroundView.addSubview(imageView)
        }
    }
    
    func setupImageView() {
        imageBackgroundView.backgroundColor = UIColor.black
        imageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupCaptionView() {
        captionView.translatesAutoresizingMaskIntoConstraints = false
        captionView.backgroundColor = UIColor.white
    }
    
    func updateImage(_ path: String) {
        guard let image = figure?.image else { return }
        imageView.image = image
        imageBackgroundView.delegate = self
        configureSizeAndZoomScale(image)
        centerScrollViewContents()
    }
    
    func configureSizeAndZoomScale(_ image: UIImage?) {
        if let image = image {
            imageView.contentMode = .scaleAspectFit
            
            //let ivFrame = CGRectMake(16, 0, view.frame.width, (view.frame.height - 160 - Config.Padding.Double))
            let imageRatio = image.size.width / image.size.height
            let viewRatio = imageView.frame.size.width / imageView.frame.size.height
            var frame = CGRect.zero
            if imageRatio < viewRatio {
                let scale = imageView.frame.size.height / image.size.height
                let width = scale * image.size.width
                //let topLeftX = (imageView.frame.size.width - width) * 0.5
                frame.size = CGSize(width: width, height: imageView.frame.height)
            } else {
                let scale = imageView.frame.size.width / image.size.width
                let height = scale * image.size.height
                let topLeftY = (imageView.frame.size.height - height) * 0.5
                frame = CGRect(x: 0, y: topLeftY, width: imageView.frame.width, height: height)
            }
            imageBackgroundView.contentSize = imageView.frame.size
            imageBackgroundView.contentInset = UIEdgeInsetsMake(padding, padding, padding, padding)
            
            let boundsSize = CGSize(width: view.frame.width, height: (view.frame.height - 160 - Config.Padding.Default))
            
            let scaleWidth = boundsSize.width / imageView.frame.width
            let scaleHeight = boundsSize.height / imageView.frame.height
            
            minZoomScale = min(scaleHeight, scaleWidth) // * 0.8
            
            minZoomScale = 1.0

            guard let _minZoomScale = minZoomScale else { return }
            
            imageBackgroundView.minimumZoomScale = _minZoomScale
            imageBackgroundView.maximumZoomScale = maxZoomScale
            imageBackgroundView.zoomScale = _minZoomScale
            
            initialScale = initialScale == nil ? imageBackgroundView.zoomScale : initialScale
        }
    }
    
    func centerScrollViewContents() {
        let boundsSize = CGSize(width: view.frame.width, height: (view.frame.height - 160 - Config.Padding.Default))
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0
        }
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in self.centerScrollViewContents() }, completion: nil)
    }
    
    func updateCaption(_ caption: String) {
        if caption == "" {
            captionViewHeightConstraint?.constant = 0
        } else {
            var cleanCaption = caption
            while let range = cleanCaption.range(of: "<[^>]+>", options: .regularExpression) {
                cleanCaption = cleanCaption.replacingCharacters(in: range, with: "")
            }
            while let range = cleanCaption.range(of: "  ") {
                cleanCaption = cleanCaption.replacingCharacters(in: range, with: " ")
            }
            if cleanCaption == " " {
                captionViewHeightConstraint?.constant = 0
            } else {
                captionViewHeightConstraint?.constant = 160
                captionView.loadHTMLString(cleanCaption, baseURL: nil)
            }
        }
    }
    
    func setupAutoLayout() {
        constrain(imageView, captionView, imageBackgroundView) { (imageView, captionV, imageBackgroundV) -> () in
            let superview = imageBackgroundV.superview!
            
            imageBackgroundV.left == superview.left
            imageBackgroundV.top == superview.top + 8
            imageBackgroundV.right == superview.right
            imageBackgroundV.bottom == captionV.top - Config.Padding.Default

            imageView.center == imageBackgroundV.center
            imageView.width == imageBackgroundV.width
            imageView.height == imageBackgroundV.height
            
            captionV.left == superview.left
            captionV.right == superview.right
            captionV.bottom == superview.bottom
            
            captionView.layoutConstraints.height = (captionV.height == 160)
        }
    }
    
    //MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        guard let _initialScale = initialScale else { return }
        
        if imageBackgroundView.zoomScale > _initialScale {
            
            captionView.layoutConstraints.height?.constant = 0
            delegate?.pagerShouldEnableSwipe(false)
        }
        else if imageBackgroundView.zoomScale <= _initialScale {

            captionView.layoutConstraints.height?.constant = 160
            delegate?.pagerShouldEnableSwipe(true)
        }
        centerScrollViewContents()
    }
    
    


}

