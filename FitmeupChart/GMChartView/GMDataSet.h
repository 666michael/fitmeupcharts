//
//  GMDataSet.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMDataSetProtocol.h"

typedef NS_ENUM(NSUInteger, GMDataGrouping)
{
    GMDataGroupDays = 0,
    GMDataGroupWeeks,
    GMDataGroupMonth,
    GMDataGroupYears
};

typedef NS_ENUM(NSUInteger, GMDataAverage)
{
    GMDataAverageArithmetic = 0,
    GMDataAverageMedian
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
    GMDataGrouping _dataGrouping;
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
- (NSInteger) indexOfPointWithXValue: (CGFloat) xValue;
- (GMDataPoint*) lastDataPoint;
- (CGPoint) minPoint;
- (CGPoint) maxPoint;
- (void) sortPoints;
- (NSArray*) pointsArray;
- (BOOL) hasDataForDate: (NSDate*) date;

- (NSInteger) daysInSet;
- (GMDataSet*) dataSetFromDate: (NSDate*) startDate;
- (GMDataSet*) dataSetSubsetFromIndex: (NSInteger) startIndex;
- (GMDataSet*) sortedGroupsWithAverageType: (GMDataAverage) averageFunc;
- (GMDataGrouping) dataGrouping;
- (void) setDataGrouping: (GMDataGrouping) dataGrouping;
- (NSString*) dateStringForPointAtIndex: (NSInteger) index;
@end
