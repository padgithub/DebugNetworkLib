//
//  DNLRequestData.swift
//  DebugNetworkLib
//
//  Created by Phung Anh Dung on 11/5/20.
//

import Foundation

extension Notification.Name {
    static let requestTimeOut = Notification.Name("requestTimeOut")
}

class DNLRequestData {
    
    let id: String = UUID().uuidString
    var urlSessionDataTask: URLSessionDataTask?
    var timer = Timer()
    var response = URLResponse()
    var data = Data()
    var defaultTimeOut = 5
    var message: String?
    
    init(urlSessionDataTask: URLSessionDataTask, data: Data ) {
        self.urlSessionDataTask = urlSessionDataTask
        self.data = data
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
        
    init(message: String?) {
        self.message = message
    }
    
    @objc private func handleTimer() {
        if defaultTimeOut > 0 {
            defaultTimeOut -= 1
        } else {
            timer.invalidate()
            NotificationCenter.default.post(name: .requestTimeOut, object: self)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func appendData(newData: Data) {
        data.append(newData)
    }
    
    func getJsonResponseData() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(getResponse()) else { return [:] }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return [:] }
        guard let json = jsonObject as? [String: Any] else { return [:] }
        return json
    }
    
    func getJsonMessageData() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(getMessage()) else { return [:] }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return [:] }
        guard let json = jsonObject as? [String: Any] else { return [:] }
        return json
    }
    
    private func getResponse() -> DNLRequestInfo {
        let dataResponse = DNLRequestInfo(id: id, date: getDate())
        dataResponse.url = urlSessionDataTask?.originalRequest?.url?.absoluteString ?? ""
        if let httpURLResponse = response as? HTTPURLResponse {
            dataResponse.statusCode = httpURLResponse.statusCode
        }
        dataResponse.userAgent = urlSessionDataTask?.currentRequest?.allHTTPHeaderFields?["User-Agent"] ?? ""
        dataResponse.authorize = urlSessionDataTask?.currentRequest?.allHTTPHeaderFields?["Authorization"] ?? ""
        dataResponse.method = urlSessionDataTask?.originalRequest?.httpMethod ?? ""
        dataResponse.httpBody =  DNLDataResponseParser.parse(data: urlSessionDataTask?.originalRequest?.httpBody).description
        dataResponse.data = DNLDataResponseParser.parse(data: data).description
        return dataResponse
    }
    
    private func getMessage() -> DNLRequestInfo {
        let dataResponse = DNLRequestInfo(id: id, date: getDate())
        dataResponse.data = message ?? "No Message"
        return dataResponse
    }
    
    private func getDate() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        return dateFormatter.string(from: Date())
    }
        
}

extension DNLRequestData: Equatable {
    static func ==(lhs: DNLRequestData, rhs: DNLRequestData) -> Bool {
        return lhs.urlSessionDataTask == rhs.urlSessionDataTask
    }
}

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
    var deviceInfo: String = ""
    var deviceIdentifier: String = ""
        
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
