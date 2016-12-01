/*
 * CKEnvironment
 * Strings
*/

enum CKEnvironment {
    case development
    case certification
    case staging
    case production
}

open class Strings {
    
    static var Environment = CKEnvironment.development
    
    static var AppShortCode = ""
    static let ConsumerId = "jb/9/kPFYAuvT4EYFow2Zw=="
    static let CIConsumerID = "BiqGJphZNDF47f2JTff8oUjL4YyljQey9wm9QKNPQPs="
    static let EncryptionKey = "kEyLI1Fy648tzWXGuRcxrg=="
    
    static let NewConsumerId = "IgOnPIr93hBynFmIe6EN0g=="
    static let NewEncryptionKey = "Bl3o42uhjoL9FrkXZMQe4Q=="
    
    static let ContentServiceConsumerId = "BiqGJphZNDF47f2JTff8oUjL4YyljQey9wm9QKNPQPs="
    
    static var CurrentIPAddress: String?
    
    static var IsLancet = false
    static let IsTestAds = true
    
    static let BackgroundDownload = true
    static let downloadLogsOn = false
    
    static var SUPPORT_HTML: String {
        var envString = ""
        switch Strings.Environment {
        case .production:
            envString = "Production"
        case .certification:
            envString = "Certification"
        case .development:
            envString = "Development"
        default:
            envString = "Unknown"
        }

        if let publisher = DatabaseManager.SharedInstance.getAppPublisher() {
            if let toc = publisher.support {
                return "\(toc) <p> Build Version: \(BUILD_VERSION) <br /> Environment: \(envString) <br /> Build Time: \(COMPILE_TIMESTAMP) </p>"
            }
        }
        return ""
    }
    
    // MARK: - Content -
    
    public struct UserDefaults {
        static let LiscensesUpdateDate = "\(Bundle.main.bundleIdentifier!).UserDefaults.LiscensesUpdateDate"
        static let AuthToken = "\(Bundle.main.bundleIdentifier!).UserDefaults.AuthToken"
        static let Usage1G = "\(Bundle.main.bundleIdentifier!).Usage1G"
        static let Usage5G = "\(Bundle.main.bundleIdentifier!).Usage5G"
    }
    
    public struct Content {
        
        fileprivate static let Development = "https://content-dev.elsevier-jbs.com"
        fileprivate static let Certification = "https://content-cert.elsevier-jbs.com" // Not Operational
        fileprivate static let Staging = "https://content-staging.elsevier-jbs.com"
        fileprivate static let Production = "https://content.elsevier-jbs.com" // Not Operational
        
        fileprivate struct Additions {
            
            fileprivate static let IPAddress = "/whatismyip"
            fileprivate static let AppImages = "/appimages"
            fileprivate static let Theme = "/themes"
            fileprivate static let Redirect = "/content/redirect"
            fileprivate static let CoverImage = "/content/cover/image/redirect"
            
            fileprivate struct Media {
                fileprivate static let Download = "/content/file/download/redirect"
                fileprivate static let Stream = "/content/file/stream/redirect"
            }
        }
        
        fileprivate static var URL: String {
            switch Strings.Environment {
            case .development:
                return Content.Development
            case .certification:
                return Content.Certification
            case .staging:
                return Content.Staging
            case .production:
                return Content.Production
            }
        }
        
        static let Redirect = Content.URL + Additions.Redirect
        static let FileDownload = Content.URL + Additions.Media.Download
        static let FileStream = Content.URL + Additions.Media.Stream
        static let Theme = Content.Production + Additions.Theme
        static let CoverImage = Content.URL + Additions.CoverImage

        public static func AppImages(_ lastModified: String?) -> String {
            var appImagesPath = Content.URL + Content.Additions.AppImages
            if let date = lastModified {
                appImagesPath += "lastmodified=\(date)"
            }
            return appImagesPath
        }
        
        
    }
    
    //  MARK: - JSON Keys -
    
