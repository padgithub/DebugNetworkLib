//
//  DNLWindowController.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

#if os(OSX)
    
import Cocoa

protocol DNLWindowControllerDelegate {
    func httpModelSelectedDidChange(model: DNLHTTPModel)
}
    
class DNLWindowController: NSWindowController, NSWindowDelegate, DNLWindowControllerDelegate {
    
    @IBOutlet var settingsButton: NSButton!
    @IBOutlet var infoButton: NSButton!
    @IBOutlet var statisticsButton: NSButton!

    @IBOutlet var listView: NSView!
    @IBOutlet var detailsView: NSView!
    @IBOutlet var listViewController: DNLListController_OSX!
    @IBOutlet var detailsViewController: DNLDetailsController_OSX!
    
    @IBOutlet var settingsPopover: NSPopover!
    @IBOutlet var infoPopover: NSPopover!
    @IBOutlet var statisticsPopover: NSPopover!
    
    @IBOutlet var settingsViewController: DNLSettingsController_OSX!
    @IBOutlet var settingsView: NSView!

    @IBOutlet var infoViewController: DNLInfoController_OSX!
    @IBOutlet var infoView: NSView!
    
    @IBOutlet var statisticsViewController: DNLStatisticsController_OSX!
    @IBOutlet var statisticsView: NSView!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        settingsButton.image = NSImage(data: DNLAssets.getImage(.settings))
        infoButton.image = NSImage(data: DNLAssets.getImage(.info))
        statisticsButton.image = NSImage(data: DNLAssets.getImage(.statistics))

        listViewController.view = listView
        listViewController.delegate = self
        detailsViewController.view = detailsView
        
        settingsViewController.view = settingsView
        infoViewController.view = infoView
        statisticsViewController.view = statisticsView

        listViewController.reloadData()
        statisticsViewController.reloadData()
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
    }
    
    // MARK: NSWindowDelegate
    
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow , window == self.window {
            DNL.sharedInstance().windowDidClose()
        }
    }
    
    // MARK: Actions
    
    @IBAction func settingsClicked(sender: AnyObject?) {
        settingsPopover.show(relativeTo: NSZeroRect, of: settingsButton, preferredEdge: NSRectEdge.maxY)
    }
    
    @IBAction func infoClicked(sender: AnyObject?) {
        infoPopover.show(relativeTo: NSZeroRect, of: infoButton, preferredEdge: NSRectEdge.maxY)
    }
    
    @IBAction func statisticsClicked(sender: AnyObject?) {
        statisticsPopover.show(relativeTo: NSZeroRect, of: statisticsButton, preferredEdge: NSRectEdge.maxY)
    }

}
    
extension DNLWindowController {
    func httpModelSelectedDidChange(model: DNLHTTPModel) {
        self.detailsViewController.selectedModel(model)
    }
}

#endif
