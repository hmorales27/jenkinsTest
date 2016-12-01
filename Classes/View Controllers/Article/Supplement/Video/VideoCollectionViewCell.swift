/**
 * P: VideoCollectionViewCellDelegate
 * C: VideoCollectionViewCell
*/

import UIKit
import Cartography

protocol VideoCollectionViewCellDelegate: class {
    func videoCollectionCellPlayButtonWasClicked(_ video: Media)
    func videoCollectionCellDownloadButtonWasClicked(_ video: Media)
}

class VideoCollectionViewCell: UICollectionViewCell {
    
    var delegate: VideoCollectionViewCellDelegate?
    
    let duration = MediaDurationLabel()
    let fileName = MediaFileNameLabel()
    
    let bottomView = UIView()
    
    let playImageView = PlayVideoImageView()
    let downloadButton = DownloadButton()
    let progressView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let webView = UIWebView()
    
    let playButtonImageView = UIImageView()
    let xAccessibilityView = JBSMView()
    
    weak var media: Media?
    
    // MARK: Initializers
    
    init(video: Media) {
        super.init(frame: CGRect.zero)
        setup(video: video)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup(video: Media) {
        
        self.media = video
        
        setupSubviews()
        setupNotifications()
        setupAutoLayout()
        
        playImageView.delegate = self
        
        downloadButton.delegate = self
        downloadButton.tintColor = UIColor.white
        downloadButton.accessibilityLabel = "download video button"
        
        bottomView.backgroundColor = UIColor.black
        bottomView.alpha = 0.6
        
        let separated = video.fileName.characters.split(separator: ".").map(String.init)
        if let _fileName = separated.first {
            let imageName = _fileName + ".png"
            let path = video.article.fulltextBasePath + "image/\(imageName)"
            if let image = UIImage(contentsOfFile: path) {
                playImageView.image = image
            }
        }
        
        let playImagePath = CachesDirectoryPath + "appimages/video_play_overlay_icon.png"
        if let image = UIImage(contentsOfFile: playImagePath) {
            playButtonImageView.image = image
            playButtonImageView.isAccessibilityElement = true
            playButtonImageView.accessibilityLabel = "Play video button"
            playButtonImageView.accessibilityTraits = UIAccessibilityTraitNone
        }
        
        var durationString = "Duration: "
        if let _duration = video.mediaFileDuration {
            
            let durationComponents = _duration.components(separatedBy: ":")
            
            guard let first = durationComponents.first, let last = durationComponents.last else { return }
            
            let firstString = Int(first) == 0 ? " " : "\(first) minutes"
            let lastString = Int(last) == 0 ? " " : "\(last) seconds"
            
            duration.accessibilityLabel = durationString + firstString + "" + lastString
            durationString += _duration
        }
        duration.text = durationString
        
        progressView.hidesWhenStopped = true
        
        var text = ""
        if let title = video.text {
            text += "<b>\(title)</b>"
        }
        if let caption = video.caption {
            text += caption
        }
        
        webView.loadHTMLString(text, baseURL: nil)
        webView.backgroundColor = UIColor.veryLightGray()
        webView.isOpaque = false
        
        updateDownloadStatus()

        if let title = video.text, let caption = video.caption, let _duration = video.mediaFileDuration {
            
            let strings = [title, caption]
            //var cleanTitle = ""
            var cleanCaption = ""
            
            for _ in strings {
                
                let htmlStringData = caption.data(using: String.Encoding.utf8)!
                
                let options: [String: Any] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue]
                let attributedHTMLString = try! NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
                
                let string = attributedHTMLString.string
                if string == strings.first {
                    //cleanTitle = string
                } else if string == strings.last {
                    cleanCaption = string
                }
            }

            var durationString = "Duration "
            let components = _duration.components(separatedBy: ":")
            guard let first = components.first else { return }
            guard let last = components.last else { return }
            
            guard let firstAsInt = Int(first) else { return }
            durationString += firstAsInt == 0 ? "\(last) seconds" : "\(first) minutes \(last) seconds"
            
            isAccessibilityElement = false
            duration.isAccessibilityElement = false
            
            playImageView.isAccessibilityElement = true
            playImageView.accessibilityLabel = "Video, \(title), " + "\(cleanCaption), " + durationString
            
            downloadButton.accessibilityLabel = "Download Video Button"
            downloadButton.isAccessibilityElement = true
            downloadButton.accessibilityTraits = UIAccessibilityTraitNone
        }
        xAccessibilityView.backgroundColor = UIColor.lightGray()
    }
    
