//
//  NSData+VZZip.h
//  VeryZhun
//
//  Created by chunxi on 15/11/24.
//  Copyright © 2015年 listener~. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (VZZip)
- (NSData *)vz_unzip;
- (NSData *)vz_zip;
@end
