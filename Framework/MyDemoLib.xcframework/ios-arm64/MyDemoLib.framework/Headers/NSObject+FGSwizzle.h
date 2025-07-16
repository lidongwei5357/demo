//
//  NSObject+FGSwizzle.h
//  FGBase
//
//  Created by wangkun on 2017/11/27.
//

#import <Foundation/Foundation.h>

@interface NSObject (FGSwizzle)
/**
 @brief Method that swizzles both instance methods and class methods
 @param fromMethod original selector
 @param toMethod method of destination in swizzling.
 **/
+ (void)fg_swizzleFromSelector:(SEL)fromMethod toSelector:(SEL)toMethod;
@end
