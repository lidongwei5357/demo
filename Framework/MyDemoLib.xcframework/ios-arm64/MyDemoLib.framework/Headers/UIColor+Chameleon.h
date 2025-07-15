
//  UIColor+Chameleon.h

/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014-2015 Vicc Alexander.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSUInteger, UIGradientStyle) {
    /**
     *  Returns a gradual blend between colors originating at the leftmost point of an object's frame, and ending at the rightmost point of the object's frame.
     *
     *  @since 1.0
     */
    UIGradientStyleLeftToRight,
    /**
     *  Returns a gradual blend between colors originating at the center of an object's frame, and ending at all edges of the object's frame. NOTE: Supports a Maximum of 2 Colors.
     *
     *  @since 1.0
     */
    UIGradientStyleRadial,
    /**
     *  Returns a gradual blend between colors originating at the topmost point of an object's frame, and ending at the bottommost point of the object's frame.
     *
     *  @since 1.0
     */
    UIGradientStyleTopToBottom
};

@interface UIColor (Chameleon)
/**
 *  Creates and returns a gradient as a color object with an alpha value of 1.0
 *
 *  @param gradientStyle Specifies the style and direction of the gradual blend between colors.
 *  @param frame The frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
 *  @param colors An array of color objects used to create a gradient.
 *
 *  @return A @c UIColor object using colorWithPattern.
 *
 *  @since 2.0
 */
+ (UIColor *)colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame andColors:(NSArray<UIColor *> *)colors;



@end

NS_ASSUME_NONNULL_END