    public struct Json {
        static let oldKeys = [
            "AIP_Identifier",           //   0
            "article_id",               //   1
            "article_info_id",          //   2
            "article_sub_type",         //   3
            "article_sub_type_2",       //   4
            "article_sub_type_3",       //   5
            "article_sub_type_4",       //   6
            "article_title",            //   7
            "article_type",             //   8
            "authors",                  //   9
            
            "citation_text",            //   10
            "copyright",                //   11
            "date_of_release",          //   12
            "doctopic_role",            //   13
            "DOI",                      //   14
            "DOI_Link",                 //   15
            "issue_id",                 //   16
            "Issue_PII",                //   17
            "keywords",                 //   18
            "lancet_article_color",     //   19
            
            "lancet_article_type",      //   20
            "lancet_group_sequence",    //   21
            "last_modified",            //   22
            "page_range",               //   23
            "Sequence",                 //   24
            "v40",                      //   25
            "version",                  //   26
            "Video",                    //   27
            "has_video",                //   28
            "has_audio",                //   29
            
            "has_image",                //   30
            "has_others",               //   31
            "has_abstract_image",       //   32
            "isArticleInPress",         //   33
            "is_cme"                    //   34
        ]
        
        
        static let newKeys =  [
            "aipIdentifier",            //  0
            "articleId",                //  1
            "articlePii",               //  2
            "articleSubType",           //  3
            "articleSubType2",          //  4
            "articleSubType3",          //  5
            "articleSubType4",          //  6
            "articleTitle",             //  7
            "articleType",              //  8
            "authors",                  //  9
            
            "citationText",             //  10
            "copyright",                //  11
            "dateOfRelease",            //  12
            "docTopicRole",             //  13
            "doi",                      //  14
            "doiLink",                  //  15
            "issueId",                  //  16
            "issuePii",                 //  17
            "keywords",                 //  18
            "lancetArticleColor",       //  19
            
            "lancetArticleType",        //  20
            "lancetGroupSequence",      //  21
            "lastModified",             //  22
            "pageRange",                //  23
            "sequence",                 //  24
            "v40",                      //  25
            "version",                  //  26
            "Video",                    //  27
            "hasVideo",                 //  28
            "hasAudio",                 //  29
            
            "hasImage",                 //  30
            "hasOthers",                //  31
            "hasAbstractImage",         //  32
            "isAip",                    //  33
            "isCme"                     //  34
        ]
    }

    
    struct Feedback {
        private static let Addition = "/ae/feedback/email"
        
        static var URL: String {
            return Authentication.BaseURL + Feedback.Addition
        }
    }
    
    // MARK: - Content Innovation -
    
    struct ContentInnovation {
        
        fileprivate static let Development = "https://ci-dev.elsevier-jbs.com/ci/v1/widget/list"
        fileprivate static let Certification = "https://ci-cert.elsevier-jbs.com/ci/v1/widget/list"
        fileprivate static let Staging = "https://ci.elsevier-jbs.com/ci/v1/widget/list"
        fileprivate static let Production = "https://ci.elsevier-jbs.com/ci/v1/widget/list"
        
        static var URL: String = {
            switch Strings.Environment {
            case .development:
                return ContentInnovation.Development
            case .certification:
                return ContentInnovation.Certification
            case .staging:
                return ContentInnovation.Staging
            case .production:
                return ContentInnovation.Production
            }
        }()
    }
    
    // MARK: - API -
    
    struct API {
        
        fileprivate static let Development = "http://dev-www.elsevier-jbsm.com/webservice5.5/index.php"
        fileprivate static let Certification = "http://cert-www.elsevier-jbsm.com/webservice5.5/index.php"
        fileprivate static let Staging = "http://cert-www.elsevier-jbsm.com/webservice5.5/index.php"
        fileprivate static let Production = "http://www.elsevier-jbsm.com/webservice5.5/index.php" // 52.87.27.45
        
        struct Additions {
            
        }
        
        static var URL: String = {
            switch Strings.Environment {
            case .development:
                return API.Development
            case .certification:
                return API.Certification
            case .staging:
                return API.Staging
            case .production:
                return API.Production
            }
        }()
        
        struct DateKeys {
            static let Issues = "strings.api.datekeys.issues"
        }
    }
    
    // MARK: - Open Access -
    
