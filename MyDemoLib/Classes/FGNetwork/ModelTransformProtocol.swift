//
//  ModelTransformProtocol.swift
//  FYGOMS
//
//  Created by zhmch on 2018/3/19.
//  Copyright © 2018年 feeyo. All rights reserved.
//

import Foundation

public protocol ModelInitializProtocol {
    init(fromDictionary dictionary: [String: Any])
}

public protocol ModelTransformProtocol: ModelInitializProtocol {
    associatedtype ObjectType = Self

    static func model(fromResult result: Any) -> ObjectType?
    static func modelArray(fromResult result: Any) -> [ObjectType]
}

public extension ModelTransformProtocol {
    static func model(fromResult result: Any) -> Self? {
        return modelArray(fromResult: result).first
    }

    static func modelArray(fromResult result: Any) -> [Self] {
        if let dic = result as? [String: Any] {
            return [Self.init(fromDictionary: dic)]
        } else if let array = result as? [[String: Any]] {
            return array.map({ Self.init(fromDictionary: $0) })
        }
        return [Self]()
    }
}

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    func int(forKey key: Key, defaultValue: Int = 0) -> Int {
        guard let value = self[key], !(value.self is NSNull) else {
            return defaultValue
        }
        if let retValue = value as? Int {
            return retValue
        } else if let retValue = value as? Double {
            return Int(retValue)
        } else if let retValue = value as? String {
            return Int(retValue) ?? defaultValue
        }
        return defaultValue
    }

    func double(forKey key: Key, defaultValue: Double = 0.0) -> Double {
        guard let value = self[key], !(value.self is NSNull) else {
            return defaultValue
        }
        if let retValue = value as? Double {
            return retValue
        } else if let retValue = value as? Int {
            return Double(retValue)
        } else if let retValue = value as? String {
            return Double(retValue) ?? defaultValue
        }
        return defaultValue
    }

    func bool(forKey key: Key, defaultValue: Bool = false) -> Bool {
        guard let value = self[key], !(value.self is NSNull) else {
            return defaultValue
        }
        if let retValue = value as? String {
            let booleans = ["false", "no", "0"]
            return !booleans.contains(retValue.lowercased())
        } else if let retValue = value as? Int {
            return retValue != 0
        }
        return defaultValue
    }

    func string(forKey key: Key, defaultValue: String = "") -> String {
        guard let value = self[key], !(value.self is NSNull) else {
            return defaultValue
        }
        if let retValue = value as? String {
            return retValue
        } else {
            return "\(value)"
        }
    }

    func array<T>(forKey key: Key) -> [T] {
        if let value = self[key] as? [T] {
            return value
        }
        return [T]()
    }

    func date(forKey key: Key, defaultValue: Date? = nil) -> Date? {
        guard let value = self[key], !(value.self is NSNull) else {
            return defaultValue
        }
        if let retValue = value as? String {
            let time = Double(retValue) ?? 0
            return Date(timeIntervalSince1970: time)
        } else if let retValue = value as? Int {
            return Date(timeIntervalSince1970: Double(retValue))
        } else if let retValue = value as? Double {
            return Date(timeIntervalSince1970: retValue)
        }
        return defaultValue
    }

    func dateFormat(forKey key: Key, dateFormat: DateFormatter, defaultValue: String = "--:--") -> String {
        if let date = date(forKey: key) {
            return dateFormat.string(from: date)
        }
        return defaultValue
    }

    func model<T: ModelInitializProtocol>(forKey key: Key) -> T? {
        if let dic = self[key] as? [String: Any] {
            return T(fromDictionary: dic)
        }
        return nil
    }

    func modelArray<T: ModelInitializProtocol>(forKey key: Key) -> [T] {
        var list = [T]()
        if let listArray = self[key] as? [[String: Any]] {
            for dic in listArray {
                list.append(T(fromDictionary: dic))
            }
        }
        return list
    }
}
