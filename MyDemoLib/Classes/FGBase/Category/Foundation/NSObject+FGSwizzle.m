//
//  NSObject+FGSwizzle.m
//  FGBase
//
//  Created by wangkun on 2017/11/27.
//

#import "NSObject+FGSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (FGSwizzle)
+ (void)fg_swizzleFromSelector:(SEL)fromMethod toSelector:(SEL)toMethod
{
    //check if methods are instance methods first
    Method origMethod = class_getInstanceMethod(self, fromMethod);
    Method newMethod = class_getInstanceMethod(self, toMethod);
    
    BOOL isClassMethod = NO;
    if (!origMethod)
    {
        origMethod = class_getClassMethod(self, fromMethod);
        isClassMethod = YES;
    }
    if (!newMethod)
    {
        newMethod = class_getClassMethod(self,toMethod);
        isClassMethod = YES;
    }
    
    
    //to only be used when method is a class method
    Class c = self;
    if (isClassMethod) {
        c = object_getClass((id) self);
    }
    
    
    
    if(class_addMethod(c, fromMethod, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
    {
        class_replaceMethod(c, toMethod, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, newMethod);
    }
    
}
@end
