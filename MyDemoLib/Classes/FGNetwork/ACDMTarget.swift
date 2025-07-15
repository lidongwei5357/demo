//
//  ACDMAPI.swift
//  Diablo
//
//  Created by wangkun on 2018/3/16.
//  Copyright © 2018年 wangkun. All rights reserved.
//

import Foundation

public protocol ACDMDecrypt {
    
    /// 解密http结果，如果不需要，return原数据
    ///
    /// - Parameter data: 未解密数据
    /// - Returns: 已解密数据
    func decrypt(data: ACDMResult) -> Result<Data>
    
    /// 解压http结果，如果不需要，return原数据
    ///
    /// - Parameter data: 未解压数据
    /// - Returns: 已解压数据
//    func upZip(data: Result<Data>) -> Result<Data>
    
//    /// <#Description#>
//    ///
//    /// - Parameters:
//    ///   - type: <#type description#>
//    ///   - data: <#data description#>
//    /// - Returns: <#return value description#>
//    func decode<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T>
}


public struct ACDMResult: Decodable {
    let key: String
    let iv: String
    let data: String
    let version: String?
}


public struct ACDMBody<T: Decodable>: Decodable {
    let code: Int
    let data: T
    let msg: String?

    fileprivate enum CodingKeys: String, CodingKey {
        case code
        case data
        case msg
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decodeSafeIfPresent(Int.self, forKey: .code) ?? 0
        data = try container.decode(T.self, forKey: .data)
        msg = try container.decodeSafeIfPresent(String.self, forKey: .msg)
    }
}
 
public struct ACDMNull: Decodable { }


public struct ACDMResponeConfig: DecryptConfig {
    public init(){}
    public var isNeedDecrypt: Bool = true
}

public struct ACDMTarget: FGTarget, ACDMDecrypt {
//    public var headers: HTTPHeaders?
    public let isDebug: Bool
    
    public let baseURL: String
    
    public let sinatureKey: String?

    public let requiredDic: [String : Any]
    
    public let optionalDic: [String : Any]
    
    public let commonErrorHandler: ((Int) -> Void)?
    
    public let p12Path: String?
    
    public let p12AccessKey: String?

    private let rsaDecryptor: FGRSACrypt

    public init(isDebug: Bool = false,
                baseURL: String,
                sinatureKey: String? = nil,
                requiredDic: [String: Any] = [:],
                optionalDic: [String: Any] = [:],
                commonErrorHandler: ((Int) -> Void)? = nil,
                p12Path: String? = nil,
                p12AccessKey: String? = nil) {

        self.isDebug = isDebug
        self.baseURL = baseURL
        self.sinatureKey = sinatureKey
        self.requiredDic = requiredDic
        self.optionalDic = optionalDic
        self.commonErrorHandler = commonErrorHandler
        self.p12Path = p12Path
        self.p12AccessKey = p12AccessKey
        self.rsaDecryptor = FGRSACrypt()
        if let p12 = self.p12Path, !p12.isEmpty {
            rsaDecryptor.loadPrivateKey(fromFile: self.p12Path, password: self.p12AccessKey)
        }
    }
    
    public func accessToken(parameters: [String: Any]?) -> [String: Any]? {
        guard let dic = parameters else { return nil }
 
        //自然排序
        let sortedKeys = dic.keys.sorted()

        //拼接signature
        guard var signatureString = self.sinatureKey else { return nil }
        
        for item in sortedKeys {
            var content = ""
            if dic[item] is NSNumber {
                let number = dic[item] as? NSNumber
                content = number?.stringValue ?? ""
            } else {
                content = dic[item] as? String ?? ""
            }
            signatureString = signatureString + "&"
            signatureString = signatureString + (item + "=" + content)
        }
        //md5 signature
        let signatureMD5String = signatureString.md5()
        return ["key" : signatureMD5String ?? ""]
    }
    
    
    /// 1. 将服务器响应的JSON(字符串)"key"对象中的数据(解密密钥的密文)使用base64对数据进行解码，然后使用RSA私钥解密，得到请求结果数据密文的解密密钥
    ///2. 将请求结果数据密文(服务器响应的JSON的“data”对象)使用base64解码
    ///3. 将初始IV密文(服务器响应的JSON的“iv”对象)使用base64解码
    ///4. 将服务器响应的JSON(字符串)"data"对象中的数据使用上面得到的解密密钥和初始向量IV，配合AES解密算法，得到解密后的请求结果数据
    ///5. 解压
    /// - Parameter data: <#data description#>
    /// - Returns: <#return value description#>
    public func decrypt(data: ACDMResult) -> Result<Data> {
        let aesKey = rsaDecryptor.rsaDecryptString(data.key)
        guard let aesPrivateKey = aesKey else { return Result.failure(FGError.decryptError(reason: .rsa)) }
        let ivData = Data(base64Encoded: data.iv, options: .ignoreUnknownCharacters)
        let contentData = Data(base64Encoded: data.data, options: .ignoreUnknownCharacters)
        let keyData = aesPrivateKey.data(using: .utf8)
        let jsonData = FGAESCrypt.decryptData(contentData, key: keyData, iv: ivData)
        guard let result = jsonData else { return Result.failure(FGError.decryptError(reason: .aes)) }
        
        //一个特殊步骤，去除解密产生的控制字符
 
        if let _ = data.version {
            let unzippedData = (result as NSData).vz_unzip()
            if let unzippedData = unzippedData {
                return trim(data: unzippedData)
            } else {
                return Result.failure(FGError.decryptError(reason: .unzip))
            }
        } else {
            return trim(data: result)
        }
 
    }
    
    func trim(data: Data) -> Result<Data> {
        var resultString = String(data: data, encoding: .utf8)
        resultString = resultString?.trimmingCharacters(in: CharacterSet.controlCharacters)
        let trimedData = resultString?.data(using: .utf8)
        if let data = trimedData {
            return Result.success(data)
        } else {
            return Result.failure(FGError.decryptError(reason: .trim))
        }
    }

}