    struct OpenAccess {
        static let URL = "http://www.elsevier-jbsm.com/webservice5.5/index.php/oa/index"
        static let HTMLURL = "http://www.elsevier-jbsm.com/webservice5.5/index.php/oa/content"
        static let LiscensesURL = "http://www.elsevier-jbsm.com/webservice5.5/index.php/info/index"
    }
    
    // MARK: - IP Auth -
    
    struct Authentication {

        static let Development = "https://ae-cert.elsevier-jbs.com"
        static let Certification = "https://ae-cert.elsevier-jbs.com"
        static let Production = "https://ae.elsevier-jbs.com"
        static var BaseURL: String {
            switch Strings.Environment {
            case .production:
                return Production
            case .certification:
                return Certification
            default:
                return Development
            }
        }
        
        static let IPAuthAddition = "/ae/auth/st/ip"
        static let IPAutzAddition = "/ae/autz/st/product"
        static let IPUsageAddition  = "/ae/autz/st/usage/logging/pii/"
        
        private static let LoginPartnersAddition = "/ae/partner/list"
        private static let LoginAuthAddition = "/ae/auth/user/"
        private static let LoginAutzAddition = "/ae/autz/product/"
        
        private static let LoginForgotPasswordLancet = "/ae/auth/tl/forgotpwd"
        private static let LoginForgotPassword = "/ae/auth/forgotpwd/"
        
        static var IPAuthURL: String {
            return BaseURL + IPAuthAddition
        }
        
        static var IPAutzURL: String {
            return BaseURL + IPAutzAddition
        }
        
        static var IPUsageURL: String {
            return BaseURL + IPUsageAddition
        }
        
        static var LoginPartnerURL: String {
            return BaseURL + LoginPartnersAddition
        }
        
        static var LoginAuthURL: String {
            return BaseURL + LoginAuthAddition
        }
        
        static var LoginAutzURL: String {
            return BaseURL + LoginAutzAddition
        }
        
        static var ForgotPasswordURL: String {
            return BaseURL + LoginForgotPassword
        }
        
        static var ForgotPasswordLancetURL: String {
            return BaseURL + LoginForgotPasswordLancet
        }
        
    }
    
    
    
    static fileprivate let BaseURLDevelopment       = "http://dev-www.elsevier-jbsm.com/webservice5.5/index.php"
    static fileprivate let BaseURLCertification     = "http://cert-www.elsevier-jbsm.com/webservice5.5/index.php"
    static fileprivate let BaseURLStaging           = "http://cert-www.elsevier-jbsm.com/webservice5.5/index.php"
    static fileprivate let BaseURLProduction        = "http://www.elsevier-jbsm.com/webservice5.5/index.php"
    
    static fileprivate let BaseAppId                = "/app2"
    
    fileprivate static let BaseIndexAddition        = "/index"
    fileprivate static let BaseThemeAddition        = "/theme"
    fileprivate static let BaseIPAddressAddition    = "/oa/ipaddress"
    fileprivate static let BaseAnnouncementAddition = "/announcement"
    fileprivate static let MailAddition             = "/index?mail"
    
    static let RedirectURL = "https://ci-dev.elsevier-jbs.com/app/redirect"
    static let FileRedirectURL = "https://ci-dev.elsevier-jbs.com/app/content/file/redirect"
    
    static fileprivate let LoginAPIURLCertification = "https://cert.services.healthadvance.com/JournalServices"
    static fileprivate let LoginAPIURLProduction = "https://services.healthadvance.com/JournalServices"
    
    static fileprivate let IPAuthentication = "/v1/auth/input/ip"
    static fileprivate let IPAuthorization = "/v1/autz/st/product"
    static fileprivate let IPUsage = "/v1/autz/st/usage/logging/pii/"
    static fileprivate let PartnerList = "/v2/retrieve/partnerlist"
    static fileprivate let LoginAuth = "/v1/auth/user/"
    
    static fileprivate let LoginAutzProduct = "/v1/autz/product/"
    
