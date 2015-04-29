//
//  GMChartUtils.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 06.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, GMPlotDirection)
{
    GMPlotDirectionNone  = 0,
    GMPlotDirectionLeft  = 1 << 0,
    GMPlotDirectionRight = 1 << 1,
    GMPlotDirectionUp    = 1 << 2,
    GMPlotDirectionDown  = 1 << 3
};

@interface GMChartUtils : NSObject

+ (GMPlotDirection) gm_plotDirectionForPoint: (CGPoint) startPoint
                                    endPoint: (CGPoint) endPoint;

+ (UIFont*) gm_defaultBoldFontWithSize: (CGFloat) size;
+ (UIFont*) gm_defaultLightFontWithSize: (CGFloat) size;
+ (UIBezierPath *) gm_quadCurvedPathWithPoints: (NSArray *) points;
+ (UIBezierPath*) gm_interpolateCGPointsWithHermiteForDataSet: (NSArray*) points;
+ (GMPlotDirection) invertedDirection: (GMPlotDirection) direction;

@end
