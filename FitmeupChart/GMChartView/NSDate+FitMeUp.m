//
//  NSDate+FitMeUp.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 20.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "NSDate+FitMeUp.h"
#import <UIKit/UIKit.h>

//=============================================================================

@implementation NSDate (FitMeUp)

//=============================================================================

- (NSDate*) gm_startOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:( NSCalendarUnitYear |  NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |  NSCalendarUnitMinute |  NSCalendarUnitSecond ) fromDate:self];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [calendar dateFromComponents:components];
}

//=============================================================================

- (NSDate*) gm_startOfNextDay
{
    return [[self dateByAddingTimeInterval:SECS_PER_DAY] gm_startOfDay];
}

//=============================================================================

- (NSInteger) daysBetweenDate: (NSDate*) toDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:( NSCalendarUnitYear |  NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |  NSCalendarUnitMinute |  NSCalendarUnitSecond ) fromDate:toDate toDate:self options:nil];
    NSInteger daysTotal = fabs([components day]) / 3;
    return daysTotal;
}
//=============================================================================
@end
