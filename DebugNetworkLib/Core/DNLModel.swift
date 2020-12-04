//
//  DNLRequestData.swift
//  DebugNetworkLib
//
//  Created by Phung Anh Dung on 11/5/20.
//

import UIKit

class DNLRequestInfo: Codable {
    
    var id: String
    var date: String
    var url: String
    var statusCode: Int
    var method: String
    var userAgent: String
    var authorize: String
    var httpBody: String
    var data: String
    var deviceInfo: String = UIDevice.getDNLDeviceType()
    var deviceIdentifier: String = "\(UIDevice.current.identifierForVendor?.uuidString ?? "")"
        
    init(id: String, date: String) {
        self.id = id
        self.date = date
        self.url = ""
        self.statusCode = 0
        self.method = ""
        self.userAgent = ""
        self.authorize = ""
        self.httpBody = ""
        self.data = ""
    }
    
    init(id: String, date: String, url: String, statusCode: Int, method: String, userAgent: String, authorize: String, httpBody: String, data: String) {
        self.id = id
        self.date = date
        self.url = url
        self.statusCode = statusCode
        self.method = method
        self.userAgent = userAgent
        self.authorize = authorize
        self.httpBody = httpBody
        self.data = data
    }
    
    func getJsonResponseData() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return [:] }
        guard let json = jsonObject as? [String: Any] else { return [:] }
        return json
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case date = "date"
        case url = "url"
        case statusCode = "status_code"
        case method = "method"
        case userAgent = "user_agent"
        case authorize = "authorize"
        case httpBody = "http_body"
        case data = "data"
        case deviceInfo = "device_info"
        case deviceIdentifier = "device_identifier"
    }
    
}

enum DNLDataResponseParser {
    
    static func parse(data: Data?) -> DNLDataResponseType {
        guard let data = data else { return .unknown }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return .json(value: jsonString)
                }
            }
        } else if let dataString = String(data: data, encoding: .utf8) {
            return .string(value: dataString)
        } else if let htmlString = try? NSMutableAttributedString(data: data,
                                                                  options: [:],
                                                                  documentAttributes: nil) {
            return .html(value: htmlString)
        }
        return .unknown
    }
    
}

enum DNLDataResponseType {
    case json(value: String)
    case html(value: NSMutableAttributedString)
    case string(value: String)
    case unknown
}

extension DNLDataResponseType {
        
    var description: String {
        switch self {
        case .json(let value):
            return value
        case .html(let value):
            return value.string
        case .string(let value):
            return value
        case .unknown:
            return ""
        }
    }
    
}
