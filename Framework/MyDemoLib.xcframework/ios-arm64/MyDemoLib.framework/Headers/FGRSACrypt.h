//
//  RSACrypt.h
//  FYGOMS
//
//  Created by wangkun on 15/5/26.
//  Copyright (c) 2015年 feeyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGRSACrypt : NSObject

#pragma mark - Instance Methods

- (void)loadPublicKeyFromFile:(NSString *)derFilePath;
- (void)loadPublicKeyFromData:(NSData *)derData;

- (void)loadPrivateKeyFromFile:(NSString *)p12FilePath password:(NSString *)p12Password;
- (void)loadPrivateKeyFromData:(NSData *)p12Data password:(NSString *)p12Password;

- (NSString *)rsaEncryptString:(NSString*)string;
- (NSData *)rsaEncryptData:(NSData*)data;

- (NSString *)rsaDecryptString:(NSString*)string;
- (NSData *)rsaDecryptData:(NSData*)data;

@end
