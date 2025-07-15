//
//  UIImage+FGResize.h
//  FGBase
//
//  Created by wangkun on 2017/11/27.
//

#import <UIKit/UIKit.h>

@interface UIImage (FGResize)
- (UIImage *)fg_scaleByFactor:(float)scaleFactor;
- (UIImage *)fg_scaleToSize:(CGSize)targetSize;
@end