    func setupSubviews() {
        contentView.addSubview(playImageView)
        contentView.addSubview(bottomView)
        contentView.addSubview(progressView)
        contentView.addSubview(fileName)
        contentView.addSubview(downloadButton)
        contentView.addSubview(webView)
        contentView.addSubview(duration)
        contentView.addSubview(playButtonImageView)
        contentView.addSubview(xAccessibilityView)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            playImageView,  // 0
            bottomView,     // 1
            fileName,       // 2
            duration,       // 3
            downloadButton, // 4
            progressView,   // 5
            webView,        // 6
            playButtonImageView,
        ]
        
        constrain(subviews) { (views) in
            guard let superview = views[0].superview else {
                return
            }
            
            let playIV         = views[0]
            let bottomV        = views[1]
            let durationL      = views[3]
            let downloadB      = views[4]
            let progressV      = views[5]
            let webV           = views[6]
            let playButtonIV   = views[7]
            
            playIV.top        == superview.top
            playIV.right      == superview.right
            playIV.left       == superview.left
            playIV.height     == playIV.width * (200/300)
            
            bottomV.right     == superview.right
            bottomV.bottom    == playIV.bottom
            bottomV.left      == superview.left
            
            durationL.top     == bottomV.top      + Config.Padding.Default
            durationL.bottom  == bottomV.bottom   - Config.Padding.Default
            durationL.left    == bottomV.left     + Config.Padding.Default
            
            downloadB.left    == durationL.right  + Config.Padding.Default
            downloadB.right   == bottomV.right    - Config.Padding.Default
            downloadB.centerY == durationL.centerY
            
            progressV.left    == durationL.right  + Config.Padding.Default
            progressV.right   == bottomV.right    - Config.Padding.Default
            progressV.centerY == durationL.centerY
            
            webV.top          == playIV.bottom
            webV.right        == superview.right
            webV.bottom       == superview.bottom
            webV.left         == superview.left
            
            playButtonIV.centerX == playIV.centerX
            playButtonIV.centerY == playIV.centerY
            playButtonIV.width   == 44
            playButtonIV.height  == 44
            
        }
    }
    
    // MARK: - Notifications -
    
    func setupNotifications() {
        guard let media = self.media else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification_download_media_updated(_:)), name: NSNotification.Name(rawValue: Notification.Download.Media.Updated), object: media)
        
        switch media.articleType {
        case .abstract:
            NotificationCenter.default.addObserver(self, selector: #selector(notification_download_media_updated(_:)), name: NSNotification.Name(rawValue: Notification.Download.AbstractSupplement.started), object: media.article)
            NotificationCenter.default.addObserver(self, selector: #selector(notification_download_media_updated(_:)), name: NSNotification.Name(rawValue: Notification.Download.AbstractSupplement.Successful), object: media.article)
        case .fullText:
            NotificationCenter.default.addObserver(self, selector: #selector(notification_download_media_updated(_:)), name: NSNotification.Name.FullTextSupplementDownloadUpdated, object: media.article)
        }
    }
    
    func notification_download_media_updated(_ notification: Foundation.Notification) {
        updateDownloadStatus()
    }
    
    func updateDownloadStatus() {
        guard let media = self.media else { return }
        switch media.downloadStatus {
        case .downloaded:
            performOnMainThread({
                self.downloadButton.isHidden = true
                self.progressView.stopAnimating()
            })
        case .downloading:
            performOnMainThread({
                self.downloadButton.isHidden = true
                self.progressView.startAnimating()
            })
        default:
            performOnMainThread({
                self.downloadButton.isHidden = false
                self.downloadButton.accessibilityLabel = "Download"
                self.progressView.stopAnimating()
            })
        }
    }
    
    // MARK: Reset
    
    override func prepareForReuse() {
        reset()
    }
    
    fileprivate func reset() {
        
    }

}

extension VideoCollectionViewCell: PlayImageViewDelegate {
    
    func playImageViewWasClicked() {
        guard let media = self.media else { return }
        delegate?.videoCollectionCellPlayButtonWasClicked(media)
    }
}

extension VideoCollectionViewCell: DownloadButtonDelegate {
    
    func downloadButtonWasClicked(_ sender: UIButton) {
        guard let media = self.media else { return }
        delegate?.videoCollectionCellDownloadButtonWasClicked(media)
    }
}
