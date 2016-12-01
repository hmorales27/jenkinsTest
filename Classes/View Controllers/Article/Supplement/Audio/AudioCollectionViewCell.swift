/**
 * P: AudioCollectionViewCellDelegate
 * C: AudioCollectionViewCell
 */

import UIKit
import Cartography

protocol AudioCollectionViewCellDelegate: class {
    func audioCollectionCellPlayButtonWasClicked(_ audio: Media)
    func audioCollectionCellDownloadButtonWasClicked(_ audio: Media)
}

class AudioCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: AudioCollectionViewCellDelegate?
    
    let fileName = MediaFileNameLabel()
    let duration = MediaDurationLabel()
    
    let bottomView = UIView()
    
    let playImageView = PlayAudioImageView()
    let downloadButton = DownloadButton()
    let progressView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    let playButtonImageView = UIImageView()
    
    let webView = UIWebView()

    weak var media: Media?
    
    // MARK: Initializers
    
    init(audio: Media) {
        super.init(frame: CGRect.zero)
        setup(audio: audio)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup(audio: Media) {
        self.media = audio
        
        setupSubviews()
        setupNotifications()
        setupAutoLayout()
        
        playImageView.delegate = self
        
        downloadButton.delegate = self
        downloadButton.tintColor = UIColor.white
        
        bottomView.backgroundColor = UIColor.black
        contentView.backgroundColor = UIColor.veryLightGray()
        
        webView.backgroundColor = UIColor.veryLightGray()
        webView.isOpaque = false
        
        var text: String = ""

        playImageView.accessibilityTraits = UIAccessibilityTraitNone
        
        if audio.text != "" {
            text += "<b>\(audio.text)<b>"
            playImageView.accessibilityLabel = "Audio: \(audio.text). "

        } else {
            text += "<b>\(audio.fileName)</b>"
            playImageView.accessibilityLabel = "Audio: \(audio.text). "
        }
        if audio.caption != "" {
            text += audio.caption
        }
        
        webView.loadHTMLString(text, baseURL: nil)
        
        let path = CachesDirectoryPath + "appimages/audio_play_overlay_icon.png"
        if let image = UIImage(contentsOfFile: path) {
            playButtonImageView.image = image
            playButtonImageView.isAccessibilityElement = true
            playButtonImageView.accessibilityLabel = "Play audio button"
            playButtonImageView.accessibilityTraits = UIAccessibilityTraitNone
        }
        
        var durationString = "Duration: "
        if let _duration = audio.mediaFileDuration {
            
            let durationComponents = _duration.components(separatedBy: ":")
            
            guard let first = durationComponents.first, let last = durationComponents.last else { return }
            
            let firstString = Int(first) == 0 ? " " : "\(first) minutes, "
            let lastString = Int(last) == 0 ? " " : "\(last) seconds"
            
            playImageView.isAccessibilityElement = true
            
            if let label = playImageView.accessibilityLabel {
                playImageView.accessibilityLabel = label + durationString + firstString + lastString
            }
            
            durationString += _duration
        }

        duration.text = durationString
        
        progressView.hidesWhenStopped = true
        
        updateDownloadStatus()
        
        downloadButton.isAccessibilityElement = true
        downloadButton.accessibilityLabel = "Download Audio"
        
        duration.isAccessibilityElement = false
        webView.isAccessibilityElement = false
        
        

    }
    
    func setupSubviews() {
        contentView.addSubview(playImageView)
        contentView.addSubview(bottomView)
        contentView.addSubview(fileName)
        contentView.addSubview(downloadButton)
        contentView.addSubview(duration)
        contentView.addSubview(progressView)
        contentView.addSubview(webView)
        contentView.addSubview(playButtonImageView)
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            playImageView,
            bottomView,
            downloadButton,
            duration,
            progressView,
            webView,
            playButtonImageView
        ]
        
        constrain(subviews) { (views) in
            let playIV = views[0]
            let bottomV = views[1]
            let downloadB = views[2]
            let durationB = views[3]
            let progressV = views[4]
            let webV = views[5]
            let playButtonIV = views[6]
            
            guard let superview = playIV.superview else {
                return
            }
            
            playIV.top == superview.top
            playIV.right == superview.right
            playIV.left == superview.left
            playIV.height == 80
            
            playButtonIV.centerX == playIV.centerX
            playButtonIV.centerY == playIV.centerY
            playButtonIV.width == 44
            playButtonIV.height == 44
            
            
            bottomV.top == playIV.bottom
            bottomV.right == superview.right
            bottomV.left == superview.left
            
            durationB.top == bottomV.top + Config.Padding.Default
            durationB.bottom == bottomV.bottom - Config.Padding.Default
            durationB.left == bottomV.left + Config.Padding.Default
            
            downloadB.right == bottomV.right - Config.Padding.Default
            downloadB.left == durationB.right + Config.Padding.Default
            downloadB.centerY == durationB.centerY
            downloadB.width == 34
            downloadB.height == 34
            
            progressV.centerY == downloadB.centerY
            progressV.centerX == downloadB.centerX
            
            webV.top == bottomV.bottom
            webV.right == superview.right
            webV.bottom == superview.bottom
            webV.left == superview.left
        }
    }
    
    // MARK: - Notifications -
    
    func setupNotifications() {
        guard let media = self.media else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(mediaDownloadUpdated(_:)), name: NSNotification.Name(rawValue: Notification.Download.Media.Updated), object: media)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaDownloadUpdated(_:)), name: NSNotification.Name.FullTextSupplementDownloadUpdated, object: media.article)
    }
    
    func mediaDownloadUpdated(_ notification: Foundation.Notification) {
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

extension AudioCollectionViewCell: PlayImageViewDelegate {
    
    func playImageViewWasClicked() {
        guard let media = self.media else { return }
        delegate?.audioCollectionCellPlayButtonWasClicked(media)
    }
}

extension AudioCollectionViewCell: DownloadButtonDelegate {
    
    func downloadButtonWasClicked(_ sender: UIButton) {
        guard let media = self.media else { return }
        delegate?.audioCollectionCellDownloadButtonWasClicked(media)
    }
}
