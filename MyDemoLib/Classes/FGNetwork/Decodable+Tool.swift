//
//  Decodable+Tool.swift
//  FYGOMS
//
//  Created by wangkun on 2018/4/11.
//  Copyright © 2018年 feeyo. All rights reserved.
//

import Foundation

extension Double {
    public func convertToDate() -> Date {
        return Date.init(timeIntervalSince1970: self)
    }
}

extension KeyedDecodingContainer {
    public func decodeSafeIfPresent(_ type: String.Type, forKey key: K) throws -> String? {
        if let value = try? decode(type, forKey: key) {
            if value.isEmpty {
                return nil
            } else {
                return value
            }
        }
        if let value = try? decode(Int.self, forKey: key) {
            return String(value)
        }
        if let value = try? decode(Double.self, forKey: key) {
            return String(value)
        }
        return nil
    }
    
    public func decodeSafeIfPresent(_ type: Int.Type, forKey key: K) throws -> Int? {
        if let value = try? decode(type, forKey: key) {
            return value
        }
        if let value = try? decode(String.self, forKey: key) {
            return Int(value)
        }
        return nil
    }
    
    public func decodeSafeIfPresent(_ type: Float.Type, forKey key: K) throws -> Float? {
        if let value = try? decode(type, forKey: key) {
            return value
        }
        if let value = try? decode(String.self, forKey: key) {
            return Float(value)
        }
        return nil
    }
    
    public func decodeSafeIfPresent(_ type: Bool.Type, forKey key: K) throws -> Bool? {
        if let value = try? decode(type, forKey: key) {
            return value
        }
        if let value = try? decode(String.self, forKey: key) {
            if let valueInt = Int(value) {
                return Bool(valueInt != 0)
            }
            return nil
        }
        if let value = try? decode(Int.self, forKey: key) {
            return Bool(value != 0)
        }
        return nil
    }
    
    public func decodeSafeIfPresent(_ type: Double.Type, forKey key: K) throws -> Double? {
        if let value = try? decode(type, forKey: key) {
            return value
        }
        if let value = try? decode(String.self, forKey: key) {
            return Double(value)
        }
        return nil
    }
    
    public func decodeSafeIfPresent(_ type: [Int].Type, forKey key: K) throws -> [Int]? {
        if let value = try? decode(type, forKey: key) {
            return value
        }
        if let value = try? decode([String].self, forKey: key) {
            return value.map { Int($0) ?? 0 }
        }
        return nil
    }
    
    public func decodeSafeIfPresent(_ type: [Double].Type, forKey key: K) throws -> [Double]? {
        if let value = try? decode(type, forKey: key) {
            return value
        }
        if let value = try? decode([String].self, forKey: key) {
            return value.map { Double($0) ?? 0.0 }
        }
        return nil
    }
    
    public func decodeSafeIfPresent(_ type: [String].Type, forKey key: K) throws -> [String]? {
        if let value = try? decode(type, forKey: key) {
            return value
        }
        if let value = try? decode([Int].self, forKey: key) {
            return value.map { String($0) }
        }
        if let value = try? decode([Double].self, forKey: key) {
            return value.map { String($0) }
        }
        return nil
    }
    
    public func decodeSafeIfPresent<T>(_ type: T.Type, forKey key: K) throws -> T? where T : Decodable {
        return try? decode(type, forKey: key)
    }
}
