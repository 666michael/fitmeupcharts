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

typedef enum
{
    GMPointUpToUp = 0,
    GMPointUpToDown = 1,
    GMPointDownToUp = 2,
    GMPointDownToDown = 3,
    GMPointNone = 4
} GMPointDirection;

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

//=============================================================================

- (void) plotLabels
{
    if (!self.shouldPlotLabels)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        if(_dataSets.count)
        {
            for (GMDataSet *dataSet in _dataSets)
            {
                [dataSet sortPoints];
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetLineWidth(context, defaultLineWidth);
                
                for (NSInteger index = 0; index < [dataSet count]; index++)
                {
                    GMDataPoint *dataPoint = [dataSet dataPointAtIndex: index];
                    float x = [self xCoordinatesForValue: dataPoint.xValue];
                    float y = [self yCoordinatesForValue: dataPoint.yValue];
                    
                    NSInteger row = ceilf((x - _leftPadding - self.chartPadding) / (_plotWidth / _xGridLines));
                    NSInteger col = ceilf((y - self.chartTopPadding) / (_plotHeight / _yGridLines));
                    
                    if (row == _xGridLines)
                        row--;
                    
                    if(dataPoint.shouldShowLabel)
                    {
                        UIColor* colorForText = dataPoint.pointStyle == GMPointUpperStyle ? [UIColor gm_redColor] : [UIColor gm_greenColor];
                        [self drawCircleAtXCoordinate: x
                                          yCoordinate: y
                                            fillColor: colorForText
                                           andContext: context];
                        if(col< _yGridLines && row < _xGridLines)
                        {
                            [self drawText: dataPoint.pointLabelText
                               xCoordinate: x
                               yCoordinate: y
                                 fillColor: colorForText
                                pointStyle: dataPoint.pointStyle
                                 direction: [self directionOfPointAtIndex: index
                                                                    inSet: dataSet]
                                andContext: context];
                        }
                        CGContextDrawPath(context, kCGPathFillStroke);
                    }
                }
            }
        }
    }
}

//=============================================================================

- (void) drawCircleAtXCoordinate: (CGFloat) x
                     yCoordinate: (CGFloat) y
                       fillColor: (UIColor*) color
                      andContext: (CGContextRef) context

{
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGRect rect = CGRectMake(x - defaultCircleRadius, y - defaultCircleRadius, 2 * defaultCircleRadius, 2 * defaultCircleRadius);
    CGContextAddEllipseInRect(context, rect);
}

//=============================================================================

- (void) drawText: (NSString*) text
      xCoordinate: (CGFloat) x
      yCoordinate: (CGFloat) y
        fillColor: (UIColor*) color
       pointStyle: (GMPointStyle) pointStyle
        direction: (GMPointDirection) direction
       andContext: (CGContextRef) context
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize],
                                 NSForegroundColorAttributeName : color};
    
    CGFloat textHeight = [text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
    CGFloat textWidth = [text gm_widthForFont: [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
    
    CGFloat step = (_plotHeight / _yGridLines);
    CGFloat rawY = y - self.chartTopPadding;
    
    NSInteger col = (x - _leftPadding - self.chartPadding) / step;
    NSInteger row = (y - self.chartTopPadding) / step;
    
    CGFloat colLeft = fmodf(rawY, step);
    NSLog(@"%ld - %ld", (long)row, (long)col);
    NSLog(@"direction %d", direction);
    if(colLeft < step / 2.0)
    {
        y -= colLeft;
    }
    else
    {
        y += (step - colLeft);
    }
    
    if(direction == GMPointDownToUp || direction == GMPointUpToUp)
    {
        if (col == 0)
        {
            y += (step - colLeft);
        }
        else
        {
            if (col == _xGridLines)
            {
                x -= step;
                y -= colLeft + textHeight;
            }
            else
            {
                y = [self adjustY: y
                      basedOnPath: direction
                         andSpace: colLeft];
                x = [self adjustX: x
                      basedOnPath: direction];
            }
        }
    }
    else
    {
        if (col == 0)
        {
            x -= step;
            y -= step;
        }
        else
        {
            if (col == _xGridLines)
            {
                x -= textWidth;
                if (fabs(colLeft - step)<1.0)
                    y += (step - colLeft);
            }
            else
            {
                y = [self adjustY: y
                      basedOnPath: direction
                         andSpace: colLeft];
                x = [self adjustX: x
                      basedOnPath: direction];
            }
        }
        
    }
    //[self drawCircleAtXCoordinate:x yCoordinate:y fillColor:[UIColor blueColor] andContext:UIGraphicsGetCurrentContext()];
    [text drawAtPoint: CGPointMake(x, y)
       withAttributes: attributes];
}

//=============================================================================

- (GMPointDirection) directionOfPointAtIndex: (NSInteger) index
                                inSet: (GMDataSet*) dataSet
{
    if(index==0 || index == [dataSet count]-1 || [dataSet count] < 3 )
        return GMPointNone;
    
    CGFloat leftPt = [[dataSet dataPointAtIndex: index - 1] yValue];
    CGFloat curPt = [[dataSet dataPointAtIndex: index] yValue];
    CGFloat rightPt = [[dataSet dataPointAtIndex: index + 1] yValue];
    
    if (leftPt < curPt && curPt < rightPt)
    {
        return GMPointUpToUp;
    }
    else
        if (leftPt < curPt && curPt > rightPt)
        {
            return GMPointUpToDown;
        }
        else
            if (leftPt > curPt && curPt < rightPt)
            {
                return GMPointDownToUp;
            }
            else
                if (leftPt > curPt && curPt > rightPt)
                {
                    return GMPointDownToDown;
                }
    return GMPointNone;
}

//=============================================================================

- (CGFloat) adjustY: (CGFloat) y
        basedOnPath: (GMPointDirection) path
           andSpace: (CGFloat) space
{
    CGFloat stepY = _plotHeight/_yGridLines;
    if(path == GMPointDownToDown)
    {
        return y - stepY;
    }
    if(path == GMPointUpToDown)
    {
        return y - (space>stepY/2.0 ? stepY : 0);
    }
    if(path == GMPointDownToUp)
    {
        return y +  (space<stepY/2.0 ? stepY : 0);
    }
    return y;
}

//=============================================================================

- (CGFloat) adjustX: (CGFloat) x
        basedOnPath: (GMPointDirection) path
{
    if(path == GMPointDownToDown)
    {
        return x + defaultCircleRadius;
    }
    if(path == GMPointUpToUp)
    {
        return x + defaultCircleRadius;
    }
    if(path == GMPointUpToDown)
    {
        return x + defaultCircleRadius;
    }
    return x;
}

//=============================================================================

@end
