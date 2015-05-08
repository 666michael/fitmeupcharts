//
//  NSDate+FitMeUp.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 20.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SECS_PER_DAY 86400.0f
#define SECS_PER_WEEK 604800.0f

@interface NSDate (FitMeUp)

- (NSDate*) gm_startOfDay;
- (NSDate*) gm_startOfNextDay;
- (NSInteger) gm_daysBetweenDate: (NSDate*) startDate;
- (NSInteger) gm_weeksBetweenDate: (NSDate*) startDate;
- (NSInteger) gm_monthsBetweenDate: (NSDate*) startDate;
- (NSInteger) gm_yearsBetweenDate: (NSDate*) startDate;

- (NSInteger) gm_weekNumber;
- (NSInteger) gm_monthNumber;
- (NSInteger) gm_yearNumber;
- (NSDate*) gm_startOfWeek;
- (NSDate*) gm_startOfMonth;
- (NSDate*) gm_startOfYear;
+ (NSDate*) gm_dateByWeekNumber: (NSInteger) weekNumber
                        andYear: (NSInteger) yearNumber;
+ (NSDate*) gm_dateByMonthNumber: (NSInteger) monthNumber
                         andYear: (NSInteger) yearNumber;
+ (NSDate*) gm_dateByYearNumber: (NSInteger) yearNumber;

@end
