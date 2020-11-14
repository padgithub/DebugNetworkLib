//
//  DNL.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

import Foundation
#if os(OSX)
import Cocoa
#else
import UIKit
#endif

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
    #if os(OSX)
        var windowController: DNLWindowController?
        let mainMenu: NSMenu? = NSApp.mainMenu?.items[1].submenu
        var DNLMenuItem: NSMenuItem = NSMenuItem(title: "DebugNetworkLib", action: #selector(DNL.show), keyEquivalent: String.init(describing: (character: NSF9FunctionKey, length: 1)))
    #endif
    
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
    #if os(OSX)
        self.addDebugNetworkLibToMainMenu()
    #endif
    }
    
    @objc open func stop()
    {
        unregister()
        disable()
        clearOldData()
        self.started = false
        showMessage("Stopped!")
    #if os(OSX)
        self.removeDebugNetworkLibFromMainmenu()
    #endif
    }
    
    fileprivate func showMessage(_ msg: String) {
        print("DebugNetworkLib \(DNLVersion) - [https://github.com/kasketis/DebugNetworkLib]: \(msg)")
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
    #if os(OSX)
        if gesture == .shake {
            self.addDebugNetworkLibToMainMenu()
        } else {
            self.removeDebugNetworkLibFromMainmenu()
        }
    #endif
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

#elseif os(OSX)
    
extension DNL {
    
    public func windowDidClose() {
        self.presented = false
    }
    
    private func setupDebugNetworkLibMenuItem() {
        self.DNLMenuItem.target = self
        self.DNLMenuItem.action = #selector(DNL.motionDetected)
        self.DNLMenuItem.keyEquivalent = "n"
        self.DNLMenuItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(rawValue: UInt(Int(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue)))
    }
    
    public func addDebugNetworkLibToMainMenu() {
        self.setupDebugNetworkLibMenuItem()
        if let menu = self.mainMenu {
            menu.insertItem(self.DNLMenuItem, at: 0)
        }
    }
    
    public func removeDebugNetworkLibFromMainmenu() {
        if let menu = self.mainMenu {
            menu.removeItem(self.DNLMenuItem)
        }
    }
    
    public func showDNLFollowingPlatform()  {
        if self.windowController == nil {
            #if swift(>=4.2)
            let nibName = "DebugNetworkLibWindow"
            #else
            let nibName = NSNib.Name(rawValue: "DebugNetworkLibWindow")
            #endif

            self.windowController = DNLWindowController(windowNibName: nibName)
        }
        self.windowController?.showWindow(nil)
    }
    
    public func hideDNLFollowingPlatform(completion: (() -> Void)?)
    {
        self.windowController?.close()
        if let notNilCompletion = completion {
            notNilCompletion()
        }
    }
}
    
#endif
