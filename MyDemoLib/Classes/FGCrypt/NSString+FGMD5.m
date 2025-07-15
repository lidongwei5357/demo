//
//  NSString+FGMD5.m
//  WGS
//
//  Created by wangkun on 2017/7/6.
//  Copyright © 2017年 wangkun. All rights reserved.
//

#import "NSString+FGMD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (FGMD5)
- (NSString *)md5String {
    if(self.length == 0) {
        return nil;
    }
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}
@end
