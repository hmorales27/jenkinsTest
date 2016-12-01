//
//  ForgotPasswordViewController.swift
//  JBSM-iOS
//
//  Created by Sharkey, Justin (ELS-CON) on 4/25/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography

class ForgotPasswordViewController: JBSMViewController {
    
    let textLabel = UILabel()
    let emailTextField = UITextField()
    let submitButton = UIButton(type: .custom)
    
    let partnerId: String
    
    init(partnerId: String) {
        self.partnerId = partnerId
        super.init(nibName: nil, bundle: nil)
        textLabel.text = "Please enter your email address below and you will recieve an email momentarily with information on how to reset your password."
        emailTextField.placeholder = "Email"
        emailTextField.accessibilityLabel = "Please enter your email id in this field."
        
        emailTextField.becomeFirstResponder()
        submitButton.setTitle("Submit", for: UIControlState())
        submitButton.addTarget(self, action: #selector(didSelectSubmitButton(_:)), for: .touchUpInside)
        title = "Forgot Password"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        analyticsScreenName = Constants.Page.Name.ForgotPassword
        analyticsScreenType = Constants.Page.Type.ap_lp
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        view.backgroundColor = UIColor.white
        setupSubviews()
        setupAutoLayout()
        
        textLabel.numberOfLines = 0
        
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.becomeFirstResponder()
        emailTextField.keyboardType = .emailAddress
        
        submitButton.setTitle("Submit", for: UIControlState())
        submitButton.backgroundColor = UIColor.darkGray
        submitButton.setTitleColor(UIColor.white, for: UIControlState())
        submitButton.addTarget(self, action: #selector(submitButtonClicked(_:)), for: .touchUpInside)
    }
    
    func submitButtonClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else {
            return
        }
        if email == "" {
            // Show Alert
            return
        }
        
        guard let request = JBSMURLRequest.V2.Login.ForgotPassword(partnerId: partnerId, email: email) else {
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (responseData, response, responseError) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            if httpResponse.statusCode == 200 {
                performOnMainThread({
                    let alertVC = UIAlertController(title: "Message", message: "Password reset successfully", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        performOnMainThread({
                            self.dismiss(animated: true, completion: nil)
                        })
                    }))
                    self.present(alertVC, animated: true, completion: nil)
                })
            } else {
                performOnMainThread({
                    let alertVC = UIAlertController(title: "Message", message: "The username that was provided does not exist.", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        performOnMainThread({
                            self.dismiss(animated: true, completion: nil)
                        })
                    }))
                    self.present(alertVC, animated: true, completion: nil)
                })
            }
        }) 
        task.resume()
    }
    
    func setupSubviews() {
        view.addSubview(textLabel)
        view.addSubview(emailTextField)
        view.addSubview(submitButton)
    }
    
    func setupAutoLayout() {
        let subviews = [
            textLabel,
            emailTextField,
            submitButton
        ]
        constrain(subviews) { (views) in
            
            let textL = views[0]
            let emailTF = views[1]
            let submitB = views[2]
            
            guard let superview = textL.superview else {
                return
            }
            
            textL.top   == superview.top + Config.Padding.Default
            textL.right == superview.right - Config.Padding.Default
            textL.left  == superview.left + Config.Padding.Default
            
            emailTF.top == textL.bottom + Config.Padding.Default
            emailTF.right == superview.right - Config.Padding.Default
            emailTF.left == superview.left + Config.Padding.Default
            
            submitB.top == emailTF.bottom + Config.Padding.Default
            submitB.right == superview.right - Config.Padding.Default
            submitB.width == 100
            submitB.height == 44
        }
        
    }
    
    func didSelectSubmitButton(_ sender: UIButton) {
        
    }
    
}
