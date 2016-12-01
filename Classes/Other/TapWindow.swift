//
//  TapWindow.swift
//  JBSM
//
//  Created by Ruhl, Glen (ELS-PHI) on 7/25/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//



//  https://mithin.wordpress.com/2009/08/26/detecting-taps-and-events-on-uiwebview-the-right-way/
protocol TapWindowDelegate: class {
    
    func userTappedView(touch: AnyObject)
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
        
        print("observedView == \(observedView) cancelsTouchesInView == ")
        delegate = _delegate
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func passTouch(touch: AnyObject) {
        
        delegate?.userTappedView(touch)
    }
    
    override func sendEvent(event: UIEvent) {
        
        super.sendEvent(event)
        if delegate == nil {
            return
        }
        
        let touches = event.allTouches()
        if touches?.count != 1 {
            return
        }
        
        let touch = touches?.first
        if touch?.phase != .Ended {
            return
        }
        if touch?.view?.isDescendantOfView(observedView) == false {
            return
        }

        guard let tappedPoint = touch?.locationInView(observedView) else {
            
            return
        }
        
        print("tappedPoint == \(tappedPoint)")
        
        let pointArray = ["\(tappedPoint.x)","\(tappedPoint.y)"]
        print("point array == \(pointArray)")
        
        if touch?.tapCount == 1 {
            
            //  Can shorten this delay if event order ends up being "off"
            performSelector(#selector(passTouch(_:)), withObject: pointArray, afterDelay: 0.5)
        }
        else if touch?.tapCount > 1 {
            
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(passTouch(_:)), object: pointArray)
        }
    }
    
}