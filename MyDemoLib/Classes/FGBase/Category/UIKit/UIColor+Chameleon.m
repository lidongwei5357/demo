#import "UIColor+Chameleon.h"
@import CoreGraphics;

@implementation UIColor (Chameleon)

+ (UIColor *)colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame andColors:(NSArray *)colors; {

    //Create our background gradient layer
    CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];

    //Set the frame to our object's bounds
    backgroundGradientLayer.frame = frame;

    //To simplfy formatting, we'll iterate through our colors array and create a mutable array with their CG counterparts
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
        [cgColors addObject:(id)[color CGColor]];
    }

    switch (gradientStyle) {
        case UIGradientStyleLeftToRight: {

            //Set out gradient's colors
            backgroundGradientLayer.colors = cgColors;

            //Specify the direction our gradient will take
            [backgroundGradientLayer setStartPoint:CGPointMake(0.0, 0.5)];
            [backgroundGradientLayer setEndPoint:CGPointMake(1.0, 0.5)];

            //Convert our CALayer to a UIImage object
            UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size,NO, [UIScreen mainScreen].scale);
            [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            return [UIColor colorWithPatternImage:backgroundColorImage];
        }

        case UIGradientStyleRadial: {
            UIGraphicsBeginImageContextWithOptions(frame.size,NO, [UIScreen mainScreen].scale);

            //Specific the spread of the gradient (For now this gradient only takes 2 locations)
            CGFloat locations[2] = {0.0, 1.0};

            //Default to the RGB Colorspace
            CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
            CFArrayRef arrayRef = (__bridge CFArrayRef)cgColors;

            //Create our Fradient
            CGGradientRef myGradient = CGGradientCreateWithColors(myColorspace, arrayRef, locations);


            // Normalise the 0-1 ranged inputs to the width of the image
            CGPoint myCentrePoint = CGPointMake(0.5 * frame.size.width, 0.5 * frame.size.height);
            float myRadius = MIN(frame.size.width, frame.size.height) * 1.0;

            // Draw our Gradient
            CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
                                         0, myCentrePoint, myRadius,
                                         kCGGradientDrawsAfterEndLocation);

            // Grab it as an Image
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();

            // Clean up
            CGColorSpaceRelease(myColorspace); // Necessary?
            CGGradientRelease(myGradient); // Necessary?
            UIGraphicsEndImageContext();

            return [UIColor colorWithPatternImage:backgroundColorImage];
        }

        case UIGradientStyleTopToBottom:
        default: {

            //Set out gradient's colors
            backgroundGradientLayer.colors = cgColors;

            //Convert our CALayer to a UIImage object
            UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size,NO, [UIScreen mainScreen].scale);
            [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            return [UIColor colorWithPatternImage:backgroundColorImage];
        }

    }
}

@end
