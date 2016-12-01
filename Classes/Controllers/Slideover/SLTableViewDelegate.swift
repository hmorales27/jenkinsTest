/*
    SLTableViewDelegate
*/

import Foundation
import UIKit

class SLTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource, SectionDataViewDelegate, SLSearchTableViewCellDelegate {
    
    static var SettingsSectionOpen = false
    static var InfoSectionOpen = false
    
    var tableViewData: [SLTableViewSection] = []
    weak var journal: Journal?
    
    weak var delegate: SLTableViewItemTypeProtocol?
    weak var tableView: UITableView?
    
    var selectedType: SLTableViewItemType?
    
    var settingsSectionIndex: Int?
    var infoSectionIndex: Int?
    
    init(journal: Journal) {
        super.init()
        self.journal = journal
    }
    
    private var type: ScreenType?
    
    func update(screenType type: ScreenType) {
        self.type = type
        tableViewData = []
        
        if type == .mobile {
            tableViewData.append(sectionZero)
        }
        
        tableViewData.append(sectionOne)
        tableViewData.append(sectionTwo)
        if let sectionThree = self.sectionThree {
            tableViewData.append(sectionThree)
        }
        
        if type == .mobile {
            tableViewData.append(sectionFour)
            tableViewData.append(sectionFive)
            tableViewData.append(sectionSix)
        }
        
        //tableViewData.append(sectionSeven)
    }
    
    var sectionZero: SLTableViewSection {
        let sectionZero = SLTableViewSection(title: nil)
        sectionZero.items.append(SLSearchTableViewItem())
        return sectionZero
    }
    
    var sectionOne: SLTableViewSection {
        let sectionOne = SLTableViewSection(title: nil)
        let allJournals = DatabaseManager.SharedInstance.getAllJournals()
        if allJournals.count > 1 {
            sectionOne.items.append(SLTableViewItem(title: "Home", type: .close))
            if let screenType = type {
                switch screenType {
                case .mobile:
                    sectionOne.items.append(SLTableViewItem(title: journal!.journalTitleIPhone!, type: .highlight))
                case.tablet:
                    sectionOne.items.append(SLTableViewItem(title: journal!.journalTitle!, type: .highlight))
                }
            }
        } else {
            sectionOne.items.append(SLTableViewItem(title: "Home", type: .highlight))
        }
        if journal?.isAipAvailable == true {
            var title = "Articles in Press"
            if let _title = journal?.aipTitle {
                title = _title
            }
            let tableViewItem = SLTableViewItem(title: title, type: .articlesInPress)
            tableViewItem.accessibilityLabel = title
            sectionOne.items.append(tableViewItem)
        }
 
        
        let title = "Top Articles"
        
        let tableViewItem = SLTableViewItem(title: title, type: .topArticles)
        tableViewItem.accessibilityLabel = title
        sectionOne.items.append(tableViewItem)
        
        
        if let issue = journal?.firstIssue {
            if let date = issue.dateOfRelease {
                let dateFormatter = DateFormatter(dateFormat: "MMM dd, YYYY")
                let dateString = dateFormatter.string(from: date)
                sectionOne.items.append(SLTableViewItem(title: "Latest Issue | \(dateString)", type: .latestIssue))
            }
        }
        sectionOne.items.append(SLTableViewItem(title: "All Issues", type: .allIssues))
        return sectionOne
    }
    
    var sectionTwo: SLTableViewSection {
        let section = SLTableViewSection(title: "MY ARTICLES")
        
        let itemOne = SLTableViewItem(title: "Reading List", type: .readingList)
        itemOne.accessibilityLabel = "My Articles. Reading List"
        section.addItem(itemOne)
        
        let itemTwo = SLTableViewItem(title: "Notes", type: .notes)
        itemTwo.accessibilityLabel = "My Articles. Notes."
        section.addItem(itemTwo)
        
        return section
    }
    
    var sectionThree: SLTableViewSection? {
        var available = false
        let section = SLTableViewSection(title: "JOURNAL INFO")
        if journal?.isAimScopeAvailable == true && journal?.aimScopeHTML != nil {
            let item = SLTableViewItem(title: "Aims & Scope", type: .aimAndScope)
            item.accessibilityLabel = "Journal Infomation. Aims & Scope."
            section.addItem(item)
            available = true
        }
        if journal?.isEditorialAvailable == true && journal?.editorialHTML != nil {
            let item = SLTableViewItem(title: "Editorial Board", type: .editorialBoard)
            item.accessibilityLabel = "Journal Information. Editorial Board."
            section.addItem(item)
            available = true
        }
        if available == true {
            return section
        } else {
            return nil
        }
    }
    
