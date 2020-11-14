//
//  DNL.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

import Foundation
import UIKit

private func podPlistVersion() -> String? {
    guard let path = Bundle(identifier: "com.kasketis.DebugNetworkLib-iOS")?.infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
    return path
}

// TODO: Carthage support
let DNLVersion = podPlistVersion() ?? "0"

// Notifications posted when DNL opens/closes, for client application that wish to log that information.
let DNLWillOpenNotification = "DNLWillOpenNotification"
let DNLWillCloseNotification = "DNLWillCloseNotification"

@objc
open class DNL: NSObject
{
    // swiftSharedInstance is not accessible from ObjC
    class var swiftSharedInstance: DNL
    {
        struct Singleton
        {
            static let instance = DNL()
        }
        return Singleton.instance
    }
    
    // the sharedInstance class method can be reached from ObjC
    @objc open class func sharedInstance() -> DNL
    {
        return DNL.swiftSharedInstance
    }
    
    @objc public enum EDNLGesture: Int
    {
        case shake
        case custom
    }
    
    fileprivate var started: Bool = false
    fileprivate var presented: Bool = false
    fileprivate var enabled: Bool = false
    fileprivate var selectedGesture: EDNLGesture = .shake
    fileprivate var ignoredURLs = [String]()
    fileprivate var filters = [Bool]()
    fileprivate var lastVisitDate: Date = Date()
    internal var cacheStoragePolicy = URLCache.StoragePolicy.notAllowed

    @objc open func start()
    {
        guard !self.started else {
            showMessage("Already started!")
            return
        }

        self.started = true
        SocketIOManager.shared.connect()
        register()
        enable()
        clearOldData()
        showMessage("Started!")
    }
    
    @objc open func stop()
    {
        unregister()
        disable()
        clearOldData()
        self.started = false
        showMessage("Stopped!")
    }
    
    fileprivate func showMessage(_ msg: String) {
        print("DebugNetworkLib \(DNLVersion) - [https://github.com/padgithub/DebugNetworkLib]: \(msg)")
    }
    
    internal func isEnabled() -> Bool
    {
        return self.enabled
    }
    
    internal func enable()
    {
        self.enabled = true
    }
    
    internal func disable()
    {
        self.enabled = false
    }
    
    fileprivate func register()
    {
        URLProtocol.registerClass(DNLProtocol.self)
    }
    
    fileprivate func unregister()
    {
        URLProtocol.unregisterClass(DNLProtocol.self)
    }
    
    @objc func motionDetected()
    {
        guard self.started else { return }
        toggleDNL()
    }
    
    @objc open func isStarted() -> Bool {
        return self.started
    }
    
    @objc open func setCachePolicy(_ policy: URLCache.StoragePolicy) {
        cacheStoragePolicy = policy
    }
    
    @objc open func setGesture(_ gesture: EDNLGesture)
    {
        self.selectedGesture = gesture
    }
    
    @objc open func show()
    {
        guard self.started else { return }
        showDNL()
    }
    
    @objc open func hide()
    {
        guard self.started else { return }
        hideDNL()
    }

    @objc open func toggle()
    {
        guard self.started else { return }
        toggleDNL()
    }
    
    @objc open func ignoreURL(_ url: String)
    {
        self.ignoredURLs.append(url)
    }
    
    internal func getLastVisitDate() -> Date
    {
        return self.lastVisitDate
    }
    
    fileprivate func showDNL()
    {
        if self.presented {
            return
        }
        
        self.showDNLFollowingPlatform()
        self.presented = true

    }
    
    fileprivate func hideDNL()
    {
        if !self.presented {
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name.DNLDeactivateSearch, object: nil)
        self.hideDNLFollowingPlatform { () -> Void in
            self.presented = false
            self.lastVisitDate = Date()
        }
    }

    fileprivate func toggleDNL()
    {
        self.presented ? hideDNL() : showDNL()
    }
    
    internal func clearOldData()
    {
        DNLHTTPModelManager.sharedInstance.clear()
        do {
            let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!
            let filePathsArray = try FileManager.default.subpathsOfDirectory(atPath: documentsPath)
            for filePath in filePathsArray {
                if filePath.hasPrefix("DNL") {
                    try FileManager.default.removeItem(atPath: (documentsPath as NSString).appendingPathComponent(filePath))
                }
            }
            
            try FileManager.default.removeItem(atPath: DNLPath.SessionLog)
        } catch {}
    }
    
    func getIgnoredURLs() -> [String]
    {
        return self.ignoredURLs
    }
    
    func getSelectedGesture() -> EDNLGesture
    {
        return self.selectedGesture
    }
    
    func cacheFilters(_ selectedFilters: [Bool])
    {
        self.filters = selectedFilters
    }
    
    func getCachedFilters() -> [Bool]
    {
        if self.filters.count == 0 {
            self.filters = [Bool](repeating: true, count: HTTPModelShortType.allValues.count)
        }
        return self.filters
    }
    
}

#if os(iOS)

extension DNL {
    fileprivate var presentingViewController: UIViewController? {
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
		while let controller = rootViewController?.presentedViewController {
			rootViewController = controller
		}
        return rootViewController
    }

    fileprivate func showDNLFollowingPlatform()
    {
        let navigationController = UINavigationController(rootViewController: DNLListController_iOS())
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = UIColor.DNLOrangeColor()
        navigationController.navigationBar.barTintColor = UIColor.DNLStarkWhiteColor()
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.DNLOrangeColor()]
        
        if #available(iOS 13.0, *) {
            navigationController.presentationController?.delegate = self
        }

        presentingViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    fileprivate func hideDNLFollowingPlatform(_ completion: (() -> Void)?)
    {
        presentingViewController?.dismiss(animated: true, completion: { () -> Void in
            if let notNilCompletion = completion {
                notNilCompletion()
            }
        })
    }
}

extension DNL: UIAdaptivePresentationControllerDelegate {

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
    {
        guard self.started else { return }
        self.presented = false
    }
}

#endif
