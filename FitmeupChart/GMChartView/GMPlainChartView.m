//
//  GMPlainChartView.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 10.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMPlainChartView.h"
#import "GMChartView.h"

//=============================================================================

@implementation GMPlainChartView

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self == nil)
        return nil;
        
    return self;
}

//=============================================================================

- (void) plotDataSet: (GMDataSet*) dataSet
          withContet: (CGContextRef) context
{
    if(!self.shouldUseBezier)
    {
        for (NSInteger index = 0; index < [dataSet count]; index++)
        {
            GMDataPoint *dataPoint = [dataSet dataPointAtIndex: index];
            CGFloat x = [self xCoordinatesForValue: dataPoint.xValue];
            CGFloat y = [self yCoordinatesForValue: dataPoint.yValue];
            
            if(index == 0)
            {
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, x, y);
            }
            else
            {
                CGContextAddLineToPoint(context, x, y);
            }
            
            if(index+1 < [dataSet count])
            {
                GMDataPoint *dataPoint1 = [dataSet dataPointAtIndex: index+1];
                float x1 = [self xCoordinatesForValue: dataPoint1.xValue];
                float y1 = [self yCoordinatesForValue: dataPoint1.yValue];
                
                for (CGFloat t = 0; t <= 1.0; t += 0.01)
                {
                    float midX = (1 - t) * x + t * x1;
                    float midY = (1 - t) * y + t * y1;
                    
                    NSInteger row1 = (midX-_leftPadding-  self.chartPadding) / (_plotWidth/_xGridLines);
                    NSInteger col1 = (_plotHeight  - (midY) + self.chartTopPadding) / (_plotHeight / _yGridLines);
                    
                    [self highlightCellInGridAtRow: row1
                                         andColumn: _yGridLines - col1 -1
                                        withIndex: [GMChartUtils gm_plotDirectionForPoint: CGPointMake(x, y)
                                                                                  endPoint: CGPointMake(x1, y1)]];
                }
            }
            
        }
        CGContextSetStrokeColorWithColor(context, dataSet.plotColor ? [dataSet.plotColor CGColor] : [UIColor whiteColor].CGColor);
        CGContextDrawPath(context, kCGPathStroke);
    }
    else
    {
        [dataSet setXCoordForValue:^CGFloat(CGFloat xValue) {
            return [self xCoordinatesForValue:xValue];
        }];
        [dataSet setYCoordForValue:^CGFloat(CGFloat yValue) {
            return [self yCoordinatesForValue:yValue];
        }];
        UIBezierPath *path = [GMChartUtils gm_quadCurvedPathWithPoints: [dataSet pointsArray]];
        if(path)
        {
            [path stroke];
            CGContextSetStrokeColorWithColor(context, dataSet.plotColor ? [dataSet.plotColor CGColor] : [UIColor whiteColor].CGColor);
            CGContextAddPath(context, [path CGPath]);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
}

//=============================================================================

- (UIColor*) colorForDataSet: (GMDataSet*) dataSet
                    withDate: (NSDate*) date
{
    return [UIColor gm_grayColor];
}

@end
