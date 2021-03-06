//
//  DNLSettingsController_iOS.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

#if os(iOS)
    
import UIKit
import MessageUI

class DNLSettingsController_iOS: DNLSettingsController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, DataCleaner {
    
    var tableView: UITableView = UITableView()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        DNLURL = "https://github.com/padgithub/DebugNetworkLib"
        
        self.title = "Settings"
        
        self.tableData = HTTPModelShortType.allValues
        self.filters =  DNL.sharedInstance().getCachedFilters()
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage.DNLStatistics(), style: .plain, target: self, action: #selector(DNLSettingsController_iOS.statisticsButtonPressed)), UIBarButtonItem(image: UIImage.DNLInfo(), style: .plain, target: self, action: #selector(DNLSettingsController_iOS.infoButtonPressed))]
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 60)
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.translatesAutoresizingMaskIntoConstraints = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = false
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        self.view.addSubview(self.tableView)
        
        var DNLVersionLabel: UILabel
        DNLVersionLabel = UILabel(frame: CGRect(x: 10, y: self.view.frame.height - 60, width: self.view.frame.width - 2*10, height: 30))
        DNLVersionLabel.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        DNLVersionLabel.font = UIFont.DNLFont(size: 14)
        DNLVersionLabel.textColor = UIColor.DNLOrangeColor()
        DNLVersionLabel.textAlignment = .center
        DNLVersionLabel.text = DNLVersionString
        self.view.addSubview(DNLVersionLabel)
        
        var DNLURLButton: UIButton
        DNLURLButton = UIButton(frame: CGRect(x: 10, y: self.view.frame.height - 40, width: self.view.frame.width - 2*10, height: 30))
        DNLURLButton.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        DNLURLButton.titleLabel?.font = UIFont.DNLFont(size: 12)
        DNLURLButton.setTitleColor(UIColor.DNLGray44Color(), for: .init())
        DNLURLButton.titleLabel?.textAlignment = .center
        DNLURLButton.setTitle(DNLURL, for: .init())
        DNLURLButton.addTarget(self, action: #selector(DNLSettingsController_iOS.DNLURLButtonPressed), for: .touchUpInside)
        self.view.addSubview(DNLURLButton)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        DNL.sharedInstance().cacheFilters(self.filters)
    }
    
    @objc func DNLURLButtonPressed()
    {
        UIApplication.shared.open(URL(string: DNLURL)!)
    }
    
    @objc func infoButtonPressed()
    {
        var infoController: DNLInfoController_iOS
        infoController = DNLInfoController_iOS()
        self.navigationController?.pushViewController(infoController, animated: true)
    }
    
    @objc func statisticsButtonPressed()
    {
        var statisticsController: DNLStatisticsController_iOS
        statisticsController = DNLStatisticsController_iOS()
        self.navigationController?.pushViewController(statisticsController, animated: true)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
        case 0: return 1
        case 1: return self.tableData.count
        case 2: return 1
        case 3: return 1

        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont.DNLFont(size: 14)
        cell.tintColor = UIColor.DNLOrangeColor()
        
        switch (indexPath as NSIndexPath).section
        {
        case 0:
            cell.textLabel?.text = "Logging"
            let DNLEnabledSwitch: UISwitch
            DNLEnabledSwitch = UISwitch()
            DNLEnabledSwitch.setOn(DNL.sharedInstance().isEnabled(), animated: false)
            DNLEnabledSwitch.addTarget(self, action: #selector(DNLSettingsController_iOS.DNLEnabledSwitchValueChanged(_:)), for: .valueChanged)
            cell.accessoryView = DNLEnabledSwitch
            return cell
            
        case 1:
            let shortType = tableData[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = shortType.rawValue
            configureCell(cell, indexPath: indexPath)
            return cell
            
        case 2:
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "Share Session Logs to Mail"
            cell.textLabel?.textColor = UIColor.DNLGreenColor()
            cell.textLabel?.font = UIFont.DNLFont(size: 16)
            return cell
            
        case 3:
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "Clear data"
            cell.textLabel?.textColor = UIColor.DNLRedColor()
            cell.textLabel?.font = UIFont.DNLFont(size: 16)
            
            return cell
            
        default: return UITableViewCell()
            
        }
        
    }
    
    func reloadTableData()
    {
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.DNLGray95Color()
        
        switch section {
        case 1:
            
            var filtersInfoLabel: UILabel
            filtersInfoLabel = UILabel(frame: headerView.bounds)
            filtersInfoLabel.backgroundColor = UIColor.clear
            filtersInfoLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            filtersInfoLabel.font = UIFont.DNLFont(size: 13)
            filtersInfoLabel.textColor = UIColor.DNLGray44Color()
            filtersInfoLabel.textAlignment = .center
            filtersInfoLabel.text = "\nSelect the types of responses that you want to see"
            filtersInfoLabel.numberOfLines = 2
            headerView.addSubview(filtersInfoLabel)
            
            
        default: break
        }
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch (indexPath as NSIndexPath).section
        {
        case 1:
            let cell = tableView.cellForRow(at: indexPath)
            self.filters[(indexPath as NSIndexPath).row] = !self.filters[(indexPath as NSIndexPath).row]
            configureCell(cell, indexPath: indexPath)
            break
            
        case 2:
            shareSessionLogsPressed()
            break
            
        case 3:
            clearDataButtonPressedOnTableIndex(indexPath)
            break
            
        default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch (indexPath as NSIndexPath).section {
        case 0: return 44
        case 1: return 33
        case 2,3: return 44

        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {        
        let iPhone4s = (UIScreen.main.bounds.height == 480)
        switch section {
        case 0:
            if iPhone4s {
                return 20
            } else {
                return 40
            }
        case 1:
            if iPhone4s {
                return 50
            } else {
                return 60
            }
        case 2, 3:
            if iPhone4s {
                return 25
            } else {
                return 50
            }
            
        default: return 0
        }
    }
    
    func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath)
    {
        if (cell != nil) {
            if self.filters[(indexPath as NSIndexPath).row] {
                cell!.accessoryType = .checkmark
            } else {
                cell!.accessoryType = .none
            }
        }
    }
    
    @objc func DNLEnabledSwitchValueChanged(_ sender: UISwitch)
    {
        if sender.isOn {
            DNL.sharedInstance().enable()
        } else {
            DNL.sharedInstance().disable()
        }
    }
    
    func clearDataButtonPressedOnTableIndex(_ index: IndexPath)
    {

        clearData(sourceView: tableView, originingIn: tableView.rectForRow(at: index)) { }
    }

    func shareSessionLogsPressed()
    {
        if (MFMailComposeViewController.canSendMail()) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setSubject("DebugNetworkLib log - Session Log \(NSDate())")
            if let sessionLogData = NSData(contentsOfFile: DNLPath.SessionLog as String) {
                mailComposer.addAttachmentData(sessionLogData as Data, mimeType: "text/plain", fileName: "session.log")
            }
            
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

#endif
