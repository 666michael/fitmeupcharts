//
//  GMDataSet.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GMDataPoint;

@interface GMDataSet : NSObject
{
    NSMutableArray* _dataPoints;
    CGFloat _minX;
    CGFloat _minY;
    CGFloat _maxX;
    CGFloat _maxY;
}

@property (nonatomic, strong) UIColor* plotColor;
@property (nonatomic, copy) NSString* plotName;

@property (nonatomic, copy) CGFloat (^xCoordForValue)(CGFloat xValue);
@property (nonatomic, copy) CGFloat (^yCoordForValue)(CGFloat yValue);

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

@end
