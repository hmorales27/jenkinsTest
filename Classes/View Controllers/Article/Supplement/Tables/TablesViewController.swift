/*
 * TablesViewController
 */

import UIKit
import Cartography
import MessageUI
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TablesViewController: JBSMViewController, UIWebViewDelegate {
    
    let webView = UIWebView()
    
    var tables: [Media]
    var article: Article? {
        if tables.count > 0 {
            return tables[0].article
        }
        return nil
    }
    
    var html = ""
    
    init(tables: [Media]) {
        
        self.tables = tables.sorted(by: {
            $0.sequence.intValue < $1.sequence.intValue
        })
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        update()
    }
    
    func setup() {
        setupNavigationBar()
        setupSubviews()
        setupAutoLayout()
        setupWebView()
        setupHTML()
    }
    
    func setupSubviews() {
        view.addSubview(webView)
    }
    
    func setupAutoLayout() {
        constrain(webView) { (webView) in
            guard let superview = webView.superview else {
                return
            }
            
            webView.top == superview.top
            webView.right == superview.right
            webView.bottom == superview.bottom
            webView.left == superview.left
        }
    }
    
    func setupWebView() {
        webView.backgroundColor = UIColor.white
        webView.delegate = self
    }
    
    func setupHTML() {
        self.html = createTableHTML()
    }
    
    func createTableHTML() -> String {
        var html = ""
        for table in tables {
            do {
                let _html = try String(contentsOfFile: table.pathString)
                html += _html
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
        }
        return html
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        title = "Tables"
        
        navigationItem.leftBarButtonItem = closeBarButtonItem

        let mailBarButtonItem = UIBarButtonItem(image: UIImage(named: "MailIcon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(mailBarButtonItemClicked(sender:)))
        if !MFMailComposeViewController.canSendMail() {
            mailBarButtonItem.isEnabled = false
        }

        mailBarButtonItem.accessibilityLabel = "Email tables"
        navigationItem.rightBarButtonItem = mailBarButtonItem
    }

    func mailBarButtonItemClicked(sender: UIBarButtonItem) {
        
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        guard let article = self.article else {
            return
        }
        
        let mailVC = MFMailComposeViewController()
        mailVC.setSubject("Recommended table from \(article.journal.journalTitle)")
        mailVC.setMessageBody(article.emailBody, isHTML: true)
        mailVC.mailComposeDelegate = self
        
        let _html = makeTableAttatchmentHTML()
        if let data = _html.data(using: String.Encoding.utf8) {
            mailVC.addAttachmentData(data, mimeType: "text/html", fileName: "tables.html")
        }
        
        self.present(mailVC, animated: true, completion: nil)
    }
    
    func makeTableAttatchmentHTML() -> String {
        var content = createTableHTML()
        
        let srr = content.components(separatedBy: "img>")
        for imgString in srr {
            
            var src: NSString?
            
            let theScanner = Scanner(string: imgString)
            
            theScanner.scanUpTo("<img", into: nil)
            
            if !theScanner.isAtEnd {
                theScanner.scanUpTo("src", into: nil)
                let charSet = CharacterSet(charactersIn: "\"'")
                theScanner.scanUpToCharacters(from: charSet, into: nil)
                theScanner.scanCharacters(from: charSet, into: nil)
                theScanner.scanUpToCharacters(from: charSet, into: &src)
            }
            
            if src?.length > 0 {
                src = src?.replacingOccurrences(of: "image/", with: "") as NSString?
                let htmlFilePath: String = article!.fulltextImagePath + (src! as String)
                let htmlData = try? Data(contentsOf: URL(fileURLWithPath: htmlFilePath))
                let imageStr = htmlData!.base64EncodedString(options: .lineLength64Characters)
                content = content.replacingOccurrences(of: "image/\(src!)", with: "data:image/gif;base64,\(imageStr)")
            }
        }
        
        let cssFilePath = article!.journal.basePath + "css/style.css"
        do {
            let cssContent = try String(contentsOfFile: cssFilePath, encoding: String.Encoding.utf8)
            let defaultCSS = ".ja50-ce-textbox-title {font-family: Helvetica;font-size: 16pt;background-color: #DDE8F4;cursor: pointer; cursor: hand;}html.isJS .ja50-ce-textbox-body{margin-top: -25px;display: none;}</style>"
            content = content.replacingOccurrences(of: defaultCSS, with: "\(cssContent)</style>")
            content = content.replacingOccurrences(of: "<link rel=\"stylesheet\" href=\"../../css/style.css\" type=\"text/css\">", with: "<style>\(cssContent)</style>")
            content = content.replacingOccurrences(of: "tblbor2", with: "tblbor")
            
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
        
        return content
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let jsPath = Bundle.main.path(forResource: "stylescript", ofType: "js")!
        do {
            var jsString = try NSString(contentsOfFile: jsPath, encoding: String.Encoding.utf8.rawValue)
           
            jsString = jsString.appending("showTableCSS();") as NSString
            jsString = jsString.appending("hideAnchorlinks()") as NSString
            
            webView.stringByEvaluatingJavaScript(from: jsString as String)
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    // MARK: - Update -
    
    func update() {
        if let article = self.article {
            webView.loadHTMLString(html, baseURL: URL(string: article.fulltextHTMLPath))
        } else {
            webView.loadHTMLString(html, baseURL: nil)
        }
        
    }
    
}
