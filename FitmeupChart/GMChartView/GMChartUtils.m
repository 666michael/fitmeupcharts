//
//  GMChartUtils.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 06.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMChartUtils.h"
#import "GMChartView.h"

//=============================================================================

const CGFloat eps = 0.1;

//=============================================================================

@implementation GMChartUtils

//=============================================================================

#pragma mark - Methods -

//=============================================================================

+ (GMPlotDirection) gm_plotDirectionForPoint: (CGPoint) startPoint
                                endPoint: (CGPoint) endPoint
{
    if(endPoint.y - startPoint.y < eps)
    {
        return GMPlotDirectionLeft | GMPlotDirectionUp;
    }
    else
        return GMPlotDirectionLeft | GMPlotDirectionDown;
}

//=============================================================================

+ (UIFont*) gm_defaultBoldFontWithSize: (CGFloat) size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

//=============================================================================

+ (UIFont*) gm_defaultLightFontWithSize: (CGFloat) size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

//=============================================================================

+ (UIBezierPath *) gm_quadCurvedPathWithPoints: (NSArray *) points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2)
    {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSUInteger i = 1; i < points.count; i++)
    {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        
        CGPoint midPoint = [self midPointForPoint: p1
                                         andPoint: p2];
        [path addQuadCurveToPoint: midPoint
                     controlPoint: [self controlPointForPoint: midPoint
                                                     andPoint: p1]];
        [path addQuadCurveToPoint: p2
                     controlPoint: [self controlPointForPoint: midPoint
                                                     andPoint: p2]];
        
        p1 = p2;
    }
    return path;
}

//=============================================================================

+ (CGPoint) midPointForPoint: (CGPoint) p1
                    andPoint:  (CGPoint) p2
{
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

//=============================================================================

+ (CGPoint) controlPointForPoint: (CGPoint) p1
                            andPoint:  (CGPoint) p2
{
    CGPoint controlPoint = [self midPointForPoint: p1
                                         andPoint: p2];
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}
//=============================================================================
+ (GMPlotDirection) invertedDirection: (GMPlotDirection) direction
{
    if(direction == (GMPlotDirectionUp|GMPlotDirectionRight))
        return (GMPlotDirectionDown|GMPlotDirectionLeft);
    
    if(direction == (GMPlotDirectionUp|GMPlotDirectionLeft))
        return (GMPlotDirectionDown|GMPlotDirectionRight);
    
    if(direction == (GMPlotDirectionDown|GMPlotDirectionRight))
        return (GMPlotDirectionUp|GMPlotDirectionLeft);
    
    if(direction == (GMPlotDirectionDown|GMPlotDirectionLeft))
        return (GMPlotDirectionUp|GMPlotDirectionRight);
    
    return direction;
}
//=============================================================================
@end
