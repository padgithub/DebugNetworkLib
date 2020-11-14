//
//  DNLInfoController.swift
//  DebugNetworkLib
//
//  Copyright © 2020 DebugNetworkLib. All rights reserved.
//
    
import Foundation

class DNLInfoController: DNLGenericController
{
    
    func generateInfoString(_ ipAddress: String) -> NSAttributedString
    {
        var tempString: String
        tempString = String()
        
        tempString += "[App name] \n\(DNLDebugInfo.getDNLAppName())\n\n"
        
        tempString += "[App version] \n\(DNLDebugInfo.getDNLAppVersionNumber()) (build \(DNLDebugInfo.getDNLAppBuildNumber()))\n\n"
        
        tempString += "[App bundle identifier] \n\(DNLDebugInfo.getDNLBundleIdentifier())\n\n"

        tempString += "[Device OS] \niOS \(DNLDebugInfo.getDNLOSVersion())\n\n"

        tempString += "[Device type] \n\(DNLDebugInfo.getDNLDeviceType())\n\n"

        tempString += "[Device screen resolution] \n\(DNLDebugInfo.getDNLDeviceScreenResolution())\n\n"
        
        tempString += "[Device IP address] \n\(ipAddress)\n\n"

        return formatDNLString(tempString)
    }
}
