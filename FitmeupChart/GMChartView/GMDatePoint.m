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
    self = [super initWithXValue: [[date gm_startOfDay] timeIntervalSinceReferenceDate]
                          yValue: yValue];
    if (self == nil)
        return nil;
        
    return self;
}

//=============================================================================

- (NSString*) description
{
    return [NSString stringWithFormat: @"x: %@ y: %f", [NSDate dateWithTimeIntervalSinceReferenceDate: super.xValue], super.yValue];
}

//=============================================================================

@end
