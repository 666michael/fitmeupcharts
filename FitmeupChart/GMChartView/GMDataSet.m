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
#import "NSDate+FitMeUp.h"

//=============================================================================

#define kElementsToShow 7

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
    _days = [NSMutableArray arrayWithCapacity: 0];
    _weeks = [NSMutableDictionary dictionaryWithCapacity: 0];
    _months = [NSMutableDictionary dictionaryWithCapacity: 0];
    _years = [NSMutableDictionary dictionaryWithCapacity: 0];
    
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

- (GMDataPoint*) lastDataPoint
{
    if(!_dataPoints.count)
        return nil;
    
    return [_dataPoints lastObject];
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

- (GMDataSet*) sortedGroups
{
    [_days removeAllObjects];
    [_weeks removeAllObjects];
    [_months removeAllObjects];
    [_years removeAllObjects];
    
    NSLog(@"Total points %d", [_dataPoints count]);
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
        
        [self placeDataPointInGroup: pt1];
        [self placeDataPointInGroup: pt2];
        return pt1.xValue > pt2.xValue;
    }];
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity: kElementsToShow];
    if ([_days count] <= kElementsToShow)
    {
        [groups addObjectsFromArray: _days];
    }
    else
        if ([[_weeks allKeys] count] <= kElementsToShow)
        {
            NSInteger key = [[NSDate date] gm_weekNumber];
            NSInteger year = [[NSDate date] gm_yearNumber];
            for (NSInteger index = 0; index < kElementsToShow; index++)
            {
                NSDictionary *week = _weeks [@(key)];
                if (!week)
                {
                    [_weeks setObject: [@{
                                          @"value" : @(0.0f),
                                          @"date" : @([[NSDate gm_dateByWeekNumber: key
                                                                           andYear: year] timeIntervalSinceReferenceDate]),
                                          @"count" : @1} mutableCopy]
                               forKey: @(key)];
                }
                
                key--;
                if(key==0)
                {
#warning Need correct calc
                    key = 51;
                    year--;
                }
            }
            for (NSDictionary *data in [_weeks allValues])
            {
                [groups addObject: [[GMDataPoint alloc] initWithXValue: [[data objectForKey: @"date"] integerValue]
                                                                yValue: [[data objectForKey: @"value"] floatValue] / [[data objectForKey: @"count"] floatValue]]];
            }
        }
        else
            if ([[_months allKeys] count] <= kElementsToShow)
            {
                NSInteger key = [[NSDate date] gm_monthNumber];
                NSInteger year = [[NSDate date] gm_yearNumber];
                for (NSInteger index = 0; index < kElementsToShow; index++)
                {
                    NSDictionary *month = _months [@(key)];
                    if (!month)
                    {
                        [_months setObject: [@{
                                               @"value" : @(0.0f),
                                               @"date" : @([[NSDate gm_dateByWeekNumber: key
                                                                                andYear: year] timeIntervalSinceReferenceDate]),
                                               @"count" : @1} mutableCopy]
                                    forKey: @(key)];
                    }
                    
                    key--;
                    if(key==0)
                    {
                        key = 12;
                        year--;
                    }
                }
                for (NSDictionary *data in [_months allValues])
                {
                    [groups addObject: [[GMDataPoint alloc] initWithXValue: [[data objectForKey: @"date"] integerValue]
                                                                    yValue: [[data objectForKey: @"value"] floatValue] / [[data objectForKey: @"count"] floatValue]]];
                }
            } else
                if ([[_years allKeys] count] <= kElementsToShow)
                {
                    NSInteger key = [[NSDate date] gm_monthNumber];
                    for (NSInteger index = 0; index < kElementsToShow; index++)
                    {
                        NSDictionary *year = _years [@(key)];
                        if (!year)
                        {
                            [_years setObject: [@{
                                                  @"value" : @(0.0f),
                                                  @"date" : @([[NSDate gm_dateByWeekNumber: 1
                                                                                   andYear: key] timeIntervalSinceReferenceDate]),
                                                  @"count" : @1} mutableCopy]
                                       forKey: @(key)];
                        }
                        
                        key--;
                    }
                    for (NSDictionary *data in [_years allValues])
                    {
                        [groups addObject: [[GMDataPoint alloc] initWithXValue: [[data objectForKey: @"date"] integerValue]
                                                                        yValue: [[data objectForKey: @"value"] floatValue] / [[data objectForKey: @"count"] floatValue]]];
                    }
                }
    GMDataSet *dataSet = [[GMDataSet alloc] initWithDataPoints: groups];
    [dataSet setPlotColor: self.plotColor];
    [dataSet setPlotName: self.plotName];
    [dataSet sortPoints];
    return dataSet;
}

#warning Refactor
//=============================================================================

