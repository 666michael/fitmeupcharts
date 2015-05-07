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

#define kElementsInGroup 7
#define kMonthsInAYear 12
#define kWeeksInAYear 52
#define kEps 0.1f

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

- (NSInteger) indexOfPointWithXValue: (CGFloat) xValue
{
    return [_dataPoints indexOfObjectPassingTest:^BOOL(GMDataPoint *point, NSUInteger idx, BOOL *stop) {
        return fabs([point xValue] - xValue) < kEps;
    }];
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
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity: kElementsInGroup];
    if ([_days count] <= kElementsInGroup)
    {
        [groups addObjectsFromArray: _days];
        _dataGrouping = GMDataGroupDays;
    }
    else
        if ([[_weeks allKeys] count] <= kElementsInGroup)
        {
            [self fillDataForGroup: _weeks
                           withKey: [[NSDate date] gm_weekNumber]
                    andMaxKeyValue: kWeeksInAYear];
            
            [groups addObjectsFromArray: [self unwrapDictionary: _weeks]];
            _dataGrouping = GMDataGroupWeeks;
        }
        else
            if ([[_months allKeys] count] <= kElementsInGroup)
            {
                [self fillDataForGroup: _months
                               withKey: [[NSDate date] gm_monthNumber]
                        andMaxKeyValue: kWeeksInAYear];
                [groups addObjectsFromArray: [self unwrapDictionary: _months]];
                _dataGrouping = GMDataGroupMonth;
            }
            else
                if ([[_years allKeys] count] <= kElementsInGroup)
                {
                    [self fillDataForGroup: _years
                                   withKey: [[NSDate date] gm_yearNumber]
                            andMaxKeyValue: 0];
                    [groups addObjectsFromArray: [self unwrapDictionary: _years]];
                    _dataGrouping = GMDataGroupYears;
                }
    GMDataSet *dataSet = [[GMDataSet alloc] initWithDataPoints: groups];
    [dataSet setPlotColor: self.plotColor];
    [dataSet setPlotName: self.plotName];
    [dataSet sortPoints];
    [dataSet setDataGrouping: _dataGrouping];
    return dataSet;
}

#warning Refactor
//=============================================================================

- (void) placeDataPointInGroup: (GMDataPoint*) dataPoint
{
    if ([[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_daysBetweenDate: [NSDate date]] <= kElementsInGroup)
    {
        if(![_days containsObject: dataPoint])
            [_days addObject: dataPoint];
    }
    if ([[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_weeksBetweenDate: [NSDate date]] <= kElementsInGroup)
    {
        NSInteger weekNumber = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_weekNumber];
        NSInteger yearNumber = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_yearNumber];
        [self placePoint: dataPoint
                 inGroup: _weeks
                 withKey: [NSString stringWithFormat: @"%d-%d", weekNumber, yearNumber]];
    }
    if ([[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_monthsBetweenDate: [NSDate date]] <= kElementsInGroup)
    {
        NSInteger monthNumber = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_monthNumber];
        NSInteger yearNumber = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_yearNumber];
        [self placePoint: dataPoint
                 inGroup: _months
                 withKey: [NSString stringWithFormat: @"%d-%d", monthNumber, yearNumber]];
    }
    if ([[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_yearsBetweenDate: [NSDate date]] <= kElementsInGroup)
    {
        NSInteger yearNumber = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_yearNumber];
        [self placePoint: dataPoint
                 inGroup: _years
                 withKey: [NSString stringWithFormat: @"%d", yearNumber]];
    }
}

//=============================================================================

- (void) placePoint: (GMDataPoint*) dataPoint
            inGroup: (NSMutableDictionary*) group
            withKey: (NSString*) key
{
    
    if (![group objectForKey: key])
    {
        [group setObject: [@{
                             @"value" : @([dataPoint yValue]),
                             @"date" : @([[[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_startOfWeek] timeIntervalSinceReferenceDate]),
                             @"count" : @1,
                             @"dates" : [@[] mutableCopy]} mutableCopy]
                  forKey: key];
    }
    else
    {
        NSMutableDictionary *dict = [group objectForKey: key];
        
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
                      forKey: key];
        }
    }
    
}

//=============================================================================

- (void) fillDataForGroup: (NSMutableDictionary*) group
                  withKey: (NSInteger) startKey
           andMaxKeyValue: (NSInteger) maxKey
{
    NSInteger key = startKey;
    NSInteger year = [[NSDate date] gm_yearNumber];
    CGFloat lastValue = 0.0f;
    for (NSInteger index = 0; index < kElementsInGroup; index++)
    {
        NSString *innerKey = [NSString stringWithFormat: @"%d-%d", key, year];
        if (startKey == year)
            innerKey = [NSString stringWithFormat: @"%d", year];
        NSDictionary *keyData = group [innerKey];
        if (!keyData)
        {
            [group setObject: [@{
                                 @"value" : @(lastValue),
                                 @"date" : @([[NSDate gm_dateByWeekNumber: key
                                                                  andYear: year] timeIntervalSinceReferenceDate]),
                                 @"count" : @1} mutableCopy]
                      forKey: innerKey];
        }
        else
        {
            lastValue = [keyData[@"value"] floatValue] / [keyData[@"count"] floatValue];
        }
        
        key--;
        if(key == 0)
        {
            key = maxKey;
            year--;
        }
    }
}

//=============================================================================

- (NSMutableArray*) unwrapDictionary: (NSMutableDictionary*) group
{
    NSMutableArray *unwrappedArr = [NSMutableArray arrayWithCapacity: [[group allValues] count]];
    
    for (NSDictionary *data in [group allValues])
    {
        [unwrappedArr addObject: [[GMDataPoint alloc] initWithXValue: [[data objectForKey: @"date"] integerValue]
                                                              yValue: [[data objectForKey: @"value"] floatValue] / [[data objectForKey: @"count"] floatValue]]];
    }
    return unwrappedArr;
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

- (GMDataGrouping) dataGrouping
{
    return _dataGrouping;
}

//=============================================================================

- (void) setDataGrouping: (GMDataGrouping) dataGrouping
{
    _dataGrouping = dataGrouping;
}

//=============================================================================

- (NSString*) dateStringForPointAtIndex: (NSInteger) index;
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat: @"dd.MM"];
    switch ( _dataGrouping)
    {
        case GMDataGroupDays:
        case GMDataGroupWeeks:
        {
            [dateFormatter setDateFormat: @"dd.MM"];
            break;
        }
        case GMDataGroupMonth:
        {
            [dateFormatter setDateFormat: @"MM"];
            break;
        }
        case GMDataGroupYears:
        {
            [dateFormatter setDateFormat: @"yyyy"];
            break;
        }
        default:
            break;
    }
    return [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSinceReferenceDate: [_dataPoints[index] xValue]]];
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
