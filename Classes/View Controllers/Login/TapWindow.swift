//
//  TapWindow.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/25/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//



//  https://mithin.wordpress.com/2009/08/26/detecting-taps-and-events-on-uiwebview-the-right-way/
protocol TapWindowDelegate: class {
    
    func userTappedView(_ touch: AnyObject)
}


class TapWindow: UIWindow {
    
    var observedView: UIView
    weak var delegate: TapWindowDelegate?
    
    override init(frame: CGRect) {
        observedView = UIView()
        super.init(frame: frame)
    }
    
    init(_observedView: UIView, _delegate: TapWindowDelegate) {
        observedView = _observedView
        
        delegate = _delegate
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func passTouch(_ touch: AnyObject) {
        
        delegate?.userTappedView(touch)
    }
    
    override func sendEvent(_ event: UIEvent) {
        
        super.sendEvent(event)
        if delegate == nil {
            return
        }
        
        let touches = event.allTouches
        if touches?.count != 1 {
            return
        }
        
        let touch = touches?.first
        if touch?.phase != .ended {
            return
        }
        if touch?.view?.isDescendant(of: observedView) == false {
            return
        }

        guard let tappedPoint = touch?.location(in: observedView) else {
            
            return
        }
        let pointArray = ["\(tappedPoint.x)","\(tappedPoint.y)"]
        
        if touch?.tapCount == 1 {
            
            //  Can shorten this delay if event order ends up being "off"
            perform(#selector(passTouch(_:)), with: pointArray, afterDelay: 0.5)
        }
        else if (touch?.tapCount)! > 1 {
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(passTouch(_:)), object: pointArray)
        }
    }
    
}
