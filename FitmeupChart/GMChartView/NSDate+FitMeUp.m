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
    NSDateComponents *components = [calendar components: ( NSCalendarUnitYear |  NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |  NSCalendarUnitMinute |  NSCalendarUnitSecond )
                                               fromDate: self];
    
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger timeZoneOffset = [destinationTimeZone secondsFromGMTForDate: self] / 3600;
    [components setHour: timeZoneOffset];
    [components setMinute: 0];
    [components setSecond: 0];
    
    return [calendar dateFromComponents: components];
}

//=============================================================================

- (NSDate*) gm_startOfNextDay
{
    return [[self dateByAddingTimeInterval: SECS_PER_DAY] gm_startOfDay];
}

//=============================================================================

- (NSInteger) gm_daysBetweenDate: (NSDate*) startDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitDay
                                               fromDate: self
                                                 toDate:startDate
                                                options: 0];
    return [components day];
}

//=============================================================================

- (NSInteger) gm_weeksBetweenDate: (NSDate*) startDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitWeekOfYear
                                               fromDate: self
                                                 toDate:startDate
                                                options: 0];
    return [components weekOfYear];
}

//=============================================================================

- (NSInteger) gm_monthsBetweenDate: (NSDate*) startDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitMonth
                                               fromDate: self
                                                 toDate:startDate
                                                options: 0];
    return [components month];
}

//=============================================================================

- (NSInteger) gm_yearsBetweenDate: (NSDate*) startDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitYear
                                               fromDate: self
                                                 toDate:startDate
                                                options: 0];
    return [components year];
}

//=============================================================================

- (NSInteger) gm_weekNumber
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitWeekOfYear
                                               fromDate: self];
    return [components weekOfYear];
}

//=============================================================================

- (NSInteger) gm_monthNumber
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitMonth
                                               fromDate: self];
    return [components month];
}

//=============================================================================

- (NSInteger) gm_yearNumber
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitYear
                                               fromDate: self];
    return [components year];
}

//=============================================================================

- (NSDate*) gm_startOfWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components: NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                               fromDate: self];
    
    NSInteger dayofweek = [[[NSCalendar currentCalendar] components: NSWeekdayCalendarUnit
                                                           fromDate: self] weekday];
    
    [components setDay:([components day] - ((dayofweek) - 2))];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger timeZoneOffset = [destinationTimeZone secondsFromGMTForDate: self] / 3600;
    [components setHour: timeZoneOffset];
    return [calendar dateFromComponents: components];
}

//=============================================================================

- (NSDate*) gm_startOfMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components: NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                               fromDate: self];
    
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger timeZoneOffset = [destinationTimeZone secondsFromGMTForDate: self] / 3600;
    [components setHour: timeZoneOffset];
    [components setDay: 1];
    return [calendar dateFromComponents: components];
}

//=============================================================================

- (NSDate*) gm_startOfYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components: NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                               fromDate: self];    
    
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger timeZoneOffset = [destinationTimeZone secondsFromGMTForDate: self] / 3600;
    [components setHour: timeZoneOffset];
    [components setDay: 1];
    [components setMonth: 1];
    return [calendar dateFromComponents: components];
}
//=============================================================================

+ (NSDate*) gm_dateByWeekNumber: (NSInteger) weekNumber
                        andYear: (NSInteger) yearNumber
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger timeZoneOffset = [destinationTimeZone secondsFromGMTForDate: [NSDate date]] / 3600;
    [components setHour: timeZoneOffset];
    [components setYear: yearNumber];
    [components setWeekOfYear: weekNumber];
    [components setWeekday: 2];
    return [calendar dateFromComponents: components];
}

//=============================================================================

+ (NSDate*) gm_dateByMonthNumber: (NSInteger) monthNumber
                         andYear: (NSInteger) yearNumber
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger timeZoneOffset = [destinationTimeZone secondsFromGMTForDate: [NSDate date]] / 3600;
    [components setHour: timeZoneOffset];
    [components setYear: yearNumber];
    [components setMonth: monthNumber];
    [components setWeekday: 1];
    return [calendar dateFromComponents: components];
}

//=============================================================================

+ (NSDate*) gm_dateByYearNumber: (NSInteger) yearNumber
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger timeZoneOffset = [destinationTimeZone secondsFromGMTForDate: [NSDate date]] / 3600;
    [components setHour: timeZoneOffset];
    [components setYear: yearNumber];
    [components setMonth: 1];
    [components setDay: 1];
    return [calendar dateFromComponents: components];
}
//=============================================================================

@end