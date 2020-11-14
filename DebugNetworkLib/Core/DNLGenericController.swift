//
//  DNLGenericController.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

class DNLGenericController: DNLViewController
{
    var selectedModel: DNLHTTPModel = DNLHTTPModel()

    override func viewDidLoad()
    {
        super.viewDidLoad()
    #if os(iOS)
        self.edgesForExtendedLayout = UIRectEdge.all
        self.view.backgroundColor = DNLColor.DNLGray95Color()
    #elseif os(OSX)
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = DNLColor.DNLGray95Color().cgColor
    #endif
    }
    
    func selectedModel(_ model: DNLHTTPModel)
    {
        self.selectedModel = model
    }
    
    func formatDNLString(_ string: String) -> NSAttributedString
    {
        var tempMutableString = NSMutableAttributedString()
        tempMutableString = NSMutableAttributedString(string: string)
        
        let l = string.count
        
        let regexBodyHeaders = try! NSRegularExpression(pattern: "(\\-- Body \\--)|(\\-- Headers \\--)", options: NSRegularExpression.Options.caseInsensitive)
        let matchesBodyHeaders = regexBodyHeaders.matches(in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, l)) as Array<NSTextCheckingResult>
        
        for match in matchesBodyHeaders {
            tempMutableString.addAttribute(.font, value: DNLFont.DNLFontBold(size: 14), range: match.range)
            tempMutableString.addAttribute(.foregroundColor, value: DNLColor.DNLOrangeColor(), range: match.range)
        }
        
        let regexKeys = try! NSRegularExpression(pattern: "\\[.+?\\]", options: NSRegularExpression.Options.caseInsensitive)
        let matchesKeys = regexKeys.matches(in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, l)) as Array<NSTextCheckingResult>
        
        for match in matchesKeys {
            tempMutableString.addAttribute(.foregroundColor, value: DNLColor.DNLBlackColor(), range: match.range)
            tempMutableString.addAttribute(.link,
                                           value: (string as NSString).substring(with: match.range),
                                           range: match.range)
        }
        
        return tempMutableString
    }
    
    @objc func reloadData()
    {
    }
}
