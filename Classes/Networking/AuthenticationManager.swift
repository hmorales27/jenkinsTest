//
//  AuthenticationManager.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 8/22/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import Foundation

class AuthenticationManager {
    
    static let sharedInstance = AuthenticationManager()
    
    static let Session = URLSession(configuration: URLSessionConfiguration.default)
    
    // MARK: - Authentication -
    
    func singleAuthenticationRequest(_ partner: Partner, userName: String, password: String) -> Foundation.URLRequest? {
        
        guard let partnerId = partner.partnerId as? Int else {
            return nil
        }
        
        let encryptedUserName = NSString(string: userName).aes256Encrypt(withKey: Strings.EncryptionKey)
        let encryptedPassword = NSString(string: password).aes256Encrypt(withKey: Strings.EncryptionKey)
        
        guard let request = JBSMURLRequest.V2.Login.LoginAuthentication(partnerId: String(partnerId), userName: encryptedUserName!, password: encryptedPassword!, rememberMe: true) else {
            return nil
        }
        
        return request as URLRequest
    }
    
    func singleAuthentication(_ partner: Partner, userName: String, password: String, rememberMe: Bool, completion:@escaping (_ success: Bool, _ json: [String: AnyObject]?)->() ) {
        
        guard let request = singleAuthenticationRequest(partner, userName: userName, password: password) else {
            completion(false, nil)
            return
        }
        
        AuthenticationManager.Session.dataTask(with: request, completionHandler: { (_data, _response, _error) in
            
            if let error = _error {
                log.error(error.localizedDescription)
                completion(false, nil)
                return
            }
            
            guard let response = _response as? HTTPURLResponse else {
                completion(false, nil)
                return
            }
            
            switch response.statusCode {
            case 200:
                
                guard let data = _data else {
                    completion(false, nil)
                    return
                }
                
                var json: [String: AnyObject]
                do {
                    guard let _json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else {
                        completion(false, nil)
                        return
                    }
                    json = _json
                } catch let error as NSError {
                    log.error(error.localizedDescription)
                    completion(false, nil)
                    return
                }
                
                completion(true, json)
                
            default:
                if let data = _data {
                    if let string = String(data: data, encoding: String.Encoding.utf8) {
                        print(string)
                    }
                }
                completion(false, nil)
            }
            
        }) .resume()
    }
    
    // MARK: - Authorization -
    
    func singleAuthorizationRequest(_ productId: String?, sessionId: String?, idp: String?) -> Foundation.URLRequest? {
        guard let productId = productId, let sessionId = sessionId, let idp = idp else {
            return nil
        }
        let issn = productId.insert("-", ind: 4)
        guard let request = JBSMURLRequest.V2.Login.LoginAuthorization(sessionId, productId: issn, idp: idp) else {
            return nil
        }
        return request
    }
    
    func singleAuthorization(_ journal: Journal, json: [String: AnyObject], completion:@escaping (_ success: Bool)->()) {
        
        guard let request = singleAuthorizationRequest(journal.issn, sessionId: json["session"] as? String, idp: json["idp"] as? String) else {
            completion(false)
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request, completionHandler: { (_data, _response, _error) in
            
            if let error = _error {
                log.error(error.localizedDescription)
                completion(false)
                return
            }
            
            guard let response = _response as? HTTPURLResponse else {
                completion(false)
                return
            }
            
            guard let data = _data else {
                completion(false)
                return
            }
            
            switch response.statusCode {
            case 200:
                guard let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                    completion(false)
                    return
                }
                if responseString == "authorized" {
                    completion(true)
                    return
                } else {
                    completion(false)
                    return
                }
            default:
                completion(false)
                return
            }
            
        }) .resume()
    }
    
    
    
    // MARK: - Login -
    
    func login(_ partner: Partner, journal: Journal, userName: String, password: String, rememberMe: Bool, authentication:@escaping ((Bool)->()), authorization:@escaping ((Bool)->())) {
        
        singleAuthentication(partner, userName: userName, password: password, rememberMe: true) { (success, json) in
            
            guard success == true, let authJSON = json else {
                authentication(false)
                return
            }
            
            authentication(true)
            
            self.singleAuthorization(journal, json: authJSON, completion: { (success) in
                
                guard success == true else {
                    authorization(false)
                    return
                }
                
                DatabaseManager.SharedInstance.performChangesAndSave({ 
                    let authentication = self.createAuthenticationObject(partner, password: password , rememberMe: rememberMe, json: authJSON)
                    journal.authentication = authentication
                    if let partnerId = partner.partnerId {
                        self.authenticateAllJournals(Int(partnerId), json: authJSON, password: password)
                    }
                    
                })
                
                authorization(true)
            })
        }
    }
    
    func createAuthenticationObject(_ partner: Partner, password: String, rememberMe: Bool, json: [String: AnyObject]) -> Authentication {
        
        let encryptedPassword = NSString(string: password).aes256Encrypt(withKey: Strings.EncryptionKey)
        
        let authentication = DatabaseManager.SharedInstance.newAuthentication()
        authentication.userId     = json["userId"]    as? String
        authentication.loginId    = json["login"]     as? String
        authentication.sessionId  = json["session"]   as? String
        authentication.emailId    = json["email"]     as? String
        authentication.firstName  = json["firstName"] as? String
        authentication.lastName   = json["lastName"]  as? String
        authentication.idp        = json["idp"]       as? String
        authentication.partner    = partner
        authentication.password   = encryptedPassword
        authentication.rememberMe = rememberMe as NSNumber?
        return authentication
    }
    
    struct LoginInfo {
        var journal: Journal
        var partner: Partner
    }
    
    func authenticateAllJournals(_ partnerId: Int, json: [String: AnyObject], password: String) {
        for journal in DatabaseManager.SharedInstance.getAllJournals() {
            if journal.authentication == .none {
                for partner in journal.allPartners {
                    if partner.partnerId?.intValue == partnerId {
                        self.authenticateJournal(LoginInfo(journal: journal, partner: partner), json: json, password: password)
                    }
                }
            }
        }
    }
    
    func authenticateJournal(_ loginInfo: LoginInfo, json: [String: AnyObject], password: String) {
        self.singleAuthorization(loginInfo.journal, json: json, completion: { (success) in
            
            guard success == true else {
                return
            }
            
            DatabaseManager.SharedInstance.performChangesAndSave({
                let authentication = self.createAuthenticationObject(loginInfo.partner, password:password, rememberMe: true, json: json)
                loginInfo.journal.authentication = authentication
            })
        })
    }
}
