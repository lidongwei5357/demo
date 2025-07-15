//
//  Target.swift
//  Diablo
//
//  Created by wangkun on 2018/3/12.
//  Copyright © 2018年 wangkun. All rights reserved.
//

import Foundation


public protocol ParameterEncoder {
    
    /// 根据输入参数产生一个用于服务端验证的token 或者 key 之类的字段
    ///
    /// - Parameter parameters: 输入参数
    /// - Returns: 一个key : value
    func accessToken(parameters: [String: Any]?) -> [String: Any]?
}



public protocol FGTarget: ParameterEncoder, NetWorkConfig {
    var headers: HTTPHeaders? { get }
    var acceptContentTypes: [String] { get }
    var requestTimeoutInterval: Int { get }
}

extension FGTarget {
    
    public var headers: [String: String]? {
        return nil
    }
    
    public var acceptContentTypes: [String] {
        return ["application/json", "text/html"]
    }
    
    public var requestTimeoutInterval: Int {
        return 60
    }
}
