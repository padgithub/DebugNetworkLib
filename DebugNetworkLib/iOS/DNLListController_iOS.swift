//
//  DNLListController.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

#if os(iOS)
    
import Foundation
import UIKit

class DNLListController_iOS: DNLListController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, DataCleaner
{
    // MARK: Properties
    
    var tableView: UITableView = UITableView()
    var searchController: UISearchController!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.all
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.frame = self.view.frame
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.translatesAutoresizingMaskIntoConstraints = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.tableView.register(DNLListCell.self, forCellReuseIdentifier: NSStringFromClass(DNLListCell.self))

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.DNLClose(), style: .plain, target: self, action: #selector(DNLListController_iOS.closeButtonPressed))

        let rightButtons = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(DNLListController_iOS.trashButtonPressed)),
            UIBarButtonItem(image: UIImage.DNLSettings(), style: .plain, target: self, action: #selector(DNLListController_iOS.settingsButtonPressed))
        ]

        self.navigationItem.rightBarButtonItems = rightButtons


        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.autoresizingMask = [.flexibleWidth]
        self.searchController.searchBar.backgroundColor = UIColor.clear
        self.searchController.searchBar.barTintColor = UIColor.DNLOrangeColor()
        self.searchController.searchBar.tintColor = UIColor.DNLOrangeColor()
        self.searchController.searchBar.searchBarStyle = .minimal
        self.searchController.view.backgroundColor = UIColor.clear
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchController
            self.definesPresentationContext = true
        } else {
            let searchView = UIView()
            searchView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: 0)
            searchView.autoresizingMask = [.flexibleWidth]
            searchView.autoresizesSubviews = true
            searchView.backgroundColor = UIColor.clear
            searchView.addSubview(self.searchController.searchBar)
            self.searchController.searchBar.sizeToFit()
            searchView.frame = self.searchController.searchBar.frame

            self.navigationItem.titleView = searchView
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(DNLListController.reloadTableViewData),
            name: NSNotification.Name.DNLReloadData,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(DNLListController_iOS.deactivateSearchController),
            name: NSNotification.Name.DNLDeactivateSearch,
            object: nil)        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        reloadTableViewData()
    }

    @objc func settingsButtonPressed()
    {
        var settingsController: DNLSettingsController_iOS
        settingsController = DNLSettingsController_iOS()
        self.navigationController?.pushViewController(settingsController, animated: true)
    }

    @objc func trashButtonPressed()
    {
        self.clearData(sourceView: tableView, originingIn: nil) {

            self.reloadTableViewData()
        }
    }

    @objc func closeButtonPressed()
    {
        DNL.sharedInstance().hide()
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController)
    {
        self.updateSearchResultsForSearchControllerWithString(searchController.searchBar.text!)
        reloadTableViewData()
    }
    
    @objc func deactivateSearchController()
    {
        self.searchController.isActive = false
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (self.searchController.isActive) {
            return self.filteredTableData.count
        } else {
            return DNLHTTPModelManager.sharedInstance.getModels().count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DNLListCell.self), for: indexPath) as! DNLListCell
        
        if (self.searchController.isActive) {
            if self.filteredTableData.count > 0 {
                let obj = self.filteredTableData[(indexPath as NSIndexPath).row]
                cell.configForObject(obj)
            }
        } else {
            if DNLHTTPModelManager.sharedInstance.getModels().count > 0 {
                let obj = DNLHTTPModelManager.sharedInstance.getModels()[(indexPath as NSIndexPath).row]
                cell.configForObject(obj)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return UIView.init(frame: CGRect.zero)
    }
    
    override func reloadTableViewData()
    {
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var detailsController : DNLDetailsController_iOS
        detailsController = DNLDetailsController_iOS()
        var model: DNLHTTPModel
        if (self.searchController.isActive) {
            model = self.filteredTableData[(indexPath as NSIndexPath).row]
        } else {
            model = DNLHTTPModelManager.sharedInstance.getModels()[(indexPath as NSIndexPath).row]
        }
        detailsController.selectedModel(model)
        self.navigationController?.pushViewController(detailsController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 58
    }

}

#endif