    var sectionFour: SLTableViewSection {
        let section = SLTableViewSection(title: "INFO")
        section.collapsable = true
        section.collapsed = !SLTableViewDelegate.InfoSectionOpen
        
        section.addItem("Support", type: .support)
        section.addItem("Feedback", type: .feedback)
        section.addItem("Terms & Conditions", type: .termsAndCoditions)
        section.addItem("FAQs", type: .faqs)
        section.addItem("How to use the App", type: .howToUseTheApp)
        return section
    }
    
    var sectionFive: SLTableViewSection {
        let section = SLTableViewSection(title: "SETTINGS")
        section.collapsable = true
        section.collapsed = !SLTableViewDelegate.SettingsSectionOpen
        section.addItem("Usage", type: .usage)
        section.addItem("Push Notifications", type: .pushNotifications)
        section.addItem("Downloads", type: .downloads)
        if journal?.isAuthenticated == true {
            section.addItem("Logout", type: .logout)
        } else {
            section.addItem("Login", type: .login)
        }
        return section
    }
    
    var sectionSix: SLTableViewSection {
        let section = SLTableViewSection(title: nil)
        section.addItem("Announcements", type: .announcements)
        return section
    }
    
    
    // MARK: - Table View -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = tableViewData[(indexPath as NSIndexPath).section]
        let row = section.items[(indexPath as NSIndexPath).row]
        
        if row.type == .search {
            let cell = tableView.dequeueReusableCell(withIdentifier: SLSearchTableViewCell.Identifier) as! SLSearchTableViewCell
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SLTableViewCell.Identifier) as! SLTableViewCell
            cell.titleLabel.textColor = UIColor.white
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            
            if row.type == .announcements {
                
                let count = DatabaseManager.SharedInstance.getAllAnnouncements().count
                
                if count == 0 {
                    cell.accessibilityLabel = "You have no new announcements"
                } else if count == 1 {
                    cell.accessibilityLabel = "You have 1 new announcement"
                } else {
                    cell.accessibilityLabel = "You have \(count) new announcements"
                }
                
                if count > 0 {
                    cell.countView.update(count)
                    cell.countView.isHidden = false
                } else {
                    cell.countView.update(0)
                    cell.countView.isHidden = true
                }
                
                if count == 0 {
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.titleLabel.textColor = UIColor.gray
                }
            } else if row.type == .downloads {
                
                //  the tableView just needs to reloadData, or at least reload at the downloads
                //  indexPath before the drawer is slid open while 'settings' section is expanded.
                
                if DMManager.sharedInstance.sectionsWithFullText.count == 0 {
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell.titleLabel.textColor = UIColor.gray
                    cell.countView.isHidden = true
                    cell.accessibilityLabel = "No downloads in progress"
                } else {
                    cell.countView.isHidden = false
                    cell.countView.update(DMManager.sharedInstance.sectionsWithFullText.count)
                    
                    if let labelText = cell.titleLabel.text {
                        cell.accessibilityLabel = labelText
                    }
                }
                
            } else {
                cell.countView.isHidden = true
            }
            
            if row.type == self.selectedType {
                cell.backgroundColor = Config.Colors.SlideOutHighlightColor
            } else {
                cell.backgroundColor = UIColor.clear
            }
            
            cell.titleLabel.text = row.title
            cell.titleLabel.accessibilityLabel = row.type == .faqs ? "F A Q's" : row.accessibilityLabel

