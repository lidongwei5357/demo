//
//  ACDMAPI.swift
//  Alamofire
//
//  Created by wangkun on 2018/4/11.
//

import Foundation
import Alamofire

//public enum FGAPI {
//    public static func request(_ request: FGRequest, plugins: [FGPlugin] = [FGPlugin]()) -> RequestContainer {
//        return FGSessionManager.sharedManager.request(request, plugins: plugins)
//    }
//}

public class FGSessionManager {
    public static var timeoutIntervalForRequest: TimeInterval = 60
    public static var timeoutIntervalForResource: TimeInterval = 604800 //默认值7天
    public static let sharedManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = timeoutIntervalForResource

        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
}


public func request(_ request: FGRequest, plugins: [FGPlugin] = [FGPlugin]()) -> RequestContainer {
    let target = request.target
    let url = request.baseURL + request.routerURL
    var dic = request.requiredParameter
    if request.isNeedToken {
        if let token = target.accessToken(parameters: dic) {
            dic?.merge(token, uniquingKeysWith: { (_, new) in new})
        }
    }
    if let optionDic = request.optionalParameter {
        dic?.merge(optionDic, uniquingKeysWith: { (_, new) in new})
    }

    var plugins = plugins
//    if request.isNeedLog && request.target.isDebug {
        plugins.append(LoggerPlugin())
//    }
    let dataRequest = FGSessionManager.sharedManager.request(url, method: request.method, parameters: dic, headers: target.headers)
    plugins.forEach { $0.willSend(request: request, dataRequest: dataRequest)}
    return RequestContainer.init(dataRequest: dataRequest, target: target, plugins: plugins)
}

public func upload(_ request: FGRequest,
                   fileName: String,
                   mimeType: String,
                   plugins: [FGPlugin] = [FGPlugin](),
                   block: @escaping (_ result: Result<RequestContainer>)->Void,
                   progressBlock: ((_ progress: Progress)->Void)? = nil) {
    let target = request.target
    let url = request.baseURL + request.routerURL
    var dic = request.requiredParameter
    if request.isNeedToken {
        if let token = target.accessToken(parameters: dic) {
            dic?.merge(token, uniquingKeysWith: { (_, new) in new})
        }
    }
    if let optionDic = request.optionalParameter {
        dic?.merge(optionDic, uniquingKeysWith: { (_, new) in new})
    }

    var plugins = plugins
    if request.isNeedLog && request.target.isDebug {
        plugins.append(LoggerPlugin())
    }

    Alamofire.upload(multipartFormData: { (multipartFormData) in
        dic?.forEach({ (key, value) in
            if let s = value as? String {
                if let data = s.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            } else if let n = value as? NSNumber {
                if let data = n.stringValue.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            } else if let d = value as? Data {
                multipartFormData.append(d, withName: key, fileName: fileName, mimeType: mimeType)
            }
        })
    },
                     to: url,
                     encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(request: let uploadRequset, streamingFromDisk: _, streamFileURL: _):
                            let container = RequestContainer.init(dataRequest: uploadRequset, target: target, plugins: plugins)
                            block(Result.success(container))
                            uploadRequset.uploadProgress(closure: { (progress) in
                                progressBlock?(progress)
                            })
                        case .failure(let error):
                            block(Result.failure(error))
                        }
                        
    })

}



 


