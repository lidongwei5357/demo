//
//  Parameter.swift
//  Diablo
//
//  Created by wangkun on 2018/3/12.
//  Copyright © 2018年 wangkun. All rights reserved.
//

import Foundation


/// 一个请求的参数
public protocol FGParameter {

    /// 一个Request的baseURL
    var baseURL: String { get }

    /// 一个Request的router
    var routerURL: String { get }

    /// 一个Request的传入参数, 必传参数和可选参数
    var requiredParameter: [String: Any]? { get }
    var optionalParameter: [String: Any]? { get }

    // 一个Request的http请求方式
    var method: HTTPMethod { get }

    var stubData: Data? { get }

    // 一个Request的
    var target: FGTarget { get }
}

extension FGParameter {
    public var stubData: Data? {
        return nil
    }
}


public protocol FGRequest: FGParameter  {
    var isNeedToken: Bool { get }
    var isNeedLog: Bool { get }
}
 
extension FGRequest {
    public var isNeedToken: Bool { return true }
    public var isNeedLog: Bool { return true }
}

public struct RequestContainer: RequestContainerTrait {
    public let dataRequest: DataRequest
    public let target: FGTarget
    public let plugins: [FGPlugin]

}

public protocol RequestContainerTrait {
    var dataRequest: DataRequest { get}

    var target: FGTarget { get }
    var plugins: [FGPlugin] { get}
}

public protocol DecryptConfig {
    var isNeedDecrypt: Bool { get }
}

 
