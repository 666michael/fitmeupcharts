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

+ (UIBezierPath*) gm_interpolateCGPointsWithHermiteForDataSet: (NSArray*) points
{
    if ([points count] < 2)
    {
        return nil;
    }
    
    NSInteger nCurves = [points count] -1 ;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (NSInteger index = 0; index < nCurves; ++index)
    {
        CGPoint curPoint  = [points[index] CGPointValue];
        CGPoint prevPt, nextPt, endPt;
        
        if (index == 0)
            [path moveToPoint:curPoint];
        
        NSInteger nextIndex = (index+1) % [points count];
        NSInteger prevIndex = (index-1 < 0 ? [points count]-1 : index - 1);
        
        
        prevPt = [points[prevIndex] CGPointValue];
        nextPt = [points[nextIndex] CGPointValue];
        endPt = nextPt;
        
        if ( fabs(curPoint.y - nextPt.y) < 1.0)
        {
            [path addLineToPoint: nextPt];
        }
        else
        {            
            float mx, my;
            if (index > 0)
            {
                mx = (nextPt.x - curPoint.x)*0.5 + (curPoint.x - prevPt.x)*0.5;
                my = (nextPt.y - curPoint.y)*0.5 + (curPoint.y - prevPt.y)*0.5;
            }
            else
            {
                mx = (nextPt.x - curPoint.x)*0.5;
                my = (nextPt.y - curPoint.y)*0.5;
            }
            
            CGPoint ctrlPt1;
            ctrlPt1.x = curPoint.x + mx / 3.0;
            ctrlPt1.y = curPoint.y + my / 3.0;
            
            curPoint = [points[nextIndex] CGPointValue];
            
            nextIndex = (nextIndex+1)%[points count];
            prevIndex = index;
            
            prevPt = [points[prevIndex] CGPointValue];
            nextPt = [points[nextIndex] CGPointValue];
            
            if (index < nCurves-1)
            {
                mx = (nextPt.x - curPoint.x)*0.5 + (curPoint.x - prevPt.x)*0.5;
                my = (nextPt.y - curPoint.y)*0.5 + (curPoint.y - prevPt.y)*0.5;
            }
            else
            {
                mx = (curPoint.x - prevPt.x)*0.5;
                my = (curPoint.y - prevPt.y)*0.5;
            }
            
            CGPoint ctrlPt2;
            ctrlPt2.x = curPoint.x - mx / 3.0;
            ctrlPt2.y = curPoint.y - my / 3.0;
            
            [path addCurveToPoint:endPt controlPoint1:ctrlPt1 controlPoint2:ctrlPt2];
        }
    }
    return path;
}

//=============================================================================

+ (UIBezierPath*) gm_smoothedPathWithGranularity: (NSInteger) granularity
                                   forDataSet: (NSMutableArray*) points
{
    if (points.count < 4)
    {
        return [self gm_quadCurvedPathWithPoints: points];
    }
    
    [points insertObject:[points objectAtIndex:0] atIndex:0];
    [points addObject:[points lastObject]];
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
    
    [smoothedPath moveToPoint:[points[0] CGPointValue]];
    
    for (NSUInteger index = 1; index < points.count - 2; index++)
    {
        CGPoint p0 = [points[index - 1] CGPointValue];
        CGPoint p1 = [points[index] CGPointValue];
        CGPoint p2 = [points[index+1] CGPointValue];;
        CGPoint p3 = [points[index+2] CGPointValue];;
        
        for (int i = 1; i < granularity; i++)
        {
            float t = (float) i * (1.0f / (float) granularity);
            float tt = t * t;
            float ttt = tt * t;
            
            CGPoint pi; // intermediate point
            pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
            pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
            [smoothedPath addLineToPoint:pi];
        }
        
        [smoothedPath addLineToPoint:p2];
    }
    
    [smoothedPath addLineToPoint: [points[points.count - 1] CGPointValue]];
    
    return smoothedPath;
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
