//
//  AudioViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/20/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import Cartography

class AudioViewController: UIViewController {
    
    var dismissable = false
    
    let url: URL
    
    weak var media: Media?
    var request: Foundation.URLRequest?
    
    var videoStarted = false
    
    var webView: UIWebView = UIWebView()
    
    init(media: Media, dismissable: Bool = false) {
        
        self.media = media
        self.dismissable = dismissable

        switch media.downloadStatus {
        case .downloaded:
            switch media.articleType {
            case .abstract:
                var path: String
                if FileSystemManager.sharedInstance.pathExists(media.pathString) {
                    path = media.pathString
                } else {
                    path = media.oldAbsSupplementPath
                }
                url = URL(fileURLWithPath: path)
            case .fullText:
                url = media.pathURL as URL
            }
        default:
            url = JBSMURLRequest.V2.MediaURL(media: media, download: false)! as URL
        }
        
        super.init(nibName: nil, bundle: nil)
        
        webView.isAccessibilityElement = true
        
        let barAppearace = UIBarButtonItem.appearance()
        barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for:UIBarMetrics.default)
        
        
//        UIBarButtonItem.appearance().setBack
        
        
        /*if #available(iOS 9.0, *) {
            playerController.allowsPictureInPicturePlayback = false
        }*/
    }
    
    @available(*, deprecated: 0.2)
    init(request: Foundation.URLRequest) {
        url = request.url!
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, deprecated: 0.2)
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        performOnMainThread { 
            self.setup()
            self.setupNavigationBar()
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AnalyticsHelper.MainInstance.releaseMultimediaTracking(mediaName: media!.fileName)
    }
    
    func setup() {

        if let titleText = self.media?.text {
            if titleText != "" {
                self.title = titleText
                webView.accessibilityLabel = "Audio: \(titleText). "
            } else {
                self.title = "Audio"
                if let fileName = media?.fileName {
                    webView.accessibilityLabel = "Audio: \(fileName). "
                }
            }
        } else {
            self.title = "Audio"
            
            if let fileName = media?.fileName {
                webView.accessibilityLabel = "Audio: \(fileName). "
            }
        }
        
        if let label = webView.accessibilityLabel {
            
            webView.accessibilityLabel = label + "Double-tap to play or pause."
        }
        
        self.view.addSubview(self.webView)
        if #available(iOS 9.0, *) {
            self.webView.allowsPictureInPictureMediaPlayback = false
        }

        self.webView.loadRequest(Foundation.URLRequest(url: self.url))

        constrain(self.webView) { (view) in
            guard let superview = view.superview else {
                return
            }
            view.top == superview.top
            view.right == superview.right
            view.bottom == superview.bottom
            view.left == superview.left
        }
    }

    
    func setupNavigationBar() {
        if dismissable == true {
            navigationItem.hidesBackButton = true
            let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
            navigationItem.rightBarButtonItem = closeBarButtonItem
        } 
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func backBarButtonItemClicked(_ sender: UIBarButtonItem) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
}
