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
    GMData7Days = 0,
    GMData7Weeks,
    GMData7Month,
    GMData7Years
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
- (CGPoint) minPoint;
- (CGPoint) maxPoint;
- (void) sortPoints;
- (NSArray*) pointsArray;
- (BOOL) hasDataForDate: (NSDate*) date;

- (void) aggregateByType: (GMDataAggregation) type
              ForEndDate: (NSDate*) endDate;
- (NSInteger) daysInSet;
@end
