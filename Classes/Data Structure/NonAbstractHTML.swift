/*
 * Non Abstract HTML
*/

class NonAbstractHTML {
    
    private var REPLACE_CSS: String?
    private var REPLACE_COLOR: String?
    private var REPLACE_TITLE: String?
    private var REPLACE_AUTHORS: String?
    private var REPLACE_JS: String?
    private var REPLACE_OPEN_ACCESS: String?
    private var REPLACE_NO_ABSTRACT: String?

    
    var html: String = ""
    
    init?(article: Article) {
        guard loadDefaultHTML() else {
            return nil
        }
        updateWithCSS(article)
        updateWithTitle(article)
        updateWithAuthors(article)
        updateWithAbstractText(article: article)
        updateWithOpenAccess(article: article)
        updateWithColor(article: article)
    }
    
    func loadDefaultHTML() -> Bool {
        if let articleURL = Bundle.main.url(forResource: "article", withExtension: "html") {
            if let articleData = try? Data(contentsOf: articleURL) {
                if let articleString = NSString(data: articleData, encoding: String.Encoding.utf8.rawValue) {
                    self.html = articleString as String
                    return true
                }
            }
        }
        return false
    }
    
    func updateWithCSS(_ article: Article) {
        let cssPath = article.journal.basePath + "css/style.css"
        if let cssData = try? Data(contentsOf: URL(fileURLWithPath: cssPath)) {
            if let cssString = NSString(data: cssData, encoding: String.Encoding.utf8.rawValue) {
                html = html.replacingOccurrences(of: "REPLACE_CSS", with: cssString as String)
                return
            }
        }
        html = html.replacingOccurrences(of: "REPLACE_CSS", with: "")
    }
    
    func updateWithTitle(_ article: Article) {
        if let articleTitle = article.articleTitle {
            html = html.replacingOccurrences(of: "REPLACE_TITLE", with: articleTitle)
            return
        }
        html = html.replacingOccurrences(of: "REPLACE_TITLE", with: "")
    }
    
    func updateWithAuthors(_ article: Article) {
        if let articleAuthors = article.author {
            html = html.replacingOccurrences(of: "REPLACE_AUTHORS", with: articleAuthors)
            return
        }
        html = html.replacingOccurrences(of: "REPLACE_AUTHORS", with: "")
    }
    
    func updateWithAbstractText(article: Article) {
        if article.downloadInfo.abstractDownloadStatus == .notAvailable {
            html = html.replacingOccurrences(of: "REPLACE_NO_ABSTRACT", with: "This article does not have an Abstract")
        } else {
            html = html.replacingOccurrences(of: "REPLACE_NO_ABSTRACT", with: "")
        }
    }
    
    func updateWithOpenAccess(article: Article) {
        if let openAccess = article.openAccess.oaStatusDisplay {
            html = html.replacingOccurrences(of: "REPLACE_OPEN_ACCESS", with: openAccess)
            return
        }
        html = html.replacingOccurrences(of:"REPLACE_OPEN_ACCESS", with: "")
    }
    
    func updateWithColor(article: Article) {
        if let color = article.lancetArticleColor {
            html = html.replacingOccurrences(of:"REPLACE_COLOR", with: color as String)
            return
        }
        html = html.replacingOccurrences(of:"REPLACE_COLOR", with: "")
    }
}
