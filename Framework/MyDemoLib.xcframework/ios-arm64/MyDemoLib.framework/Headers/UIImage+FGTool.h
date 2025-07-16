//
//  UIImage+FGTool.h
//  FYGOMS
//
//  Created by wangkun on 16/1/20.
//  Copyright © 2016年 feeyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FGTool)
+ (UIImage *)fg_imageFromColor:(UIColor *)color;

+ (UIImage *)fg_imageFromColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)fg_imageRotationWithDegree:(double)degree;

- (UIImage *)fg_fixOrientation;
@end
