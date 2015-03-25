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
    
    return self;
}

//=============================================================================

- (NSString*) description
{
    return [NSString stringWithFormat:@"x: %f y: %f", _xValue, _yValue];
}

//=============================================================================

@end