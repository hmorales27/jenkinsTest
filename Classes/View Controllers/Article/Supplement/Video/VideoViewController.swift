//
//  VideoViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 1/14/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class VideoViewController: UIViewController {
    
    let url: URL
    var isDismissable = false
    
    weak var media: Media?
    var request: Foundation.URLRequest?
    
    var videoStarted = false
    
    var playerController: AVPlayerViewController = AVPlayerViewController()
    var alertTimer: Timer?
    
    var didShowAlert = false
    
    init(media: Media, isDismissable: Bool = false) {
        
        self.media = media
        self.isDismissable = isDismissable
        
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
        
        if let titleText = media.text {
            if titleText != "" {
                title = titleText
                
                playerController.view.accessibilityLabel = "Video: " + titleText + " " // + duration + " " + caption
            } else {
                title = "Video"
                
                if let fileName = media.fileName {

                    playerController.view.accessibilityLabel = "Video: " + fileName
                }
            }
        } else {
            title = "Video"
            
            if let fileName = media.fileName {
                
                playerController.view.accessibilityLabel = "Video: " + fileName
            }
        }
        
        if let label = playerController.view.accessibilityLabel {
            
            playerController.view.accessibilityLabel = "\(label). " + "Double-tap to play or pause."
        }
        
        if #available(iOS 9.0, *) {
            playerController.allowsPictureInPicturePlayback = false
        }
    }
    
    @available(*, deprecated: 0.2) init(request: Foundation.URLRequest) {
        url = request.url!
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, deprecated: 0.2) init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.playingVideo = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.playerController.player?.removeObserver(self, forKeyPath: "status")
        self.playerController.player?.removeObserver(self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self)
        
        if alertTimer?.isValid == true {
            
            alertTimer?.invalidate()
        }
        AnalyticsHelper.MainInstance.releaseMultimediaTracking(mediaName: media!.fileName)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.playingVideo = false
    }
    
    
    func setup() {

        let player = AVPlayer(url: url)
        
        self.playerController.player = player
        addChildViewController(self.playerController)
        view.addSubview(self.playerController.view)
        self.playerController.view.frame = view.frame
        playerController.view.isAccessibilityElement = true
        
        player.play()
        
        player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkNetworkStatus(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _player = object as? AVPlayer {
            if _player == self.playerController.player {
                
                if keyPath == "status" {
                    
                    if _player.status == AVPlayerStatus.readyToPlay {
                        if let duration = _player.currentItem?.asset.duration {
                            let durationInt = Int(Float(CMTimeGetSeconds(duration)))
                            if durationInt >= 0 {
                                AnalyticsHelper.MainInstance.configureMultimedia(
                                    mediaName: media?.fileName,
                                    mediaTotalLength: durationInt,
                                    mediaPlayerName: "What Is This",
                                    mediaPlayerID: "What Is This"
                                )
                                AnalyticsHelper.MainInstance.startMultimediaTracking(playPause: true, mediaName: media?.fileName, mediaOffset: 0)
                                videoStarted = true
                            }
                        }
                    } else if _player.status == AVPlayerStatus.failed {
                        
                    }
                    
                } else if keyPath == "rate" {
                    if videoStarted == true {
                        
                        let playedTime = _player.currentTime()
                        let durationInt = Int(Float(CMTimeGetSeconds(playedTime)))
                        if durationInt >= 0 {
                            if _player.rate == 0.0 {
                                AnalyticsHelper.MainInstance.startMultimediaTracking(playPause: false, mediaName: media?.fileName, mediaOffset: durationInt)
                                
                                performOnMainThread({ 
                                    
                                    //  Remove obs. and add after calling -pause() to avoid callback loop.
                                    self.playerController.player?.removeObserver(self, forKeyPath: "rate")
                                    _player.pause()
                                    _player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
                                    self.checkNetworkStatus(nil)
                                })

                            } else {
                                AnalyticsHelper.MainInstance.startMultimediaTracking(playPause: true, mediaName: media?.fileName, mediaOffset: durationInt)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkNetworkStatus(_ notification: Foundation.Notification?) {
        
        if didShowAlert == false {
            let networkAvailable =  InternetHelper.sharedInstance.available
            
            if networkAvailable == false {
                
                performOnMainThread({
                    let alert = Alerts.NoNetwork()
                    self.alertTimer = Timer.init(timeInterval: 10.0, target: self, selector: #selector(self.timerDidFire(_:)), userInfo: nil, repeats: false)
                    
                    guard let timer = self.alertTimer else {
                        
                        return
                    }
                    
                    self.present(alert, animated: true, completion: {
                        
                        self.didShowAlert = true
                        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
                    })
                })
            }
        }
    }
    
    func timerDidFire(_ timer: Timer) {
        timer.invalidate()
        didShowAlert = false
    }
    
    func playMedia() {
        
    }
    
    func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        if isDismissable == true {
            let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain, target: self, action: #selector(closeBarButtonItemClicked(_:)))
            navigationItem.rightBarButtonItem = closeBarButtonItem
        } else {
            let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(backBarButtonItemClicked(_:)))
            navigationItem.leftBarButtonItem = backBarButtonItem
        }
    }
    
    func setupNotifications() {
        
    }
    
    func closeBarButtonItemClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func backBarButtonItemClicked(_ sender: UIBarButtonItem) {
        let _ = navigationController?.popViewController(animated: true)
    }
}

extension AVPlayerViewController {
    
    open override var shouldAutorotate: Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}
