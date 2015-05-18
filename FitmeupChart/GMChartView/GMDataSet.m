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

static const NSString* const kValues = @"values";
static const NSString* const kDate   = @"date";
static const NSString* const kDates  = @"dates";
static const NSString* const kCount  = @"count";

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

- (GMDataPoint*) firstDataPoint
{
    if(!_dataPoints.count)
        return nil;
    
    return [_dataPoints firstObject];
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

- (GMDataSet*) sortedGroupsWithAverageType: (GMDataAverage) averageFunc
{
    [_days removeAllObjects];
    [_weeks removeAllObjects];
    [_months removeAllObjects];
    [_years removeAllObjects];
    
    NSLog(@"Total points %d", [_dataPoints count]);
    [self detectGroupingAvailability];
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
    
    switch (_dataGrouping)
    {
        case GMDataGroupDays:
            [groups addObjectsFromArray: _days];
            break;
        case GMDataGroupWeeks:
        {
            NSLog(@"weeks: %d", [[_weeks allKeys] count]);
            [self fillDataForGroup: _weeks
                           withKey: [[NSDate date] gm_weekNumber]
                    andMaxKeyValue: kWeeksInAYear];
            
            [groups addObjectsFromArray: [self unwrapDictionary: _weeks
                                                       withFunc: averageFunc]];
            break;
        }
        case GMDataGroupMonth:
        {
            NSLog(@"months: %d", [[_months allKeys] count]);
            [self fillDataForGroup: _months
                           withKey: [[NSDate date] gm_monthNumber]
                    andMaxKeyValue: kMonthsInAYear];
            [groups addObjectsFromArray: [self unwrapDictionary: _months
                                                       withFunc: averageFunc]];
            break;
        }
        case GMDataGroupYears:
        {
            [self fillDataForGroup: _years
                           withKey: [[NSDate date] gm_yearNumber]
                    andMaxKeyValue: 0];
            [groups addObjectsFromArray: [self unwrapDictionary: _years
                                                       withFunc: averageFunc]];
            break;
        }
    }
    [self addPointStylesForGroup: groups];
    
    GMDataSet *dataSet = [[GMDataSet alloc] initWithDataPoints: groups];

    [dataSet sortPoints];
    if ([dataSet count] > kElementsInGroup)
    {
        dataSet = [dataSet dataSetSubsetFromIndex: [dataSet count] - kElementsInGroup];
    }
    [dataSet setPlotColor: self.plotColor];
    [dataSet setPlotName: self.plotName];
    [dataSet setDataGrouping: _dataGrouping];
    NSLog(@"end grouping");
    
    return dataSet;
}

#warning Refactor

//=============================================================================

#warning No If
- (void) detectGroupingAvailability
{
    NSDate *firstDate = [NSDate dateWithTimeIntervalSinceReferenceDate: [_dataPoints[0] xValue]];
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceReferenceDate: [[self lastDataPoint] xValue]];
    if ([firstDate gm_daysBetweenDate: lastDate] < kElementsInGroup)
    {
        _dataGrouping = GMDataGroupDays;
    }
    else
        if ([firstDate gm_weeksBetweenDate: lastDate] < kElementsInGroup)
        {
            _dataGrouping = GMDataGroupWeeks;
        }
        else
            if ([firstDate gm_monthsBetweenDate: lastDate] < kElementsInGroup)
            {
                _dataGrouping = GMDataGroupMonth;
            }
            else
                if ([firstDate gm_yearsBetweenDate: lastDate] < kElementsInGroup)
                {
                    _dataGrouping = GMDataGroupYears;
                }
}

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
        NSDate *keyStartDate = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_startOfWeek];
        if (group == _months)
        {
            keyStartDate = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_startOfMonth];
        }
        if (group == _years)
        {
            keyStartDate = [[NSDate dateWithTimeIntervalSinceReferenceDate: [dataPoint xValue]] gm_startOfYear];
        }
        [group setObject: [@{
                             kValues : [@[ @([dataPoint yValue])] mutableCopy],
                             kDate : @([ keyStartDate timeIntervalSinceReferenceDate]),
                             kCount : @1,
                             kDates : [@[ @(dataPoint.xValue) ] mutableCopy]} mutableCopy]
                  forKey: key];
    }
    else
    {
        NSMutableDictionary *dict = [group objectForKey: key];
        
        NSMutableArray *ids = dict[kDates];
        NSMutableArray *values = dict[kValues];
        
        if(![ids containsObject: @(dataPoint.xValue)])
        {
            [ids addObject: @(dataPoint.xValue)];
            [values addObject: @(dataPoint.yValue)];
            
            [dict setObject: @([ids count])
                     forKey: kCount];
            [dict setObject: values
                     forKey: kValues];
            [dict setObject: ids
                     forKey: kDates];
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
    
    NSArray* lastValues = @[];
    NSNumber* lastCount = @0;
    
    for (NSInteger index = 0; index < kElementsInGroup; index++)
    {
        NSString *innerKey = [NSString stringWithFormat: @"%d-%d", key, year];
        if (startKey == year)
        {
            innerKey = [NSString stringWithFormat: @"%d", key];
        }
        NSDictionary *keyData = group [innerKey];
        if (!keyData)
        {
            NSDate *keyStartDate = [NSDate date];
            if (group == _weeks)
            {
                keyStartDate = [NSDate gm_dateByWeekNumber: key
                                                   andYear: year];
            }
            if (group == _months)
            {
                keyStartDate = [NSDate gm_dateByMonthNumber: key
                                                    andYear: year];
            }
            if (group == _years)
            {
                keyStartDate = [NSDate gm_dateByYearNumber: key];
            }
            [group setObject: [@{
                                 kValues : lastValues,
                                 kDate : @([keyStartDate timeIntervalSinceReferenceDate]),
                                 kCount : lastCount} mutableCopy]
                      forKey: innerKey];
        }
        else
        {
            lastValues = [keyData[kValues] copy];
            lastCount = [keyData[kCount] copy];
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

- (void) addPointStylesForGroup: (NSArray*) group
{
    for (NSInteger index = 0; index < [group count]; index++)
    {
        if(index > 0)
        {
            if([group[index - 1] yValue] < [group[index] yValue])
            {
                [group[index] setPointStyle: GMPointStyleUpper];
            }
            else
            {
                [group[index] setPointStyle: GMPointStyleLower];
            }
        }
    }
}

//=============================================================================

- (NSMutableArray*) unwrapDictionary: (NSMutableDictionary*) group
                            withFunc: (GMDataAverage) avgFunc
{
    NSMutableArray *unwrappedArr = [NSMutableArray arrayWithCapacity: [[group allValues] count]];
    
    switch (avgFunc)
    {
        case GMDataAverageArithmetic:
        {
            for (NSDictionary *data in [group allValues])
            {
                [unwrappedArr addObject: [[GMDataPoint alloc] initWithXValue: [data[kDate] integerValue]
                                                                      yValue: [[data[kValues] valueForKeyPath: @"@avg.self"] floatValue] ]];
            }
            break;
        }
        case GMDataAverageMedian:
        {
            
            for (NSDictionary *data in [group allValues])
            {
                CGFloat medianVal = 0;
                NSUInteger middleIndex;
                
                NSArray * groupData = [[data objectForKey: kValues] sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
                    return [obj1 isEqualToNumber: obj2];
                }];
                if (self.count % 2 != 0)
                {
                    middleIndex = (groupData.count / 2);
                    medianVal = [[groupData objectAtIndex: middleIndex] floatValue];
                }
                else
                {
                    middleIndex = (groupData.count / 2) - 1;
                    medianVal = [[@[[groupData objectAtIndex: middleIndex], [groupData objectAtIndex: middleIndex + 1]] valueForKeyPath:@"@avg.self"] floatValue];
                }
                
                [unwrappedArr addObject: [[GMDataPoint alloc] initWithXValue: [data[kDate] integerValue]
                                                                      yValue: medianVal ]];
            }
            break;
        }
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

//=============================================================================

- (GMDataSet*) dataSetFromDate: (NSDate*) startDate
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

- (GMDataSet*) dataSetFromDate: (NSDate*) startDate
                        toDate: (NSDate*) endDate

{
    NSInteger indexOfFirstDate = [_dataPoints indexOfObjectPassingTest: ^BOOL(GMDataPoint *point, NSUInteger idx, BOOL *stop) {
        return point.xValue > [startDate timeIntervalSinceReferenceDate];
    }];
    NSInteger indexOfLastDate = [_dataPoints indexOfObjectPassingTest: ^BOOL(GMDataPoint *point, NSUInteger idx, BOOL *stop) {
        return point.xValue > [endDate timeIntervalSinceReferenceDate];
    }];
    if (indexOfFirstDate != NSNotFound)
    {
        NSInteger toIndex = _dataPoints.count - indexOfFirstDate;
        
        if (indexOfLastDate != NSNotFound)
        {
            toIndex = _dataPoints.count - indexOfLastDate;
        }
        return [[GMDataSet alloc] initWithDataPoints: [_dataPoints subarrayWithRange: NSMakeRange(indexOfFirstDate, toIndex)]];
    }
    else
    {
        return self;
    }
}
//=============================================================================

- (GMDataSet*) dataSetSubsetFromIndex: (NSInteger) startIndex
{
    if(startIndex <0 && startIndex> [self count])
    {
        startIndex = NSNotFound;
    }
    
    if (startIndex != NSNotFound)
    {
        return [[GMDataSet alloc] initWithDataPoints: [_dataPoints subarrayWithRange: NSMakeRange(startIndex, _dataPoints.count - startIndex)]];
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

- (NSString*) dateStringForPointAtIndex: (NSInteger) index
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
            [dateFormatter setDateFormat: @"MMM"];
            break;
        }
        case GMDataGroupYears:
        {
            [dateFormatter setDateFormat: @"yyyy"];
            break;
        }
    }
    return [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSinceReferenceDate: [_dataPoints[index] xValue]]];
}

//=============================================================================

- (GMDataSet*) dataSetForMidget
{
    NSMutableArray *points = [NSMutableArray arrayWithCapacity: kElementsInGroup];
    if ([_dataPoints count] > 0)
    {
        [points addObject: [[self firstDataPoint] copy]];
        [points addObject: [[self lastDataPoint] copy]];
    }
    
    CGFloat startX = [[self firstDataPoint] xValue];
    CGFloat endX = [[self lastDataPoint] xValue];
    CGFloat stepX = (endX - startX) / (kElementsInGroup + 1);
    
    for (NSInteger index = 0; index < kElementsInGroup; index++)
    {
        GMDataSet *setOfPoints = [self dataSetFromDate: [NSDate dateWithTimeIntervalSinceReferenceDate: startX + index * stepX]
                                                toDate: [NSDate dateWithTimeIntervalSinceReferenceDate: startX + (index + 1) * stepX]];
        [points addObject: [[GMDatePoint alloc] initWithDate: [NSDate dateWithTimeIntervalSinceReferenceDate: startX + (index + 1) * stepX]
                                                      yValue: [setOfPoints averageArithmetic]]];
    }
    
    GMDataSet *dataSet = [self copyWithPoints: points];
    [dataSet sortPoints];
    
    return dataSet;
}

//=============================================================================

- (CGFloat) averageArithmetic
{
    return [[_dataPoints valueForKeyPath: @"@avg.yValue"] floatValue];
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

#pragma mark - NSCopying -

//=============================================================================

- (id)copyWithZone: (NSZone *) zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        [copy setPlotColor: self.plotColor];
        [copy setPlotName: self.plotName];
        [copy setDataGrouping: self.dataGrouping];
    }
    
    return copy;
}

//=============================================================================

- (id) copyWithPoints: (NSArray*) points
{
    id copy = [[[self class] alloc] initWithDataPoints: points];
    
    if (copy)
    {
        [copy setPlotColor: self.plotColor];
        [copy setPlotName: self.plotName];
        [copy setDataGrouping: self.dataGrouping];
    }
    
    return copy;
}

//=============================================================================

@end
