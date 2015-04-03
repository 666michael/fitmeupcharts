//
//  GMDataSet.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMDataSet.h"
#import "GMDataPoint.h"
#import "GMDatePoint.h"

//=============================================================================

@implementation GMDataSet

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _dataPoints = [NSMutableArray arrayWithCapacity: 0];
    
    _minX = MAXFLOAT;
    _minY = MAXFLOAT;
    
    _maxX = 0.0f;
    _maxY = 0.0f;
    
    return self;
}

//=============================================================================

- (id) initWithDataPoints: (NSArray*) dataPoints
{
    self = [self init];
    if (self == nil)
        return nil;

    _dataPoints = [dataPoints mutableCopy];
    
    _minX = MAXFLOAT;
    _minY = MAXFLOAT;
    
    _maxX = 0.0f;
    _maxY = 0.0f;
    
    return self;
}

//=============================================================================

- (id) initWithDictionary: (NSDictionary*) dictionary
{
    NSMutableArray* dataPoints = [NSMutableArray new];
    
    if(!dictionary || ![[dictionary allKeys] count])
        return nil;
    
    for (NSNumber* key in [dictionary allKeys])
    {
        [dataPoints addObject:[[GMDatePoint alloc] initWithDate: [NSDate dateWithTimeIntervalSinceReferenceDate:[key integerValue]]
                                                         yValue: [dictionary[key] floatValue]]];
    }    
    
    return [self initWithDataPoints:dataPoints];
}

//=============================================================================

- (id) initWithDates: (NSArray*) dates
           andValues: (NSArray*) values
{
    NSMutableArray* dataPoints = [NSMutableArray new];
    
    if(!dates || !values)
        return nil;
    if([dates count] != [values count])
        return nil;
    for (NSInteger index = 0; index < [dates count]; index++)
    {
        [dataPoints addObject:[[GMDatePoint alloc] initWithDate: dates[index]
                                                         yValue: [values[index] floatValue]]];
    }
    
    return [self initWithDataPoints:dataPoints];
}

//=============================================================================

#pragma mark - Methods -

//=============================================================================

- (void) addDataPoint: (GMDataPoint*) dataPoint
{
    [_dataPoints addObject: dataPoint];
}

//=============================================================================

- (NSInteger) count
{
    return _dataPoints.count;
}

//=============================================================================

- (GMDataPoint*) dataPointAtIndex: (NSInteger) index
{
    if(index >= _dataPoints.count)
        return nil;
    
    return _dataPoints[index];
}

//=============================================================================

- (CGPoint) minPoint
{
    return CGPointMake(_minX, _minY);
}

//=============================================================================

- (CGPoint) maxPoint
{
    return CGPointMake(_maxX, _maxY);
}

//=============================================================================

- (void) sortPoints
{
    [_dataPoints sortUsingComparator: ^NSComparisonResult(GMDataPoint* pt1, GMDataPoint* pt2) {
        
        if(pt1.xValue > _maxX)
            _maxX = pt1.xValue;
        
        if(pt1.xValue < _minX)
            _minX = pt1.xValue;
        
        if(pt2.xValue > _maxX)
            _maxX = pt2.xValue;
        
        if(pt2.xValue < _minX)
            _minX = pt2.xValue;
        
        if(pt1.yValue > _maxY)
            _maxY = pt1.yValue;
        
        if(pt1.yValue < _minY)
            _minY = pt1.yValue;
        
        if(pt2.yValue > _maxY)
            _maxY = pt2.yValue;
        
        if(pt2.yValue < _minY)
            _minY = pt2.yValue;
        
        return pt1.xValue > pt2.xValue;
        
    }];
}

//=============================================================================

- (NSArray*) pointsArray
{
    NSMutableArray* pointsArray = [NSMutableArray new];
    [_dataPoints enumerateObjectsUsingBlock:^(GMDataPoint* dataPoint, NSUInteger idx, BOOL *stop) {
        if(self.xCoordForValue && self.yCoordForValue)
        {
            [pointsArray addObject: [NSValue valueWithCGPoint:CGPointMake(self.xCoordForValue(dataPoint.xValue), self.yCoordForValue(dataPoint.yValue))]];
        }
    }];
    
    return pointsArray;
}

//=============================================================================

@end
