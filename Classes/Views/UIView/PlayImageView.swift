/*
 *
 */

import UIKit

protocol PlayImageViewDelegate: class {
    func playImageViewWasClicked()
}

class PlayImageView: UIImageView {
    
    var delegate: PlayImageViewDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        isUserInteractionEnabled = true
        backgroundColor = UIColor.black
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playImageViewWasClicked))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc fileprivate func playImageViewWasClicked() {
        delegate?.playImageViewWasClicked()
    }
    
}

class PlayAudioImageView: PlayImageView {
    
    fileprivate let playImagePath = CachesDirectoryPath + "/appimages/video.png"
    
    override init() {
        if let image = UIImage(contentsOfFile: playImagePath) {
            super.init(image: image)
        } else {
            super.init()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayVideoImageView: PlayImageView {
    
    fileprivate let playImagePath = CachesDirectoryPath + "/appimages/video.png"
    
    override init() {
        if let image = UIImage(contentsOfFile: playImagePath) {
            super.init(image: image)
        } else {
            super.init()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
