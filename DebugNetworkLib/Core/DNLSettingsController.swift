//
//  DNLSettingsController.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//
    
import Foundation

class DNLSettingsController: DNLGenericController {
    // MARK: Properties

    let DNLVersionString = "DebugNetworkLib - \(DNLVersion)"
    var DNLURL = "https://github.com/padgithub/DebugNetworkLib"
    
    var tableData = [HTTPModelShortType]()
    var filters = [Bool]()
}
