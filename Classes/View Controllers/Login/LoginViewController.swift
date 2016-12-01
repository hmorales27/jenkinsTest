//
//  LoginViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 2/29/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit
import Cartography


protocol MediaAuthDelegate {
    
    func mediaLoginWasClosed()
}

protocol LoginVCDelegate: class {
    func userDidCompleteLogin(_ article: Article?, issue: Issue?)
    func userDidCompleteLogin(_ info: LoginViewControllerInfo)
    func didLoginForMedia(_ media: Media, forDownload: Bool)
}


class LoginViewController: SLViewController, UITextFieldDelegate {
    
    let journal: Journal
    var partners: [Partner] = []
    
    var selectedPartner: Partner?
    
    var mediaDelegate: MediaAuthDelegate?
    
    var loginDelegate: LoginVCDelegate?
    var loginDelegateArticle: Article?
    var loginDelegateIssue: Issue?
    
    var loginInfo: LoginViewControllerInfo?
    
    let partnerHeader = UIView()
    let loginLabel = UILabel()
    
    let chooseToLabel = UILabel()
    let selectLabel = UILabel()
    
    let helperTextTitleLabel = UILabel()
    let helperTextLabel = UILabel()
    let nextButton = UIButton(type: .roundedRect)
    
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    
    let rememberMe = UISwitch()
    let rememberMeLabel = UILabel()
    
    let forgotPasswordButton = UIButton(type: .roundedRect)
    
    let submitButton = UIButton(type: .roundedRect)
    
    let chooseLoginView = UIButton(type: .custom)
    let chooseLoginArrow = UIImageView(image: UIImage(named: "Choose Login Arrow"))
    let chooseLoginLabel = UILabel()
    let chooseLoginTable = UITableView()
    
    let webView = UIWebView()
    
    var partnerViews: [UIView] = []
    var loginViews  : [UIView] = []
    
    var isDismissable = false
    
    var newSearch = true
    
    let headerLabelFontSize : CGFloat = 20.0
    
    let cellId = "choose login cell"
    
    var expanded = false

    var lastTapPoint = CGPoint(x: 0, y: 0)
    
    var choosePartnerScreenOn = true
    
    weak var chooseLoginHeightConstraing: NSLayoutConstraint?
    weak var tapWindow: TapWindow?
    
    // MARK: - Initializers -
    
    override init(journal: Journal) {
        self.journal = journal
        super.init(journal: journal)
        enabled = false
        self.partners = journal.allPartners
    }
    
    init(info: LoginViewControllerInfo) {
        journal = info.journal
        super.init(journal: journal)
        enabled = false
        self.partners = journal.allPartners
        
        self.loginInfo = info
        self.loginDelegateArticle = info.article
        self.loginDelegateIssue = info.issue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.white
        title = "Login"
        
        if partners.count == 0 {
            log.error("There are no partners for journal: \(journal.journalTitle)")
        }
        if partners.count > 0 {
            if partners.count == 1 {
                //chooseLoginHeightConstraing?.constant = 0
            }
        } else {
//            chooseLoginHeightConstraing?.constant = 0
        }
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsTagScreen()
    }

    override func closeButtonClicked(_ sender: AnyObject) {
        super.closeButtonClicked(sender)
        mediaDelegate?.mediaLoginWasClosed()
    }
    
    
    //  MARK: - Setup -
    
    override func analyticsTagScreen() {
        var contentData: [AnyHashable: Any] = [:]
        contentData[AnalyticsConstant.TagPageType] = Constants.Page.Type.ap_lp
        AnalyticsHelper.MainInstance.trackState(Constants.Page.Name.Login, stateContentData: contentData)
    }
    
