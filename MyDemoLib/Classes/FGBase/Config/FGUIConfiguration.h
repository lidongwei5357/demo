//
//  FGUIConfiguration.h
//  Pods
//
//  Created by wangkun on 2017/5/19.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FGUIConfiguration : NSObject

@property (nonatomic, strong, nonnull) UIColor *navBGColor;
@property (nonatomic, strong, nonnull) UIColor *BGColor;

@property (nonatomic, strong, nonnull) UIColor *lineGrayColor;
@property (nonatomic, assign) CGFloat lineHeight;

+ (nonnull instancetype)sharedInstance;
@end
