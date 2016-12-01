
//  OverlordViewController.swift
//  JBSM
//
//  Created by Sharkey, Justin (ELS-CON) on 9/16/16.
//  Copyright © 2016 Elsevier, Inc. All rights reserved.
//

import UIKit

class Overlord {
    
    internal enum AppType {
        case singleJournal
        case multiJournal
        case unknown
    }
    
    public struct CurrentAppInformation {
        var publisher : Publisher?
        var journal   : Journal?
        var issue     : Issue?
        var article   : Article?
    }
    
    static var currentPublisher : Publisher?
    static var currentJournal   : Journal?
    static var currentIssue     : Issue?
    static var currentArticle   : Article?
    
    // MARK: - View Controller Item -
    
    private struct ViewControllerItem {
        let type: ViewControllerType
        weak var viewController: UIViewController?
    }
    
    // MARK: - Navigation Controller -
    
    class NavigationController: UINavigationController {
        
        private var overloadItems: [ViewControllerItem] = []
        
        var appType: AppType {
            switch DatabaseManager.SharedInstance.numberOfJournals {
            case 1:
                return .singleJournal
            case 2:
                return .multiJournal
            default:
                return .unknown
            }
        }
        
        override init(rootViewController: UIViewController) {
            let type = ViewControllerType.type(for: rootViewController)
            overloadItems.append(ViewControllerItem(type: type, viewController: rootViewController))
            super.init(rootViewController: rootViewController)
        }
        
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            let type = ViewControllerType.type(for: viewController)
            pushViewController(viewController, animated: animated, type: type)
        }
        
        func pushViewController(_ viewController: UIViewController, animated: Bool, type: ViewControllerType) {
            
            if let currentItem = overloadItems.last {
                switch currentItem.type {
                case .splashScreen:
                    removeSelfAndPushViewController(viewController, animated: false)
                    overloadItems.append(ViewControllerItem(type: type, viewController: viewController))
                    return
                default:
                    break
                }
            }
            
            overloadItems.append(ViewControllerItem(type: type, viewController: viewController))
            super.pushViewController(viewController, animated: animated)
        }
        
        func navigateToViewControllerType(_ type: ViewControllerType, appInfo: CurrentAppInformation) -> Bool {
            var viewControllers: [UIViewController] = []
            switch type {
                
            case .splashScreen:
                
                let splashScreenVC = SplashScreenViewController()
                viewControllers.append(splashScreenVC)
                
            case .multiJournal:
                
                guard let publisher = appInfo.publisher else {
                    return false
                }
                let multiJournalVC = MultiJournalViewController(publisher: publisher)
                viewControllers.append(multiJournalVC)
                
            case .singleJournal:
                
                guard let publisher = appInfo.publisher, let journal = appInfo.journal else {
                    return false
                }
                if publisher.allJournals.count > 1 {
                    viewControllers.append(MultiJournalViewController(publisher: publisher))
                }
                viewControllers.append(SingleJournalViewController(journal: journal))
                
            case .latestIssue:
                
                guard let publisher = appInfo.publisher, let journal = appInfo.journal else {
                    return false
                }
                guard let firstIssue = journal.firstIssue else {
                    return false
                }
                
                let issueVC = StoryboardHelper.Articles()
                issueVC.currentJournal = journal
                issueVC.currentIssue = firstIssue
                
                if publisher.allJournals.count > 1 {
                    viewControllers.append(MultiJournalViewController(publisher: publisher))
                }
                viewControllers.append(issueVC)
                
                break
                
            case .issues:
                
                guard let publisher = appInfo.publisher, let journal = appInfo.journal else {
                    return false
                }
                if publisher.allJournals.count > 1 {
                    viewControllers.append(MultiJournalViewController(publisher: publisher))
                }
                viewControllers.append(IssuesViewController(journal: journal))
                
            default:
                break
            }
            
            guard viewControllers.count > 0 else {
                return false
            }
            
            removeSelfAndPushViewControllers(viewControllers)
            return true
        }
        
        func removeAllAndPushViewController(_ viewController: UIViewController, animated: Bool) {
            overloadItems.removeAll()
            self.setViewControllers([viewController], animated: false)
        }
        
        func removeSelfAndPushViewController(_ viewController: UIViewController, animated: Bool) {
            if self.popViewController(animated: animated) != .none {
                overloadItems.removeLast()
            }
            var vcs = self.viewControllers
            vcs.append(viewController)
            self.setViewControllers(vcs, animated: false)
        }
        
        func removeSelfAndPushViewControllers(_ viewControllers: [UIViewController]) {
            overloadItems.removeAll()
            self.setViewControllers(viewControllers, animated: false)
        }
    }
}

extension UIViewController {
    
    var overlord: Overlord.NavigationController? {
        guard let _overlord = self.navigationController as? Overlord.NavigationController else {
            return nil
        }
        return _overlord
    }
    
}

// MARK: - View Conroller type -

extension Overlord {
    internal enum ViewControllerType {
        
        case unknown
        case splashScreen
        case multiJournal
        case singleJournal
        case latestIssue
        case aips
        case aipArticle
        case issues
        case issueTOC
        case issueArticle
        
        static func type(for viewController: UIViewController) -> ViewControllerType {
            switch viewController.self {
            case is SplashScreenViewController:
                return .splashScreen
            case is MultiJournalViewController:
                return .multiJournal
            case is SingleJournalViewController:
                return .singleJournal
            default:
                return .unknown
            }
        }
        
        static func firstLevelTypes() -> [ViewControllerType] {
            return [self.splashScreen, self.multiJournal, self.singleJournal]
        }
        
        static func secondLevelTypes() -> [ViewControllerType] {
            return []
        }
    }
}