    func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleKeyboard))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        setupSubviews()
        
        loginLabel.backgroundColor = UIColor.clear
        loginLabel.textColor = UIColor.white
        loginLabel.text = "Login"
        loginLabel.font = UIFont.boldSystemFont(ofSize: headerLabelFontSize)
        loginLabel.isAccessibilityElement = false
        
        chooseLoginView.setBackgroundImage(UIImage(named: "Choose Login"), for: UIControlState())
        chooseLoginArrow.image = UIImage(named: "Choose Login Arrow")
        chooseLoginView.addTarget(self, action: #selector(chooseLoginClicked(_:)), for: .touchUpInside)
        
        chooseLoginView.accessibilityLabel = "Choose your login"
        
        chooseLoginView.isUserInteractionEnabled = true
        
        chooseLoginLabel.isAccessibilityElement = false
        chooseLoginLabel.isUserInteractionEnabled = false
        

        setupEmailTextField()
        setupPasswordTextField()
        setupRememberMeSwitch()
        
        rememberMeLabel.text = "Keep me logged in"

        submitButton.setTitle("Login", for: UIControlState())
        submitButton.addTarget(self, action: #selector(submitButtonClicked(_:)), for: .touchUpInside)
        submitButton.backgroundColor = UIColor.darkGray
        submitButton.setTitleColor(UIColor.white, for: UIControlState())
        
        
        let attributes: [String: AnyObject] = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject]
        let attributedForgotPasswordText = NSMutableAttributedString(string: "Forgot Password", attributes: attributes)
        forgotPasswordButton.setAttributedTitle(attributedForgotPasswordText, for: UIControlState())
        forgotPasswordButton.addTarget(self, action: #selector(didSelectForgotPasswordButton(_:)), for: .touchUpInside)

        helperTextTitleLabel.font = AppConfiguration.DefaultBoldTitleFont
        helperTextLabel.numberOfLines = 0
        

        
        emailTextField.delegate = self
        emailTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = UIReturnKeyType.go
        
        setupChooseToLabel()
        setupSelectLabel()
        setupChooseLoginTable()
        setupNextButton()
        
        setupWebView()
        setupAutoLayout()
        setupNavigationBar()
        
        for window in UIApplication.shared.windows {
            
            if let _tapWindow = window as? TapWindow {
                
                tapWindow = _tapWindow
                break
            }
        }
        
        tapWindow?.observedView = webView
        tapWindow?.delegate = self
    }
    
    override func updateNavigationTitle() {
        super.updateNavigationTitle()

        if let journalTitle = journal.journalTitle, let titleView = navigationItem.titleView {
            titleView.accessibilityLabel = "Journal: " + journalTitle
        }
    }     

    func toggleKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func setupFirstViewSSO(_ partner: Partner) {
        
        if let _journalTitle = journal.journalTitle {
            title = "\(_journalTitle)"
        }
        partnerHeader.backgroundColor = UIColor.lightGray
        
        partnerViews = [partnerHeader, chooseToLabel, selectLabel, chooseLoginView, nextButton]
        
        for _subview in view.subviews {
            
            if partnerViews.contains(_subview) == false {
                _subview.isHidden = true
            
            } else if partnerViews.contains(_subview) == true {
                _subview.isHidden = false
            }
        }
        chooseLoginLabel.text = "Choose your login"
    }
    
    func setupChooseToLabel() {
        
        chooseToLabel.numberOfLines = 0
        chooseToLabel.text = "Choose an Account to Login"
        chooseToLabel.font = UIFont.boldSystemFont(ofSize: headerLabelFontSize)
    }
    
    func setupSelectLabel() {
        
        selectLabel.numberOfLines = 0
        selectLabel.text = Strings.Login.SelectLabelText
        selectLabel.font = UIFont.systemFont(ofSize: 17)
    }
    
    func setupChooseLoginTable() {
        
        chooseLoginTable.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        chooseLoginTable.delegate = self
        chooseLoginTable.dataSource = self
        chooseLoginTable.layer.borderColor = UIColor.black.cgColor
        chooseLoginTable.layer.borderWidth = 1
    }
    
    func setupNextButton() {
        
        nextButton.setTitleColor(.white, for: UIControlState())
        nextButton.backgroundColor = .darkGray
        nextButton.setTitle("Next", for: UIControlState())
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        nextButton.addTarget(self, action: #selector(nextButtonWasClicked(_:)), for: .touchUpInside)
    }
    
    func setupWebView() {
        view.addSubview(webView)
        webView.backgroundColor = UIColor.white
        webView.delegate = self
    }
    
    func setupEmailTextField() {
        view.addSubview(emailTextField)
        emailTextField.placeholder = "Username or Email"
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.none
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = UIKeyboardType.emailAddress
    }
    
    func setupPasswordTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
    }
    
    func setupRememberMeSwitch() {
        
        rememberMe.accessibilityLabel = rememberMe.isOn ? "keep me logged in switch, switched on" : "keep me logged in switch, switched off"
        rememberMe.addTarget(self, action: #selector(rememberMeSwitchChanged(_:)), for: UIControlEvents.valueChanged)
    }
    
    func setupAutoLayout() {
        let subviews = [
            emailTextField,
            passwordTextField,
            rememberMe,
            rememberMeLabel,
            forgotPasswordButton,
            submitButton,
            
            webView,
            helperTextTitleLabel,
            helperTextLabel,
            
            partnerHeader,
            loginLabel,
            chooseToLabel,
            selectLabel,
            
            chooseLoginView,
            chooseLoginArrow,
            chooseLoginLabel,
            chooseLoginTable,
            nextButton
        ]
        constrain(subviews) { (views) in
            let emailTF = views[0]
            let passwordTF = views[1]
            let rememberMeS = views[2]
            let rememberMeL = views[3]
            let forgotPasswordB = views[4]
            let submitB = views[5]
            let webV = views[6]
            let helpterTextTitleL = views[7]
            let helperTextL = views[8]
            
            let partnerH = views[9]
            
            let loginL = views[10]
            
            let chooseToL = views[11]
            let selectL = views[12]
            
            let chooseLoginV = views[13]
            let chooseLoginA = views[14]
            let chooseLoginL = views[15]
            let chooseLoginT = views[16]
            
            let nextB = views[17]
            
            guard let superview = emailTF.superview else {
                return
            }
            
            partnerH.top == superview.top
            partnerH.left == superview.left
            partnerH.right == superview.right
            partnerH.height == 45
            
            loginL.left == superview.left + Config.Padding.Double
            loginL.centerY == partnerH.centerY
            
            chooseToL.top == partnerH.bottom + Config.Padding.Default
            chooseToL.right == superview.right - Config.Padding.Default
            chooseToL.left == superview.left + Config.Padding.Double
            
            selectL.top == chooseToL.bottom + Config.Padding.Default
            selectL.right == superview.right -  Config.Padding.Default
            selectL.left == superview.left + Config.Padding.Double
            
            chooseLoginL.top == chooseLoginV.top
            chooseLoginL.right == chooseLoginA.left - Config.Padding.Default
            chooseLoginL.bottom == chooseLoginV.bottom
            chooseLoginL.left == chooseLoginV.left + Config.Padding.Default
            
            chooseLoginA.top == chooseLoginV.top
            chooseLoginA.right == chooseLoginV.right
            chooseLoginA.bottom == chooseLoginV.bottom
            chooseLoginA.width == 40
            
            helpterTextTitleL.top == partnerH.bottom + Config.Padding.Default
            helpterTextTitleL.right == superview.right - Config.Padding.Default
            helpterTextTitleL.left == superview.left + Config.Padding.Default
            
            helperTextL.top == helpterTextTitleL.bottom + Config.Padding.Default
            helperTextL.right == superview.right - Config.Padding.Default
            helperTextL.left == superview.left + Config.Padding.Default
            
            chooseLoginV.top == selectL.bottom + Config.Padding.Default
            chooseLoginV.right == superview.right - Config.Padding.Default
            chooseLoginV.left == superview.left + Config.Padding.Default
            chooseLoginHeightConstraing = (chooseLoginV.height == 40)
            
            chooseLoginT.top == chooseLoginV.bottom
            chooseLoginT.right == chooseLoginV.right
            chooseLoginT.left == chooseLoginV.left
            chooseLoginT.height == 180
            
            nextB.right == superview.right - Config.Padding.Default
            nextB.width == 76
            nextB.height == 34
            nextB.top == chooseLoginV.bottom + Config.Padding.Double
            
            emailTF.top == helperTextL.bottom + Config.Padding.Default
            emailTF.right == superview.right - Config.Padding.Default
            emailTF.left == superview.left + Config.Padding.Default
            
            passwordTF.top == emailTF.bottom + Config.Padding.Default
            passwordTF.right == superview.right - Config.Padding.Default
            passwordTF.left == superview.left + Config.Padding.Default
            
            rememberMeS.top == passwordTF.bottom + Config.Padding.Default
            rememberMeS.left == superview.left + Config.Padding.Default
            
            rememberMeL.left == rememberMeS.right + Config.Padding.Default
            rememberMeL.centerY == rememberMeS.centerY
            
            forgotPasswordB.left == superview.left + Config.Padding.Default
            forgotPasswordB.top == rememberMeS.bottom + Config.Padding.Default
            
            submitB.top == passwordTF.bottom + Config.Padding.Default
            submitB.right == superview.right - Config.Padding.Default
            submitB.width == 76
            submitB.height == 34
            
            webV.top == forgotPasswordB.bottom + Config.Padding.Default
            webV.right == superview.right - Config.Padding.Default
            webV.bottom == superview.bottom - Config.Padding.Default
            webV.left == superview.left + Config.Padding.Default
        }
    }
    
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        updateNavigationTitle()
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.leftBarButtonItem = isDismissable ? closeBarButtonItem : menuBarButtonItem
    }
    
    override var screenTitle: String {
        get {
            return screenTitleJournal
        }
    }

    
    func update() {
        if partners.count > 0 {
            let partner = partners[0]
            
            if selectedPartner == nil {
                setupFirstViewSSO(partner)
            
            } else if selectedPartner != nil {
                
                if isDismissable == true {
                    updateForPartner(partner)
                    emailTextField.becomeFirstResponder()
                }
            }
            
            if partners.count == 1 {
                selectedPartner = partner
                updateForPartner(partner)
                showLoginViews()
                emailTextField.becomeFirstResponder()
            }
        }
    }
    
    
    //  MARK: - User Actions -
    
    func rememberMeSwitchChanged(_ sender: UISwitch) {
        sender.accessibilityLabel = sender.isOn ? "keep me logged in switch, switched on" :
                                                "keep me logged in switch, switched off"
    }
    
    
    func chooseLoginClicked(_ sender: UIView){
        
        expanded = !expanded
        
        nextButton.isAccessibilityElement = !expanded
        dropdownWasExpanded(expanded)
        chooseLoginTable.becomeFirstResponder()
    }
    
    
    func dropdownWasExpanded(_ _expanded: Bool) {
        
        var indexPaths: [IndexPath] = []
        
        for i in 0...partners.count - 1 {
            
            let indexPath = IndexPath(row: i, section: 0)
            indexPaths.append(indexPath)
        }
        
        performOnMainThread {
            self.chooseLoginTable.beginUpdates()
            
            var interval = 0.0
            
            if self.expanded == true {
                
                interval = 0.1
                self.chooseLoginTable.insertRows(at: indexPaths, with: .fade)
                
            } else if self.expanded == false {
                
                interval = 0.3
                self.chooseLoginTable.deleteRows(at: indexPaths, with: .fade)
            }
            Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(LoginViewController.showOrHideTable), userInfo: nil, repeats: false)
            
            self.chooseLoginTable.endUpdates()
        }
    }
    
    
    
    func showOrHideTable() {
        chooseLoginTable.isHidden = !chooseLoginTable.isHidden
    }

    
    func updateForPartner(_ partner: Partner) {
        
        helperTextTitleLabel.numberOfLines = 0
        helperTextTitleLabel.text = "Login Using Your \(partner.partnerName!) Credentials"
        helperTextLabel.text = "Enter the credentials that you use to access full-text content on the \(partner.partnerName!) website. These are case-sensitive."
        if let helpText = partner.helpText {
            selectedPartner = partner
            webView.loadHTMLString(helpText, baseURL: nil)
        }
        chooseLoginLabel.text = partner.partnerName
        
        if let partnerName = partner.partnerName {
            chooseLoginView.accessibilityLabel = partnerName + " selected. Double-tap to change it."
        }
    }
    
    
    func showLoginViews() {
        
        loginViews = [helperTextTitleLabel, helperTextLabel, emailTextField, passwordTextField, rememberMeLabel, rememberMe, forgotPasswordButton, submitButton, webView
        ]
        
        performOnMainThread { 
            for partnerView in self.partnerViews {
                if partnerView != self.partnerHeader {

                    partnerView.isHidden = true
                }
            }
            for loginView in self.loginViews {
                
                loginView.isHidden = false
            }
            
        }
    }
    
    
    func setupSubviews() {
        view.addSubview(rememberMe)
        view.addSubview(rememberMeLabel)
        
        view.addSubview(submitButton)
        view.addSubview(forgotPasswordButton)
        
        view.addSubview(helperTextTitleLabel)
        view.addSubview(helperTextLabel)
        
        view.addSubview(partnerHeader)
        partnerHeader.addSubview(loginLabel)
        
        view.addSubview(chooseToLabel)
        view.addSubview(selectLabel)
        
        view.addSubview(chooseLoginView)
        chooseLoginView.addSubview(chooseLoginLabel)
        chooseLoginView.addSubview(chooseLoginArrow)
        
        view.addSubview(nextButton)
        view.addSubview(chooseLoginTable)
    }
    
    func nextButtonWasClicked(_ sender: UIButton) {

        for partner in partners {
            guard let partnerName = partner.partnerName, let selected = chooseLoginLabel.text else {
                break
            }
            
            if partnerName == selected {
              showLoginViews()
                performOnMainThread({ 
                    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.helperTextTitleLabel)
                })
              break
                
            } else if partner == partners.last {
                let alert = Alerts.chooseLogin()
                performOnMainThread({ 
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    
    func submitButtonClicked(_ sender: UIButton) {
        guard let partner = selectedPartner else {
            return
        }
        guard let userName = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        
        if userName == "" {
            let alertVC = UIAlertController(title: "Invalid Username", message: "Please provide the valid Username.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
            return
        }
        
        if password == "" {
            let alertVC = UIAlertController(title: "Invalid Password", message: "Please provide the valid Password.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
            return
        }
        
        DispatchQueue.main.async { () -> Void in
            self.emailTextField.resignFirstResponder()
            self.passwordTextField.resignFirstResponder()
            self.view.resignFirstResponder()
        }
        let alertVC = UIAlertController(title: "Please Wait", message: "Authenticating", preferredStyle: .alert)
        present(alertVC, animated: true, completion: nil)
        
        AuthenticationManager.sharedInstance.login(partner, journal: journal, userName: userName, password: password, rememberMe: true, authentication:
            { (success) in
                guard success == true else {
                    performOnMainThread({
                        alertVC.dismiss(animated: true, completion: {
                            performOnMainThread({ 
                                self.showFailureAlert()
                            })
                        })
                    })
                    return
                }
            }) { (success) in
                
                guard success else {
                    performOnMainThread({
                        alertVC.dismiss(animated: true, completion: nil)
                        self.showFailureAlert()
                    })
                    return
                }
                
                performOnMainThread({
                    alertVC.message = nil
                    alertVC.title = "Login Successful"
                })
                
                AnalyticsHelper.MainInstance.updateLoginInDefaultConfiguration("login", uniqueUserId: String(NSString(string: userName).aes256Encrypt(withKey: Strings.EncryptionKey)))
                AnalyticsHelper.MainInstance.analyticsTagAction(AnalyticsHelper.ContentAction.loginSuccess, additionalInfo: "")
                
                performOnMainThreadAfter(seconds: 1, tasks: {
                    
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.Authentication.Login), object: nil)
                    
                    alertVC.dismiss(animated: true, completion: {
                        performOnMainThread({
                            self.dismiss(animated: true, completion: {
                                if let info = self.loginInfo {
                                    if let media = info.media, let forDownload = info.forMediaDownload {
                                        self.loginDelegate?.didLoginForMedia(media, forDownload: forDownload)
                                    } else {
                                        self.loginDelegate?.userDidCompleteLogin(info)
                                    }
                                } else {
                                    self.loginDelegate?.userDidCompleteLogin(self.loginDelegateArticle, issue: self.loginDelegateIssue)
                                }
                            })
                        })
                    })
                })
        }
    }
    

    func didSelectForgotPasswordButton(_ sender: UIButton) {
        if partners.count > 0 {
            let partner = partners[0]
            let forgotPasswordVC = ForgotPasswordViewController(partnerId: "\(partner.partnerId!)")
            navigationController?.pushViewController(forgotPasswordVC, animated: true)
        }
    }
    
    
    //  MARK: - Alerts -
    
    func showSuccessAlert() {
        DispatchQueue.main.async { () -> Void in
            let alertVC = UIAlertController(title: "Login Successful", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.dismiss(animated: true, completion:nil)
                })
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func showFailureAlert() {
        DispatchQueue.main.async { () -> Void in
            let alertVC = UIAlertController(title: "Access Denied!", message: "Invalid username and password combination. Try again.", preferredStyle: UIAlertControllerStyle.alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in

            }))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
            return false
        } else if textField === passwordTextField {
            passwordTextField.resignFirstResponder()
            submitButtonClicked(submitButton)
            return true
        }
        return true
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if emailTextField.isFirstResponder || passwordTextField.isFirstResponder {
            return true
        } else {
            return false
        }
    }
    
}

extension LoginViewController: UIWebViewDelegate, UIPopoverPresentationControllerDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url {
            if url.isTelephoneNumber {
                let telpromptString = url.absoluteString.replacingOccurrences(of: "tel", with: "telprompt")
                guard let telpromptURL = URL(string: telpromptString) else { return false }

                if UIApplication.shared.canOpenURL(telpromptURL) {
                    
                    switch self.screenType {
                    case .mobile:
                        UIApplication.shared.openURL(telpromptURL)
                    case .tablet:
                        
                        break
                    }
                }
                return false
            }
        }
        return true
    }
}


extension LoginViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if partners.count > (indexPath as NSIndexPath).row {
            let partnerName = partners[(indexPath as NSIndexPath).row].partnerName

            cell?.textLabel?.text = partnerName
            cell?.accessibilityLabel = partnerName
            
            cell?.contentView.backgroundColor = .groupTableViewBackground
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let partner = partners[(indexPath as NSIndexPath).row]
        self.updateForPartner(partner)
        expanded = false
        dropdownWasExpanded(expanded)
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nextButton)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expanded == false ? 0 : partners.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}



extension LoginViewController: TapWindowDelegate {
    
    
    func userTappedView(_ touch: AnyObject) {}
}
