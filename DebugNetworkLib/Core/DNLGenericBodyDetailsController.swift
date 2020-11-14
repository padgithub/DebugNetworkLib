//
//  DNLGenericBodyDetailsController.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//

import Foundation

enum DNLBodyType: Int
{
    case request  = 0
    case response = 1
}

class DNLGenericBodyDetailsController: DNLGenericController
{
    var bodyType: DNLBodyType = DNLBodyType.response
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
