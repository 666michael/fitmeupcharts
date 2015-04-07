//
//  GMChartUtils.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 06.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMChartUtils.h"

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
@end
