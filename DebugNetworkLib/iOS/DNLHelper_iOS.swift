//
//  DNLHelper.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

#if os(iOS)

import UIKit

#if swift(>=4.2)
public typealias UIEventSubtype = UIEvent.EventSubtype
#endif

extension UIWindow {
    override open func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?)
    {
        if DNL.sharedInstance().getSelectedGesture() == .shake {
            if (event!.type == .motion && event!.subtype == .motionShake) {
                DNL.sharedInstance().motionDetected()
            }
        } else {
            super.motionEnded(motion, with: event)
        }
    }
}

public extension UIDevice
{
    class func getDNLDeviceType() -> String
    {
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion) \(UIDevice.current.name)"
    }
}

#endif

protocol DataCleaner {

    func clearData(sourceView: UIView, originingIn sourceRect: CGRect?, then: @escaping () -> ())
}

extension DataCleaner where Self: UIViewController {

    func clearData(sourceView: UIView, originingIn sourceRect: CGRect?, then: @escaping () -> ())
    {
        let actionSheetController: UIAlertController = UIAlertController(title: "Clear data?", message: "", preferredStyle: .actionSheet)
        actionSheetController.popoverPresentationController?.sourceView = sourceView
        if let sourceRect = sourceRect {
            actionSheetController.popoverPresentationController?.sourceRect = sourceRect
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        actionSheetController.addAction(cancelAction)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            DNL.sharedInstance().clearOldData()
            then()
        }
        actionSheetController.addAction(yesAction)

        let noAction = UIAlertAction(title: "No", style: .default) { _ in }
        actionSheetController.addAction(noAction)

        self.present(actionSheetController, animated: true, completion: nil)
    }
}
