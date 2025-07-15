//
//  Error.swift
//  Diablo
//
//  Created by wangkun on 2018/3/13.
//  Copyright © 2018年 wangkun. All rights reserved.
//

import Foundation

public enum FGError: Swift.Error {
    public enum DecryptErrorReason {
        case rsa
        case aes
        case unzip
        case trim
    }
    
    public enum DecodeErrorReason {
        case noData
        case acdmBody
    }
    
    case decryptError(reason: DecryptErrorReason)
    case unzipError
    case decodeError(reason: DecodeErrorReason)
    case httpError
    case logicError
}
