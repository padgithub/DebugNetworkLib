//
//  DNLHTTPModelManager.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

import Foundation

private let _sharedInstance = DNLHTTPModelManager()

final class DNLHTTPModelManager: NSObject
{
    static let sharedInstance = DNLHTTPModelManager()
    fileprivate var models = [DNLHTTPModel]()
    private let syncQueue = DispatchQueue(label: "DNLSyncQueue")
    
    func add(_ obj: DNLHTTPModel)
    {
        syncQueue.async {
            self.models.insert(obj, at: 0)
            NotificationCenter.default.post(name: NSNotification.Name.DNLAddedModel, object: obj)
            if SocketIOManager.shared.isSocketConnected() {
                guard let data =  obj.urlSessionDataTask else {
                    return
                }
                let obj = DNLRequestData.init(urlSessionDataTask: data, data: obj.dataConver ?? Data())
                SocketIOManager.shared.send(data: obj.getJsonResponseData())
                print("SockABC")
            }
            
        }
    }
    
    func clear()
    {
        syncQueue.async {
            self.models.removeAll()
            NotificationCenter.default.post(name: NSNotification.Name.DNLClearedModels, object: nil)
        }
    }
    
    func getModels() -> [DNLHTTPModel]
    {        
        var predicates = [NSPredicate]()
        
        let filterValues = DNL.sharedInstance().getCachedFilters()
        let filterNames = HTTPModelShortType.allValues
        
        var index = 0
        for filterValue in filterValues {
            if filterValue {
                let filterName = filterNames[index].rawValue
                let predicate = NSPredicate(format: "shortType == '\(filterName)'")
                predicates.append(predicate)

            }
            index += 1
        }

        let searchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        let array = (self.models as NSArray).filtered(using: searchPredicate)
        
        return array as! [DNLHTTPModel]
    }
}
