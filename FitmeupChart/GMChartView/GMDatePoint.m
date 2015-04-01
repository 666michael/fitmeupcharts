//
//  GMDatePoint.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMDatePoint.h"
#import "NSDate+FitMeUp.h"

//=============================================================================

@implementation GMDatePoint

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (id) initWithDate: (NSDate*) date
             yValue: (CGFloat) yValue
{
    self = [self init];
    if (self == nil)
        return nil;
    
    self.xValue = [[date gm_startOfDay] timeIntervalSinceReferenceDate];
    self.yValue = yValue;
    
    return self;
}

//=============================================================================

- (NSString*) description
{
    return [NSString stringWithFormat: @"x: %f y: %f", super.xValue, super.yValue];
}

//=============================================================================

@end
