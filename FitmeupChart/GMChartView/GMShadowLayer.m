//
//  GMShadowLayer.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 19.05.15.
//  Copyright (c) 2015 Anton Gubarenko. All rights reserved.
//

#import "GMShadowLayer.h"
#import <UIKit/UIKit.h>
#import "UIColor+FitMeUp.h"

@implementation GMShadowLayer

- (void) drawInContext: (CGContextRef) context
{
    if (_clipRect.size.width > 0.0f)
    {
        CGContextClipToRect(context, _clipRect);
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor gm_greenColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor gm_greenColor].CGColor);
    CGContextAddPath(context, [self.midgetPath CGPath]);
    
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: [[UIColor redColor] colorWithAlphaComponent: 1]];
    [shadow setShadowOffset: CGSizeMake(0, 0)];
    [shadow setShadowBlurRadius: 25.0f];
    
    CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
    
    
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake( 0, 0, 100, 100)
                                                        cornerRadius: 0];
    clipPath.usesEvenOddFillRule = YES;
    
    CGContextSetAlpha(context, CGColorGetAlpha([shadow.shadowColor CGColor]));
    CGContextBeginTransparencyLayer(context, NULL);
    {
        UIColor* opaqueShadow = [shadow.shadowColor colorWithAlphaComponent: 1];
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [opaqueShadow CGColor]);
        CGContextSetBlendMode(context, kCGBlendModeSourceOut);
        CGContextBeginTransparencyLayer(context, NULL);
        
        //[clipPath addClip];
        //[opaqueShadow setFill];
        CGContextDrawPath(context, kCGPathFill);
        
        CGContextEndTransparencyLayer(context);
    }
    CGContextEndTransparencyLayer(context);
}

@end
