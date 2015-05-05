//
//  GMDataSet.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMDataSetProtocol.h"

typedef NS_ENUM(NSUInteger, GMDataAggregation)
{
    GMDataAggregationDays = 0,
    GMDataAggregationWeeks,
    GMDataAggregationMonth,
    GMDataAggregationYears
};

@class GMDataPoint;

@interface GMDataSet : NSObject
{
@private
    NSMutableArray* _dataPoints;
    CGFloat _minX;
    CGFloat _minY;
    CGFloat _maxX;
    CGFloat _maxY;
    NSMutableArray* _days;
    NSMutableDictionary* _weeks;
    NSMutableDictionary* _months;
    NSMutableDictionary* _years;
}

@property (nonatomic, strong) UIColor* plotColor;
@property (nonatomic, copy) NSString* plotName;

@property (nonatomic, weak) NSObject<GMDataSetProtocol>* dataSource;

- (id) initWithDataPoints: (NSArray*) dataPoints;
- (id) initWithDictionary: (NSDictionary*) dictionary;
- (id) initWithDates: (NSArray*) dates
           andValues: (NSArray*) values;

- (void) addDataPoint: (GMDataPoint*) dataPoint;
- (NSInteger) count;
- (GMDataPoint*) dataPointAtIndex: (NSInteger) index;
- (GMDataPoint*) lastDataPoint;
- (CGPoint) minPoint;
- (CGPoint) maxPoint;
- (void) sortPoints;
- (NSArray*) pointsArray;
- (BOOL) hasDataForDate: (NSDate*) date;

- (void) aggregateByType: (GMDataAggregation) type;
- (NSInteger) daysInSet;
- (GMDataSet*) dataSetFromDate: (NSDate*) startDate;
- (GMDataSet*) sortedGroups;

@end
