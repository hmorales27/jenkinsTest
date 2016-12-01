//
//  FeedbackViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 3/1/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class FeedbackViewController: SLViewController, UITextViewDelegate, UITextFieldDelegate {
    
    weak var parentVC: UIViewController?
    
    let headerView = HeadlineView()
    var showHeaderView = false
    
    let nameTextField = FeedbackTextField()
    let emailTextField = FeedbackTextField()
    
    let nameEmailView = UIView()
    let separatorView = UIView()
    
    let submitButton = UIButton(type: UIButtonType.custom)
    let cancelButton = UIButton(type: .custom)
    weak var submitButtonBottomConstraint: NSLayoutConstraint?
    
    weak var topConstraint: NSLayoutConstraint?
    
    let bodyTextView = UITextView()
    
    let doneView = UIView()
    let doneButton = UIButton(type: .custom)
    
    override init() {
        super.init()
    }
    
    override init(journal: Journal) {
        super.init(journal: journal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        analyticsScreenName = Constants.Page.Name.InfoFeedback
        analyticsScreenType = Constants.Page.Type.np_gp
        _registerForKeyboardChange = true
        setup()
        super.viewDidLoad()
        
        if showHeaderView == true {
            headerView.titleLabel.text = "Feedback"
            title = currentJournal?.publisher.appTitleIPhone
        } else {
            title = "Feedback"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.preferredContentSize = CGSize(width: 340.0, height: 380.0)
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setup() {
        setupSubviews()
        setupNameEmailView()
        setupNameTextField()
        setupEmailTextField()
        setupBodyTextView()
        setupSubmitButton()
        setupCancelButton()
        setupAutoLayout()
        setupDoneButton()
    }
    
    func setupSubviews() {
        view.addSubview(headerView)
        view.addSubview(nameEmailView)
        nameEmailView.addSubview(nameTextField)
        nameEmailView.addSubview(emailTextField)
        view.addSubview(separatorView)
        view.addSubview(bodyTextView)
        view.addSubview(submitButton)
        view.addSubview(cancelButton)
        view.addSubview(doneView)
        doneView.addSubview(doneButton)
    }
    
    func setupNameEmailView() {
        nameEmailView.backgroundColor = UIColor.white
        nameEmailView.layer.cornerRadius = 8
        nameEmailView.clipsToBounds = true
        nameEmailView.layer.borderColor = UIColor.gray.cgColor
        nameEmailView.layer.borderWidth = 1.0
        separatorView.backgroundColor = UIColor.gray
    }
    
    func setupNameTextField() {
        nameTextField.layer.cornerRadius = 0
        nameTextField.updateLeftTextLabel("Name:")
        nameTextField.delegate = self
        nameTextField.accessibilityLabel = "Please enter your name in this text field"
    }
    
    func setupEmailTextField() {
        emailTextField.layer.cornerRadius = 0
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.none
        emailTextField.updateLeftTextLabel("Email:")
        emailTextField.delegate = self
        emailTextField.accessibilityLabel = "Please enter your email in this text field"
    }
    
    func setupBodyTextView() {
        bodyTextView.returnKeyType = .done
        bodyTextView.layer.cornerRadius = 8
        bodyTextView.delegate = self
        bodyTextView.returnKeyType = UIReturnKeyType.default
        bodyTextView.accessibilityLabel = "Please enter your comments in this text field"
    }
    
    func setupSubmitButton() {
        submitButton.setTitle("Submit", for: UIControlState())
        submitButton.setTitleColor(UIColor.white, for: UIControlState())
        submitButton.backgroundColor = AppConfiguration.NavigationBarColor
        submitButton.layer.cornerRadius = 8
        submitButton.accessibilityLabel = "Submit feedback"
        submitButton.addTarget(self, action: #selector(submitButtonClicked(_:)), for: .touchUpInside)
    }
    
    func setupCancelButton() {
        cancelButton.setTitle("Cancel", for: UIControlState())
        cancelButton.setTitleColor(UIColor.white, for: UIControlState())
        cancelButton.backgroundColor = AppConfiguration.NavigationBarColor
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked(_:)), for: .touchUpInside)
        cancelButton.accessibilityLabel = "Cancel feedback"
        
        if screenType == .mobile {
            cancelButton.isHidden = true
        }
    }
    
    func setupDoneButton() {
        doneView.backgroundColor = UIColor.gray
        doneView.isHidden = true
        
        doneButton.setTitle("Done", for: UIControlState())
        doneButton.setTitleColor(UIColor.white, for: UIControlState())
        doneButton.backgroundColor = AppConfiguration.NavigationBarColor
        doneButton.layer.cornerRadius = 4
        doneButton.addTarget(self, action: #selector(doneButtonWasClicked(_:)), for: .touchUpInside)
    }
    
    func doneButtonWasClicked(_ sender: UIButton) {
        self.view.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.nameTextField.resignFirstResponder()
        self.bodyTextView.resignFirstResponder()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        if screenType == .mobile {
            navigationItem.leftBarButtonItem = menuBarButtonItem
        } else {
            navigationItem.leftBarButtonItems = backButtons("Back")
        }
    }
    
    func setupAutoLayout() {
        
        let subviews = [
            nameEmailView,
            nameTextField,
            separatorView,
            emailTextField,
            bodyTextView,
            submitButton,
            cancelButton,
            headerView,
            doneView,
            doneButton
        ]
        
        constrain(subviews) { (views) in
            let nameEmailV = views[0]
            let nameTF = views[1]
            let separatorV = views[2]
            let emailTF = views[3]
            let bodyTV = views[4]
            let submitB = views[5]
            let cancelB = views[6]
            let headerV = views[7]
            let doneV = views[8]
            let doneB = views[9]
            
            guard let superview = nameEmailV.superview else {
                return
            }
            
            topConstraint = (headerV.top == superview.top)
            headerV.right == superview.right
            headerV.left == superview.left
            
            if showHeaderView == true {
                headerV.height == 40
            } else {
                headerV.height == 0
            }
            
            nameEmailV.top     == headerV.bottom     + Config.Padding.Default
            nameEmailV.right   == superview.right    - Config.Padding.Default
            nameEmailV.left    == superview.left     + Config.Padding.Default
            nameEmailV.height  == 68
            
            nameTF.top         == nameEmailV.top
            nameTF.right       == nameEmailV.right
            nameTF.bottom      == separatorV.top
            nameTF.left        == nameEmailV.left
            
            separatorV.right   == nameEmailV.right
            separatorV.left    == nameEmailV.left
            separatorV.centerY == nameEmailV.centerY
            separatorV.height  == 1
            
            emailTF.top        == separatorV.bottom
            emailTF.right      == nameEmailV.right
            emailTF.bottom     == nameEmailV.bottom
            emailTF.left       == nameEmailV.left
            
            bodyTV.top         == nameEmailV.bottom  + Config.Padding.Default
            bodyTV.right       == superview.right    - Config.Padding.Default
            bodyTV.left        == superview.left     + Config.Padding.Default
            
            submitB.top        == bodyTV.bottom      + Config.Padding.Default
            submitB.right      == superview.right    - Config.Padding.Default
            submitButtonBottomConstraint = (submitB.bottom == superview.bottom - Config.Padding.Default)
            submitB.height     == 34
            submitB.width      == 100
            
            cancelB.right      == submitB.left - Config.Padding.Default
            cancelB.centerY    == submitB.centerY
            cancelB.height     == submitB.height
            cancelB.width      == 100
            
            doneV.right        == superview.right
            doneV.bottom       == submitB.bottom + Config.Padding.Default
            doneV.left         == superview.left
            doneV.height       == 44
            
            doneB.right        == doneV.right - Config.Padding.Small
            doneB.height       == 34
            doneB.centerY      == doneV.centerY
            doneB.width        == 60
        }
    }
    
    func cancelButtonClicked(_ sener: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func submitButtonClicked(_ sender: UIButton) {
        guard let name = nameTextField.text else {
            return
        }
        guard let email = emailTextField.text else {
            return
        }
        guard let body = bodyTextView.text else {
            return
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        if email == "" || emailPredicate.evaluate(with: email) == false {
            let alertVC = UIAlertController(title: "Feedback", message: "Please enter a valid email id.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertVC, animated: true, completion: nil)
            return
        }
        
        if name == "" {
            let alertVC = UIAlertController(title: "Feedback", message: "Please enter your name.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertVC, animated: true, completion: nil)
            return
        }
        
        if body == "" {
            let alertVC = UIAlertController(title: "Feedback", message: "Please enter some text.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertVC, animated: true, completion: nil)
            return
        }
        
        view.endEditing(true)
        
        guard let request = JBSMURLRequest.V2.Metadata.FeedbackRequest(name: name, email: email, message: body) else {
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request as URLRequest) { (responseData, _response, responseError) -> Void in
            guard let data = responseData else {
                return
            }
            let response = _response as! HTTPURLResponse
            switch response.statusCode {
            case 200:
                performOnMainThread({ 
                    self.nameTextField.text = ""
                    self.emailTextField.text = ""
                    self.bodyTextView.text = ""
                })
            default:
                print("Failure")
            }
            
            let message = String(data: data, encoding: String.Encoding.utf8)
            
            let alertVC = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                performOnMainThread {
                    if self.navigationController?.popoverPresentationController != .none {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }))
            performOnMainThread({ 
                self.present(alertVC, animated: true, completion: nil)
            })
            
        }
        task.resume()
    }
    
    override func updateKeyboardForRect(_ rect: CGRect) {
        if navigationController?.popoverPresentationController == .none {
            submitButtonBottomConstraint?.constant = -(rect.size.height + Config.Padding.Default)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if navigationController?.popoverPresentationController == .none {
            topConstraint?.constant = -(68 + Config.Padding.Default + 40)
            doneView.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if navigationController?.popoverPresentationController == .none {
            topConstraint?.constant = 0
            doneView.isHidden = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if navigationController?.popoverPresentationController == .none {
            topConstraint?.constant = -40
            doneView.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if navigationController?.popoverPresentationController == .none {
            topConstraint?.constant = 0
            doneView.isHidden = true
        }
    }
}
