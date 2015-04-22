//
//  GMBarChartView.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 10.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMBarChartView.h"
#import "GMChartView.h"

//=============================================================================

@implementation GMBarChartView

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self == nil)
        return nil;
    
    [self setGridSize: GMGridSize16];
    
    return self;
}

//=============================================================================

- (void) plotLabels
{
    NSLog(@"no labels");
}

//=============================================================================

- (void) calcScale
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        [super calcScale];
        _minY = 0.0;
    }
}

//=============================================================================

- (void) plotDataSet: (GMDataSet*) dataSet
          withContet: (CGContextRef) context
{
    CGFloat step = _plotHeight/_yGridLines;
    for (NSInteger index = 0; index < [dataSet count]; index++)
    {
        GMDataPoint *dataPoint = [dataSet dataPointAtIndex: index];
        CGFloat x = [self xCoordinatesForValue: dataPoint.xValue];
        CGFloat y = [self yCoordinatesForValue: dataPoint.yValue];
        
        if (x < _plotWidth + self.chartPadding + _leftPadding)
        {
            [self drawRounedRectWithRect: CGRectMake(x + step/2.0, y, step, _plotHeight + self.chartTopPadding - y)
                            cornerRaduis: step / 2
                                   color: [dataSet plotColor]
                              forContext: context];
        }
    }
}

//=============================================================================

- (UIColor*) colorForDataSet: (GMDataSet*) dataSet
                    withDate: (NSDate*) date
{
    return [dataSet hasDataForDate: date] ? [UIColor gm_greenColor] : [UIColor gm_grayColor];
}
@end
