//
//  FGUIConfiguration.m
//  Pods
//
//  Created by wangkun on 2017/5/19.
//
//

#import "FGUIConfiguration.h"

@implementation FGUIConfiguration
+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static FGUIConfiguration *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[FGUIConfiguration alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.BGColor        = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.00]; //#f2f2f2
        self.navBGColor     = [UIColor colorWithRed:0.125 green:0.369 blue:0.749 alpha:1.00]; //[UIColor fg_colorWithHex:0x205ebf];
        self.lineGrayColor  = [UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:1.00];//[UIColor fg_colorWithHex:0xdcdcdc];
        
        
        self.lineHeight     = (1 / [UIScreen mainScreen].scale);
    }
    return self;
}

@end
