//
//  DNLListController.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

import Foundation

class DNLListController: DNLGenericController {

    var tableData = [DNLHTTPModel]()
    var filteredTableData = [DNLHTTPModel]()

    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    func updateSearchResultsForSearchControllerWithString(_ searchString: String)
    {
        let predicateURL = NSPredicate(format: "requestURL contains[cd] '\(searchString)'")
        let predicateMethod = NSPredicate(format: "requestMethod contains[cd] '\(searchString)'")
        let predicateType = NSPredicate(format: "responseType contains[cd] '\(searchString)'")
        let predicates = [predicateURL, predicateMethod, predicateType]
        let searchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        let array = (DNLHTTPModelManager.sharedInstance.getModels() as NSArray).filtered(using: searchPredicate)
        self.filteredTableData = array as! [DNLHTTPModel]
    }

    @objc func reloadTableViewData()
    {
    }
}
