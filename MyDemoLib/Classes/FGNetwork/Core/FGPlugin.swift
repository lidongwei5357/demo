//
//  Plugin.swift
//  Diablo
//
//  Created by wangkun on 2018/3/12.
//  Copyright © 2018年 wangkun. All rights reserved.
//

import Foundation

public protocol FGPlugin {
 
    func willSend(request: FGRequest, dataRequest: DataRequest)
    
    func didReceive(request: URLRequest?, response: HTTPURLResponse?, data: Result<Data>?)

}


public struct LoggerPlugin: FGPlugin {

    public init(){}
    
    func printURL(request: URLRequest?) -> String {
        let hostHeader = request?.allHTTPHeaderFields?["Host"]
        let urlString =  request?.url?.absoluteString
        let hostString = request?.url?.host
        if let hostField = hostHeader, let url = urlString, let host = hostString {
            return url.replacingOccurrences(of: host, with: hostField)
        } else {
            return urlString ?? ""
        }
    }

    public func willSend(request: FGRequest, dataRequest: DataRequest) {
        var message = "\n-> -> -> -> -> -> -> -> -> -> -> -> -> -> ->\n"
        
        message += "[REQUEST:] \(request.method) \(request.baseURL + request.routerURL)\n"
        message += "\n[必须参数:]\n"
        if let required = request.requiredParameter {
            message += "\(printDic(dic: required))\n"
        }
        message += "\n[可选参数:]\n"
        if let optional = request.optionalParameter {
            message += "\(printDic(dic: optional))\n"
        }
        
        message += "[DATAREQUEST:]\n\(printURL(request: dataRequest.request))\n"
        message += "<- <- <- <- <- <- <- <- <- <- <- <- <- <- <-\n"
        print(message)
    }
    
    public func didReceive(request: URLRequest?, response: HTTPURLResponse?, data: Result<Data>?) {
        guard let request = request else { return }
        guard let response = response else { return }
        let url = self.printURL(request: request)
        var message = "\n-> -> -> -> -> -> -> -> -> -> -> -> -> -> ->\n"
        message += "[RESPONSE:] \(request.httpMethod ?? "--") [HTTPCODE:] \(response.statusCode)\n[URL:]\n\(url)\n"
        if let body = request.httpBody {
            message += "[BODY:]\n\(body)"
        }
        guard let data = data else { return }
        switch data {
        case .success(let result):
            guard let json = try? JSONSerialization.jsonObject(with: result, options: .allowFragments) else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else { return }
            let string = String(data: data, encoding: .utf8)
            message += "\n[DATA:]\n\(string ?? "--")\n"
        case .failure(let error):
            message += "\n[ERROR:]\(error)) \n"
        }
        message += "\n<- <- <- <- <- <- <- <- <- <- <- <- <- <- <-\n"
        print(message)
    }
    
    private func printDic(dic: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted) else { return  "" }
        if let string = String(data: data, encoding: .utf8) {
            return string
        } else {
            return ""
        }
        
    }
}
