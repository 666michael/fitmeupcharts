//
//  GMDataPoint.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMDataPoint.h"

//=============================================================================

@implementation GMDataPoint

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (id) initWithXValue: (CGFloat) xValue
               yValue: (CGFloat) yValue
{
    self = [self init];
    if (self == nil)
        return nil;
    
    _xValue = xValue;
    _yValue = yValue;
    
    [self setShouldShowLabel: YES];
    [self setPointLabelText: [NSString stringWithFormat:@"%0.0f", _yValue]];
    [self setPointStyle: GMPointStyleLower];
    
    return self;
}

//=============================================================================

- (NSString*) description
{
    return [NSString stringWithFormat: @"x: %f y: %f", _xValue, _yValue];
}

//=============================================================================

#pragma mark - NSCopying -

//=============================================================================

- (id)copyWithZone: (NSZone *) zone
{
    id copy = [[[self class] alloc] initWithXValue: _xValue
                                            yValue: _yValue];
    
    if (copy)
    {
        [copy setShouldShowLabel: self.shouldShowLabel];
        [copy setPointLabelText: self.pointLabelText];
        [copy setPointStyle: self.pointStyle];
    }
    
    return copy;
}

//=============================================================================
@end