- (void) placeDataPointInGroup: (GMDataPoint*) dataPoint
{
    if ([[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_daysBetweenDate: [NSDate date]] <= kElementsToShow)
    {
        if(![_days containsObject: dataPoint])
            [_days addObject: dataPoint];
    }
    if ([[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_weeksBetweenDate: [NSDate date]] <= kElementsToShow)
    {
        NSInteger weekNumber = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_weekNumber];
        [self placePoint: dataPoint
                 inGroup: _weeks
                 withKey: weekNumber];
    }
    if ([[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_monthsBetweenDate: [NSDate date]] <= kElementsToShow)
    {
        NSInteger monthNumber = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_monthNumber];
        [self placePoint: dataPoint
                 inGroup: _months
                 withKey: monthNumber];
    }
    if ([[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_yearsBetweenDate: [NSDate date]] <= kElementsToShow)
    {
        NSInteger yearNumber = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_yearNumber];
        [self placePoint: dataPoint
                 inGroup: _years
                 withKey: yearNumber];
    }
}

//=============================================================================

- (void) placePoint: (GMDataPoint*) dataPoint
            inGroup: (NSMutableDictionary*) group
            withKey: (NSInteger) key
{
    
    if (![group objectForKey: @(key)])
    {
        [group setObject: [@{
                             @"value" : @([dataPoint yValue]),
                             @"date" : @([[[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_startOfWeek] timeIntervalSinceReferenceDate]),
                             @"count" : @1,
                             @"dates" : [@[] mutableCopy]} mutableCopy]
                  forKey: @(key)];
    }
    else
    {
        NSMutableDictionary *dict = [group objectForKey: @(key)];
        
        NSMutableArray *ids = dict[@"dates"];
        
        if(![ids containsObject: @(dataPoint.xValue)])
        {
            [ids addObject: @(dataPoint.xValue)];
            [dict setObject: @([ids count])
                     forKey: @"count"];
            [dict setObject: @([[dict objectForKey: @"value"] integerValue]+[dataPoint yValue])
                     forKey: @"value"];
            [dict setObject: ids
                     forKey: @"dates"];
            [group setObject: dict
                      forKey: @(key)];
        }
    }
    
}

//=============================================================================

- (NSArray*) pointsArray
{
    NSMutableArray* pointsArray = [NSMutableArray new];
    [_dataPoints enumerateObjectsUsingBlock:^(GMDataPoint* dataPoint, NSUInteger idx, BOOL *stop) {
        if([self.dataSource respondsToSelector: @selector(xCoordForValue:forDataSet:)] && [self.dataSource respondsToSelector: @selector(yCoordForValue:forDataSet:)])
        {
            [pointsArray addObject: [NSValue valueWithCGPoint: CGPointMake([self.dataSource xCoordForValue: dataPoint.xValue
                                                                                                forDataSet: self],
                                                                           [self.dataSource yCoordForValue: dataPoint.yValue
                                                                                                forDataSet: self])]];}
    }];
    
    return pointsArray;
}

//=============================================================================

- (BOOL) hasDataForDate: (NSDate*) date
{
    for (GMDataPoint* dataPoint in _dataPoints)
    {
        if(dataPoint.xValue == [date timeIntervalSinceReferenceDate])
        {
            return YES;
        }
    }
    return NO;
}

- (GMDataSet*) dataSetFromDate: (NSDate*) startDate;
{
    NSInteger indexOfDate = [_dataPoints indexOfObjectPassingTest: ^BOOL(GMDataPoint *point, NSUInteger idx, BOOL *stop) {
        return point.xValue > [startDate timeIntervalSinceReferenceDate];
    }];
    if (indexOfDate != NSNotFound)
    {
        return [[GMDataSet alloc] initWithDataPoints: [_dataPoints subarrayWithRange: NSMakeRange(indexOfDate, _dataPoints.count - indexOfDate)]];
    }
    else
    {
        return self;
    }
}

//=============================================================================

- (NSInteger) daysInSet
{
    return [[NSDate dateWithTimeIntervalSinceReferenceDate: [[_dataPoints firstObject] xValue]] gm_daysBetweenDate: [NSDate dateWithTimeIntervalSinceReferenceDate: [[_dataPoints lastObject] xValue]]];
}

//=============================================================================

- (void) aggregateByType: (GMDataAggregation) type
{
    switch (type)
    {
        case GMDataAggregationDays:
            
            break;
        case GMDataAggregationWeeks:
            
            break;
        case GMDataAggregationMonth:
            
            break;
            
        case GMDataAggregationYears:
            
            break;
        default:
            break;
    }    
}

//=============================================================================


- (NSString*) description
{
    NSString *points = @"";
    for (GMDataPoint *point in _dataPoints)
    {
        points = [points stringByAppendingFormat: @"%@\n", point];
    }
    return points;
}

//=============================================================================
@end
