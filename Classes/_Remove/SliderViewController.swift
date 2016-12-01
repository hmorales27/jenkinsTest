//
//  JATSliderViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 10/13/15.
//  Copyright © 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit

class SliderViewController: UIViewController {
    
    var journal:Journal!
    var hambergerButton: UIBarButtonItem!
    
    var backViewController: UIViewController?
    var backViewControllerConstraints: [NSLayoutConstraint] = []
    @IBOutlet var backView: UIView!
    
    var frontViewController: UIViewController?
    var frontViewControllerConstraints: [NSLayoutConstraint] = []
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var frontViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var frontViewRightConstraint: NSLayoutConstraint!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    let sliderMaxStartingPosition: CGFloat = 40.0
    let sliderMaxEndingPosition: CGFloat = 280.0
    var sliderShouldSlide = false
    var sliderOpened = false
    var sliderXPosition: CGFloat = 0.0
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        hambergerButton = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(toggleSliderMenu(_:)))
        navigationItem.leftBarButtonItem = hambergerButton
        
        frontView?.layer.zPosition = 1

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(mainPanGestureRegognizer(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        self.navigationItem.title = journal.journalTitle
    }
    
    // MARK: - Front View Controller -
    
    func changeFrontViewController(frontVC: UIViewController) {
        frontViewController?.view.removeConstraints(frontViewControllerConstraints)
        frontViewController?.view.removeFromSuperview()
        frontViewController = nil

        addChildViewController(frontVC)
        frontViewController = frontVC
        frontView.addSubview(frontVC.view)

        frontVC.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Gesture Methods -
    
    func mainPanGestureRegognizer(gesture:UIPanGestureRecognizer) {
        let location = gesture.locationInView(view)
        
        switch(gesture.state) {
        case .Began:
            if sliderOpened {
                if location.x < sliderMaxEndingPosition + 20 && location.x > sliderMaxEndingPosition - 20 {
                    sliderShouldSlide = true
                } else {
                    sliderShouldSlide = false
                }
            } else {
                if location.x < sliderMaxStartingPosition {
                    sliderShouldSlide = true
                } else {
                    sliderShouldSlide = false
                }
            }
        case .Changed:
            if sliderShouldSlide {
                if sliderOpened {
                    var constraint: CGFloat = 0
                    if location.x > sliderMaxEndingPosition {
                        constraint = sliderMaxEndingPosition
                    } else {
                        constraint = location.x
                    }
                    setFrontViewConstraints(constraint)
                } else {
                    var constraint: CGFloat = 0
                    if location.x > sliderMaxEndingPosition {
                        constraint = sliderMaxEndingPosition
                    } else {
                        constraint = location.x
                    }
                    setFrontViewConstraints(constraint)
                }
            }
        case .Ended:
            if sliderOpened {
                if location.x < sliderMaxStartingPosition {
                    closeSliderMenu()
                } else {
                    openSlideMenu()
                }
            } else {
                if location.x > sliderMaxEndingPosition {
                    openSlideMenu()
                } else {
                    closeSliderMenu()
                }
            }
            
        default:
            return
        }
    }
    
    @IBAction func toggleSliderMenu(sender: AnyObject) {
        if sliderOpened {
            closeSliderMenu()
        } else {
            openSlideMenu()
        }
    }
    
    func closeSliderMenu() {
        UIView.animateWithDuration(10.0) { () -> Void in
            self.frontViewLeftConstraint.constant = 0
            self.frontViewRightConstraint.constant = 0
        }
        sliderOpened = false
        sliderShouldSlide = false
        sliderXPosition = 0
    }
    
    func openSlideMenu() {
        UIView.animateWithDuration(1.0) { () -> Void in
            self.frontViewLeftConstraint.constant = self.sliderMaxEndingPosition
            self.frontViewRightConstraint.constant = -self.sliderMaxEndingPosition
        }
        sliderOpened = true
        sliderShouldSlide = false
        sliderXPosition = sliderMaxEndingPosition
    }
    
    func setFrontViewConstraints(constraint:CGFloat) {
        self.frontViewLeftConstraint.constant = constraint
        self.frontViewRightConstraint.constant = -constraint
    }
}
