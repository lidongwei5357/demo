//
//  BaseRequest.swift
//  FGNetwork
//
//  Created by kun wang on 2018/12/25.
//

import Foundation

public class FGCoreConfig {

    public static var shared = FGCoreConfig()
    private init() { }

    public var acdmTarget: ACDMTarget = ACDMTarget.init(baseURL: "")

    public var userProxyTarget: ACDMTarget = ACDMTarget.init(baseURL: "")
}


public protocol ProxyRequest: FGRequest {

}

public extension ProxyRequest {
    var method: HTTPMethod {
        return target.isDebug ? .get : .post
    }

    var baseURL: String {
        return target.baseURL
    }

    var optionalParameter: [String: Any]? {
        return target.optionalDic
    }

    var target: FGTarget {
        return FGCoreConfig.shared.userProxyTarget
    }
}

public protocol BaseRequest: FGRequest {

}

public extension BaseRequest {
    var method: HTTPMethod {
        return target.isDebug ? .get : .post
    }

    var baseURL: String {
        return target.baseURL
    }

    var optionalParameter: [String: Any]? {
        return target.optionalDic
    }

    var target: FGTarget {
        return FGCoreConfig.shared.acdmTarget
    }
}

