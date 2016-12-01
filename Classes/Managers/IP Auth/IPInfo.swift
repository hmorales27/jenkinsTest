/*
    IPAuthentication

    Created by Sharkey, Justin (ELS-CON) on 2/10/16.
    opyright © 2016 Elsevier, Inc. All rights reserved.
*/

import Foundation

enum Anonymity: String {
    case ANON_IP = "ANON_IP"
    case ANON_GUEST = "ANON_GUEST"
}

enum IPInfoStatus {
    case none
    case ipAuthenticated
    case ipAuthorizing
    case complteted
}

class IPAuthenticationResponse {
    var anonymity: String?
    var idp: String?
    var lastName: String?
    var ipAddress: String?
    var login: String?
    var email: String?
    var authUsageInfo: String?
    var titleId: String?
    var bannerText: String?
    var authToken: String?
    var userId: String?
    var firstName: String?
    var session: String?
    var organizationName: String?
}

class IPAuthorizationResponse {
    
    fileprivate var entitlements: [Entitled] = []
    
    func itemForISSN(_ issn: String) -> Entitled? {
        for item in entitlements {
            if item.issn == issn {
                return item
            }
        }
        return nil
    }
}

class Entitled {
    
    let dateFormatter = DateFormatter(dateFormat: "dd-MMM-yyyy HH:mm:ss")
    
    // Properties
    var issn: String?
    var isEntitled: String?
    var compDates: [DateRange] = []
    var subDates: [DateRange] = []
    
    var allDates: [DateRange] {
        return compDates + subDates
    }
    
    // Methods
    
    init() {
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
    }
    
    func addCompDates(_ dateString: String) {
        compDates = dateRangesForString(dateString)
    }
    
    func addSubDates(_ dateString: String) {
       subDates = dateRangesForString(dateString)
    }
    
    func dateRangesForString(_ string: String) -> [DateRange] {
        var dateRanges: [DateRange] = []
        let separatedDates = string.characters.split{$0 == ","}.map(String.init)
        for dates in separatedDates {
            let date = dates.characters.split{$0 == "/"}.map(String.init)
            if date.count == 2 {
                if let startDate = dateFormatter.date(from: date[0]), let endDate = dateFormatter.date(from: date[1]) {
                    let dateRange = DateRange(startDate: startDate, endDate: endDate)
                    dateRanges.append(dateRange)
                }
            }
            
        }
        return dateRanges
    }
    
    func validForDate(_ date: Date) -> Bool {
        for dateRange in allDates {
            if dateRange.contains(date) {
                return true
            }
        }
        return false
    }
}

class DateRange {
    
    var startDate: Date
    var endDate: Date

    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func contains(_ date: Date) -> Bool {
        if date.timeIntervalSince1970 < endDate.timeIntervalSince1970 && date.timeIntervalSince1970 > startDate.timeIntervalSince1970 {
            return true
        }
        return false
    }
}

class IPInfo {
    
    class func SetupWithDummyInformation() {
        var authData: [String: Any] = [:]
        authData["userId"] = "" as AnyObject?
        authData["login"] = "" as AnyObject?
        authData["email"] = "" as AnyObject?
        authData["firstName"] = "" as AnyObject?
        authData["lastName"] = "" as AnyObject?
        authData["titleId"] = "Tufts University" as AnyObject?
        authData["anonymity"] = "ANON_IP" as AnyObject?
        authData["authUsageInfo"] = "(123Nonsense)" as AnyObject?
        authData["ipAddress"] = "71.175.48.144" as AnyObject?
        authData["organizationName"] = "Tufts University" as AnyObject?
        authData["bannerText"] = "Access provided by Tufts University" as AnyObject?
        Instance.setupAuthentication(authData as [String : AnyObject])
        
        var autzData: [String: Any] = [:]
        var autzItem: [String: Any] = [:]
        autzItem["issn"] = "00928674" as AnyObject?
        autzItem["description"] = "" as AnyObject?
        autzItem["entitled"] = true as AnyObject?
        autzItem["compDate"] = "" as AnyObject?
        autzItem["subDate"] = "01-Jan-2008 00:00:00/30-Jun-2018 00:00:00" as AnyObject?
        autzData["multipleIssnBean"] = [autzItem]
        Instance.setupAuthorization(autzData as [String : AnyObject])
    }
    
    static let Instance = IPInfo()
    
    static var Session: String? {
        return IPInfo.Instance.authentication?.session
    }
    
    static var AuthToken: String? {
        return UserDefaults.standard.value(forKey: Strings.UserDefaults.AuthToken) as? String
    }
    
    static var FetchedIP: String? {
        return IPInfo.Instance.fetchedIP
    }
    
    static var AuthenticatedIP: String? {
        return IPInfo.Instance.authentication?.ipAddress
    }
    
    var authentication: IPAuthenticationResponse?
    var authorization: IPAuthorizationResponse?
    
    var fetchedIP: String?
    
    var currentIPAuthentication: IPAuthentication?
    var currentIPAuthenticationSaved = false
    
    var currentIPBanner: String?
    var shouldShowIPBanner = true
    
    var bannerForOpenAccess: String? {
        return IPInfo.Instance.authentication?.bannerText
    }
    
    // MARK: Initializer
    
    init() {
        
    }
    
    // MARK: Setup
    
    func setupAuthentication(_ json: [String: AnyObject]) {
        let response = IPAuthenticationResponse()
        response.anonymity = json["anonymity"] as? String
        response.idp = json["idp"] as? String
        response.ipAddress = json["ipAddress"] as? String
        response.login = json["login"] as? String
        response.email = json["email"] as? String
        response.authUsageInfo = json["authUsageInfo"] as? String
        response.titleId = json["titleId"] as? String
        response.bannerText = json["bannerText"] as? String
        if let authToken = json["authToken"] as? String {
            UserDefaults.standard.setValue(authToken, forKey: Strings.UserDefaults.AuthToken)
            response.authToken = json["authToken"] as? String
        }
        response.userId = json["userId"] as? String
        response.firstName = json["firstName"] as? String
        response.session = json["session"] as? String
        response.organizationName = json["organizationName"] as? String
        IPInfo.Instance.authentication = response
    }
    
    func setupAuthorization(_ json: [String: AnyObject]) {
        let response = IPAuthorizationResponse()
        if let bean = json["multipleIssnBean"] as? [[String: AnyObject]] {
            for item in bean {
                let issn = Entitled()
                issn.issn = item["issn"] as? String
                issn.isEntitled = item["entitled"] as? String
                if let compDates = item["compDate"] as? String {
                    issn.addCompDates(compDates)
                }
                if let subDate = item["subDate"] as? String {
                    issn.addSubDates(subDate)
                }
                response.entitlements.append(issn)
            }
        }
        IPInfo.Instance.authorization = response
    }
    
    func isDate(_ date: Date?, validForISSN issn: String) -> Bool {
        guard let _date = date else {
            return false
        }
        if let item = IPInfo.Instance.authorization?.itemForISSN(issn) {
            if item.validForDate(_date) {
                return true
            }
        }
        return false
    }
    
    func save() {
        if let authentication = IPInfo.Instance.authentication {
            if !IPInfo.Instance.currentIPAuthenticationSaved {
                let ipAuth = DatabaseManager.SharedInstance.newIPAuthentication()
                ipAuth.setup(authentication)
                DatabaseManager.SharedInstance.save()
                self.currentIPAuthentication = ipAuth
                self.currentIPAuthenticationSaved = true
            }
        }
    }
    
    func reset() {
        currentIPAuthentication = nil
        currentIPAuthenticationSaved = false
    }
}
