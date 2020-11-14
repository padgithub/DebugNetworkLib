//
//  DNLConstants.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

#if os(iOS)
import UIKit

typealias DNLColor = UIColor
typealias DNLFont = UIFont
typealias DNLImage = UIImage
typealias DNLViewController = UIViewController
    
#elseif os(OSX)
import Cocoa

typealias DNLColor = NSColor
typealias DNLFont = NSFont
typealias DNLImage = NSImage
typealias DNLViewController = NSViewController
#endif
