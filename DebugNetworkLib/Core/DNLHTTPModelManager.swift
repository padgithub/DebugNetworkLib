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
                let info = DNLRequestInfo(id: UUID().uuidString, date: obj.getDate(), url: obj.requestURL ?? "N/A", statusCode: obj.responseStatus ?? 0, method: obj.requestMethod ?? "N/A", userAgent: obj.responseUserAgent ?? "N/A", authorize: obj.responseAuthorization ?? "", httpBody: obj.getRequestBody() as String, data: obj.getResponseBody() as String)
                SocketIOManager.shared.send(data: info.getJsonResponseData())
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
