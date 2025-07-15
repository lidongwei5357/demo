//
//  FGNetworkConfig.swift
//  FGCore
//
//  Created by kun wang on 2018/7/31.
//

import Foundation

public protocol NetWorkConfig {
    var isDebug: Bool { get }
    var baseURL: String { get }
    var sinatureKey: String? { get }
    var requiredDic: [String: Any] { get }
    var optionalDic: [String: Any] { get }
    var commonErrorHandler: ((_ errorCode: Int) -> Void)? { get }
    var p12Path: String? { get }
    var p12AccessKey: String? { get }
}

@objc public class FGNetworkConfig: NSObject, NetWorkConfig {
    @objc public let isDebug: Bool

    @objc public let baseURL: String

    @objc public let sinatureKey: String?

    @objc public let requiredDic: [String: Any]

    @objc public let optionalDic: [String: Any]

    @objc public let commonErrorHandler: ((Int) -> Void)?

    @objc public let p12Path: String?

    @objc public let p12AccessKey: String?

    @objc public init(isDebug: Bool,
                      baseURL: String,
                      sinatureKey: String?,
                      requiredDic: [String: Any],
                      optionalDic: [String: Any],
                      commonErrorHandler: ((Int) -> Void)?,
                      p12Path: String?,
                      p12AccessKey: String?) {
        self.isDebug = isDebug
        self.baseURL = baseURL
        self.sinatureKey = sinatureKey
        self.requiredDic = requiredDic
        self.optionalDic = optionalDic
        self.commonErrorHandler = commonErrorHandler
        self.p12AccessKey = p12AccessKey
        self.p12Path = p12Path
        super.init()
    }
}
