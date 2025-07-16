//
//  AESCrypt.h
//  FYGOMS
//
//  Created by wangkun on 15/5/26.
//  Copyright (c) 2015年 feeyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGAESCrypt : NSObject

//-----------------
// API (raw data)
//-----------------
+ (NSData *)generateIv;
+ (NSData *)encryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;
+ (NSData *)decryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;

@end
