
//
//  AppDelegate.swift
//  JAT
//
//  Created by Sharkey, Justin (ELS-CON) on 6/20/15.
//  Copyright (c) 2015 Sharkey, Justin (ELS-CON). All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var currentJournal: Journal?
    
    let reachability = Reachability.forInternetConnection()
    
    var backgroundTask: UIBackgroundTaskIdentifier?
    
    var playingVideo = false
    
    var overlord: Overlord.NavigationController!
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

// MARK: - Lifecycle -

extension AppDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        updateAppConfiguration()
        startLogs()
        updateForLaunchArguments()
        
        log.info(CachesDirectoryPath as AnyObject?)
        
        if ScreenshotStrings.RunningSnapshots {
            UserConfig.MainInstance.ShowGoToBookmarks = false
            UserConfig.MainInstance.ShowHowToUseTheApp = false
        }
        
        migrate()

        startAnalytics()
        startPushNotifications()
        startFabric()
        
        startReachability()
        
        AppConfiguration.UpdateAppearance()
        DatabaseManager.SharedInstance.resetAllDownloads()
        
        var splashScreen: SplashScreenViewController
        
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: Any] != nil {
            splashScreen = SplashScreenViewController(deepLink: true)
        } else {
            splashScreen = SplashScreenViewController()
        }
        
        overlord = Overlord.NavigationController(rootViewController: splashScreen)
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = self.overlord
        
        return true
    }
    
    func startLogs() {
        //log.addDestination(cloud)
        //log.addDestination(console)
        //log.info(CachesDirectoryPath)
    }
    
    func updateForLaunchArguments() {
        let defaults: ProcessInfo = ProcessInfo.processInfo
        var index = 0
        for _ in defaults.arguments {
            if defaults.arguments[index] == ScreenshotStrings.ScreenNameSplashScreenKey {
                ScreenshotStrings.ScreenName = defaults.arguments[index + 1]
            }
            index += 1
        }
    }
    
    func startAnalytics() {
        guard ANALYTICS_ENABLED, !ScreenshotStrings.RunningSnapshots else {
            return
        }
        
        AnalyticsHelper.Create(analyticsType: .siteCatalyst)
        ADBMobile.setDebugLogging(false)
        ADBMobile.collectLifecycleData()
    }
    
    func startFabric() {
        // guard FABRIC_ENABLED else { return }
        // guard !ScreenshotStrings.RunningSnapshots else { return }
        // Fabric.with([Crashlytics.self])
    }
    
    func startPushNotifications() {
        guard PUSH_NOTIFICATIONS_ENABLED, !ScreenshotStrings.RunningSnapshots else {
            return
        }
        
        let config = UAConfig.default()
        config.isAutomaticSetupEnabled = true
        UAirship.takeOff(config)
        let pushDelegate = PushNotification.Manager.shared
        UAirship.push().userPushNotificationsEnabled = true
        UAirship.push().pushNotificationDelegate = pushDelegate
        UAirship.push().registrationDelegate = pushDelegate
    }
    
    func startReachability() {
        guard NETWORKING_ENABLED else {
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectionDidChange(_:)), name: NSNotification.Name.reachabilityChanged, object: reachability)
        self.reachability?.startNotifier()
    }
    
    func updateAppConfiguration() {
        
        guard let infoDict = Bundle.main.infoDictionary else { return }
        
        if let appShortCode = infoDict["AppShortCode"] as? String {
            Strings.AppShortCode = appShortCode
            if appShortCode == "V45LANCET" { Strings.IsLancet = true }
        }
        
        if let _environment = infoDict["ENVIRONMENT"] as? String {
            let environment = _environment.lowercased()
            if environment == "prod" || environment == "production" {
                Strings.Environment = .production
            } else if environment == "cert" || environment == "certification" {
                Strings.Environment = .certification
            } else if environment == "dev" || environment == "development" {
                Strings.Environment = .development
            }
        }
        
        if let buildVersion = infoDict["CFBundleVersion"] as? String {
            BUILD_VERSION = buildVersion
        }
        
        if let compileTimestamp = infoDict["COMPILE_TIMESTAMP"] as? String {
            COMPILE_TIMESTAMP = compileTimestamp
        }
        
        if let _snapshots = infoDict["Screenshots"] as? Bool {
            ScreenshotStrings.RunningSnapshots = _snapshots
        }
        
        if ScreenshotStrings.RunningSnapshots {
            Strings.Environment = .production
            OVERRIDE_LOGIN = true
        }
    }

    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        
        guard let vc = window?.rootViewController else {
            return .portrait
        }
        if vc.view.frame.size.width < 768 {
            if playingVideo == false {
                return .portrait
            } else {
                return .all
            }
        } else {
            return .all
        }
    }
}

// MARK: - Application Lifecycle -

extension AppDelegate {
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if DMManager.sharedInstance.sections.count > 0 {
            BackgroundManager.StartBackgroundRequest()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if NETWORKING_ENABLED {
            updateIPAuth()
            APIManager.sharedInstance.downloadAppImages()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

// MARK: - Methods -

extension AppDelegate {
    
    func connectionDidChange(_ notification: Foundation.Notification) {
        guard NETWORK_AVAILABLE else { return }
        
        updateIPAuth()
    }
    
    func updateIPAuth() {
        guard NETWORKING_ENABLED else { return }
        guard IP_Auth_Enabled    else { return }
        guard NETWORK_AVAILABLE  else { return }
        
        APIManager.sharedInstance.ipAuthentication(authtoken: IPInfo.AuthToken, ip: nil) { (success) in
            guard IPInfo.Instance.authentication?.anonymity == "ANON_IP" else {
                IPInfo.Instance.authorization = nil
                return
            }
            APIManager.sharedInstance.ipAuthorization({ success in })
        }
    }
    
    func deleteFirstIssue(journalId: String) {
        guard let journal = DatabaseManager.SharedInstance.getJournal(issn: journalId) else { return }
        guard let issue = journal.firstIssue else { return }
        let dateFormatter = DateFormatter(dateFormat: "YYYY-MM-dd HH:mm:ss")
        let date = dateFormatter.string(from: issue.dateOfRelease!)
        UserDefaults.standard.setValue(date, forKey: Strings.API.DateKeys.Issues)
        DatabaseManager.SharedInstance.moc!.delete(issue)
    }
    
    func migrate() {
        let finalDBPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/dbJAT.sqlite"
        guard FileSystemManager.sharedInstance.fileExists(finalDBPath) else { return }
        DBMigration()?.migrate()
        FileSystemManager.sharedInstance.deleteFile(finalDBPath)
    }
    
    func authorizeAllJournals(_ authentication: Authentication) {
        for journal in DatabaseManager.SharedInstance.getAllJournals() {
            APIManager.sharedInstance.loginAuthorization(authentication, journal: journal, completion: { (authorized) in })
        }
    }
}