    static var BaseUrl: String = {
        switch Strings.Environment {
        case .development:
            return Strings.BaseURLDevelopment + Strings.BaseAppId
        case .certification:
            return Strings.BaseURLCertification + Strings.BaseAppId
        case .staging:
            return Strings.BaseURLStaging + Strings.BaseAppId
        case .production:
            return Strings.BaseURLProduction + Strings.BaseAppId
        }
    }()
    
    static var BaseURLWithoutAppId: String {
        switch Strings.Environment {
        case .development:
            return Strings.BaseURLDevelopment
        case .certification:
            return Strings.BaseURLCertification
        case .staging:
            return Strings.BaseURLStaging
        case .production:
            return Strings.BaseURLProduction
        }
    }
    
    static var LoginURL: String {
        switch Strings.Environment {
        case .production:
            return Strings.LoginAPIURLProduction
        default:
            return Strings.LoginAPIURLCertification
        }
    }
    
    static var BaseIndexURL: String {
        return Strings.BaseUrl + Strings.BaseIndexAddition
    }
    
    static var BaseThemeURL: String {
        return Strings.BaseUrl + Strings.BaseThemeAddition
    }
    
    static var BaseAnnouncementURL: String {
        return Strings.BaseUrl + Strings.BaseAnnouncementAddition
    }
    
    static var MailURL: String {
        return Strings.BaseUrl + Strings.MailAddition
    }
    
    static var IPAddressURL: String {
        return Strings.BaseURLWithoutAppId + Strings.BaseIPAddressAddition
    }
    
    // MARK: - TextSize -
    
    struct TextSize {
        static let UserDefaultsKey = "strings.textsize.userdefaultskey"
    }
    
    // MARK: - Alerts -
    
    struct Alerts {
        static let NoAbstractTitle = "Please Download This Issue."
        static let NoAbstractMessage = "This article does not have an abstract to display. Please download the issue to read the article."
        
        struct Authentication {
            static let Title = "Issue Access Options"
            static let Message = "Please choose an option below to view the issue"
            static let Member = "I am an existing member/subscriber"
            
            static func Issue(_ price: String) -> String {
                return "I want to purchase this issue for " + price
            }
            
            static func Subscription(_ price: String) -> String {
                return "Buy a 1-year subscription for " + price
            }
            
            static let Restore = "Restore My Purchase"
        }
    }
    
    struct DateFormats {
        static let dayMonthYear = "dd-MMM-yyyy"
    }
    
    struct TopArticles {
        static let MostReadTitle = "Most-read articles in the last 30 days"
    }
}

// MARK: - Cell Identifiers -

extension Strings {
    
    class CellIdentifier {
        static let SearchCell = "SearchCell"
        static let ArticleTableViewCell = "ArticleTableViewCell"
    }
}

// MARK - HTTP Methods -

extension Strings {
    
    class HTTPMethod {
        static let GET = "GET"
        static let POST = "POST"
    }
}

extension Strings {
    
    class CollectionView {
        
        class CellIdentifier {
            static let Publication = "PublicationCollectionViewCell"
        }
        
        class HeaderView {
            static let Publication = "PublicationHeaderView"
        }
    }
}

extension Strings {
    
    class IPAuth {
        
        static let UsageAuthorized = "authorized"
        
    }
}

let CachesDirectoryPath = FileSystem.Caches.Path
let DocumentDirectoryPath = FileSystem.Documents.Path

struct FileSystem {
    struct Caches {
        static let URL = Foundation.URL(string: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String)!
        static let Path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String + "/"
    }
    struct Documents {
        static let URL = Foundation.URL(string: FileSystem.Documents.Path)!
        static let Path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String + "/"
    }
}


//  MARK: - Accessibility - 

extension Strings {
    
    class func accessibilityForSectionWithTitle(_ section: SLTableViewSection, title: String) -> String {
        
        var accessibility = title == "INFO" ? "\(title), " : "\(title) section, "
        let collapsed = section.collapsed
        
        accessibility = collapsed == true ? accessibility + "collapsed" : accessibility + "expanded"
        
        return accessibility
    }
}


//  MARK: - Long strings -

extension Strings {
    
    struct Login {
        
        static let SelectLabelText = "Select an option from the list below that best identifies your journal subscription: either through society membership or as a non-member personal subscriber."
    }
    
    
}
