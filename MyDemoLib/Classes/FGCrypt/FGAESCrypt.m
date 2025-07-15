//
//  AESCrypt.m
//  FYGOMS
//
//  Created by wangkun on 15/5/26.
//  Copyright (c) 2015年 feeyo. All rights reserved.
//

#import "FGAESCrypt.h"
#import <CommonCrypto/CommonCryptor.h>

#define AESENCRYPT_ALGORITHM     kCCAlgorithmAES128
#define AESENCRYPT_BLOCK_SIZE    kCCBlockSizeAES128
#define AESENCRYPT_KEY_SIZE      kCCKeySizeAES256

@implementation FGAESCrypt
 
#pragma mark -
#pragma mark API

+ (NSData*)encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv;
{
    NSData* result = nil;
    
    // setup key
    unsigned char cKey[AESENCRYPT_KEY_SIZE];
    bzero(cKey, sizeof(cKey));
    [key getBytes:cKey length:AESENCRYPT_KEY_SIZE];
    
    // setup iv
    char cIv[AESENCRYPT_BLOCK_SIZE];
    bzero(cIv, AESENCRYPT_BLOCK_SIZE);
    if (iv) {
        [iv getBytes:cIv length:AESENCRYPT_BLOCK_SIZE];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + AESENCRYPT_BLOCK_SIZE;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    //与php配合，使用zero padding方式
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          AESENCRYPT_ALGORITHM,
                                          0x0000,
                                          cKey,
                                          AESENCRYPT_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
    } else {
        free(buffer);
        NSLog(@"[ERROR] failed to encrypt|CCCryptoStatus: %d", cryptStatus);
    }
    
    return result;
}

+ (NSData*)decryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv;
{
    NSData* result = nil;
    
    // setup key
    unsigned char cKey[AESENCRYPT_KEY_SIZE];
    bzero(cKey, sizeof(cKey));
    [key getBytes:cKey length:AESENCRYPT_KEY_SIZE];
    
    // setup iv
    char cIv[AESENCRYPT_BLOCK_SIZE];
    bzero(cIv, AESENCRYPT_BLOCK_SIZE);
    if (iv) {
        [iv getBytes:cIv length:AESENCRYPT_BLOCK_SIZE];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + AESENCRYPT_BLOCK_SIZE;
    void *buffer = malloc(bufferSize);
    
    // do decrypt
    size_t decryptedSize = 0;
    //与php配合，使用zero padding方式
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          AESENCRYPT_ALGORITHM,
                                          0x0000,
                                          cKey,
                                          AESENCRYPT_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &decryptedSize);
    
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];

        
    } else {
        if (buffer) {
            free(buffer);
        }
        NSLog(@"[ERROR] failed to decrypt| CCCryptoStatus: %d", cryptStatus);
    }
    
    return result;
}

#define FBENCRYPT_IV_HEX_LEGNTH (FBENCRYPT_BLOCK_SIZE*2)

+ (NSData *)generateIv
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        srand((unsigned)time(NULL));
    });
    
    char cIv[AESENCRYPT_BLOCK_SIZE];
    for (int i=0; i < AESENCRYPT_BLOCK_SIZE; i++) {
        cIv[i] = rand() % 256;
    }
    return [NSData dataWithBytes:cIv length:AESENCRYPT_BLOCK_SIZE];
}

@end