            if row.type == .latestIssue {
                let cleanTitle = row.title.replacingOccurrences(of: " |", with: "")

                cell.titleLabel.accessibilityLabel = cleanTitle
                
                if let issue = journal?.firstIssue {
                    let showFree = issue.coverImageShouldShowFreeLabel
                    
                    cell.freeLabel.isHidden = !Bool(showFree)
                    
                    if showFree == true {
                        cell.titleLabel.accessibilityLabel = "Free issue. " + cleanTitle
                    }
                }
            }
            if row.type == .support || row.type == .usage {
                
                guard let labelText = cell.titleLabel.text else {
                    
                    return cell
                }
                
                cell.accessibilityLabel = labelText
            }
            
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = tableViewData[section]
        if section.collapsable == true {
            if section.collapsed == true {
                return 0
            }
        }
        return section.items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableViewData[section].title == .none {
            return 0
        }
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionsData.TableHeaderView()
        let _section = tableViewData[section]
        var title = ""
        if let _title = _section.title {
            title = _title
        }
        let collapsed = _section.collapsed
        if _section.collapsable == false {
            view.view.collapsable = false
        }
        
        if title == "INFO" {
            infoSectionIndex = section
            view.view.isAccessibilityElement = true
            view.view.accessibilityLabel = Strings.accessibilityForSectionWithTitle(_section, title: title)
        }
        else if title == "SETTINGS" {
            settingsSectionIndex = section
            view.isAccessibilityElement = true
            view.accessibilityLabel = Strings.accessibilityForSectionWithTitle(_section, title: title)
        }
        else {
            view.isAccessibilityElement = false
            view.view.isAccessibilityElement = false
        }
        
        view.view.update(title, section: section, collapsed: collapsed)
        view.view.delegate = self

        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = tableViewData[(indexPath as NSIndexPath).section]
        let row = section.items[(indexPath as NSIndexPath).row]
        delegate?.slTableViewNavigateWithType(row.type)
    }
    
    func sectionViewDidToggleCollapseAll(_ collapse: Bool) {
        
    }
    
    func sectionViewDidToggleCollapseForIndex(_ index: Int) {
        
        guard let infoSectionIndex = self.infoSectionIndex else { return }
        guard let settingsSectionIndex = self.settingsSectionIndex else { return }
        

        let infoSection = tableViewData[infoSectionIndex]
        let settingsSection = tableViewData[settingsSectionIndex]
        
        if index == infoSectionIndex {

            // Both INFO and SETTINGS are collapsed
            if infoSection.collapsed == true && settingsSection.collapsed == true {
                infoSection.collapsed = false
                SLTableViewDelegate.InfoSectionOpen = true
                SLTableViewDelegate.SettingsSectionOpen = false
                delegate?.slTableViewReloadSection(infoSectionIndex)
                return
            }
            
            // INFO is open
            if infoSection.collapsed == false {
                infoSection.collapsed = true
                SLTableViewDelegate.InfoSectionOpen = false
                SLTableViewDelegate.SettingsSectionOpen = false
                delegate?.slTableViewReloadSection(infoSectionIndex)
                return
            }
            
            // SETTINGS is open
            if settingsSection.collapsed == false {
                settingsSection.collapsed = true
                infoSection.collapsed = false
                SLTableViewDelegate.InfoSectionOpen = true
                SLTableViewDelegate.SettingsSectionOpen = false
                delegate?.slTableViewReloadSection(infoSectionIndex)
                delegate?.slTableViewReloadSection(settingsSectionIndex)
                return
            }
            
        } else if index == settingsSectionIndex {
            
            // Both INFO and SETTINGS are collapsed
            if infoSection.collapsed == true && settingsSection.collapsed == true {
                settingsSection.collapsed = false
                SLTableViewDelegate.InfoSectionOpen = false
                SLTableViewDelegate.SettingsSectionOpen = true
                delegate?.slTableViewReloadSection(settingsSectionIndex)
                return
            }
            
            // INFO is open
            if settingsSection.collapsed == false {
                settingsSection.collapsed = true
                SLTableViewDelegate.InfoSectionOpen = false
                SLTableViewDelegate.SettingsSectionOpen = false
                delegate?.slTableViewReloadSection(settingsSectionIndex)
                return
            }
            
            // SETTINGS is open
            if infoSection.collapsed == false {
                infoSection.collapsed = true
                settingsSection.collapsed = false
                SLTableViewDelegate.InfoSectionOpen = false
                SLTableViewDelegate.SettingsSectionOpen = true
                delegate?.slTableViewReloadSection(infoSectionIndex)
                delegate?.slTableViewReloadSection(settingsSectionIndex)
                return
            }
            
        }
    }
    
    func userDidSearch(text: String) {
        delegate?.slTableViewNavigateWithType(.search, text: text)
    }
}
