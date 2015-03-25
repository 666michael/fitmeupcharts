//
//  NSDate+FitMeUp.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 20.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SECS_PER_DAY (86400)

@interface NSDate (FitMeUp)

- (NSDate*) gm_startOfDay;
- (NSDate*) gm_startOfNextDay;
- (NSInteger) daysBetweenDate: (NSDate*) toDate;

@end
