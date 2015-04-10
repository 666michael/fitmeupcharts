//
//  GMChartView.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMChartView.h"
#import "NSString+FitMeUp.h"
#import "UIColor+FitMeUp.h"
#import "GMDataSet.h"
#import "NSDate+FitMeUp.h"
#import "GMChartUtils.h"

//=============================================================================

const CGFloat chartPadding = 30.0f;
const CGFloat chartTopPadding = 60.0f;
const CGFloat chartBottomPadding = 120.0f;
const CGFloat defaultLineWidth = 2.0f;
const CGFloat defaultGridLineWidth = 0.5f;
const NSInteger defaultGridLines = 5;
const CGFloat defaultFontSize = 10.5;
const CGFloat defaultCircleRadius = 2.5;
const CGFloat defaultSmallCircleRadius = 2.5;
const NSString* defaultDateFormat = @"EEE";
const CGFloat defaultLegendSquare = 30.0f;
const CGFloat defaultXSquaresCount = 14;

//=============================================================================

@implementation GMChartView

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (id) initWithFrame: (CGRect) frame
{
    if(self == [super initWithFrame: frame])
    {
        [self setupDefaultViewLayout];
    }
    return self;
}

//=============================================================================

- (id) initWithCoder: (NSCoder*) aDecoder
{
    if(self == [super initWithCoder: aDecoder])
    {
        [self setupDefaultViewLayout];
    }
    return self;
}

//=============================================================================

- (void) setupDefaultViewLayout
{
    [self setBackgroundColor: [UIColor whiteColor]];
    
    _xAxisColor = [UIColor gm_grayColor];
    _yAxisColor = [UIColor gm_grayColor];
    
    _leftPadding = 0.0f;
    
    _plotWidth = CGRectGetWidth(self.frame) - 2 * chartPadding - _leftPadding;
    _plotHeight = CGRectGetHeight(self.frame) - chartTopPadding - chartBottomPadding;
    
    [self setupXLabel];
    [self setupYLabel];
    _xAxisLabel.text = @"month / january";
    _yAxisLabel.text = @"weight";
    
    _defaultGridLineColor = [[UIColor lightGrayColor] CGColor];
    
    _dataSets = @[];
    
    _minX = MAXFLOAT;
    _minY = MAXFLOAT;
    
    _maxX = 0.0f;
    _maxY = 0.0f;
    
    _minGridSize = 30.0f;
    
    self.showGrid = YES;
    
    self.chartType = GMScatterChart;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didRotateDeviceChangeNotification:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    
    [self setShowYValues: YES];
    [self setShouldUseBezier: NO];
    [self setChartType: GMScatterChart];
    [self setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [self setTranslatesAutoresizingMaskIntoConstraints: YES];
}

//=============================================================================

-(void)didRotateDeviceChangeNotification:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

//=============================================================================

- (void) setupXLabel
{
    _xAxisLabel = [[UILabel alloc] initWithFrame: CGRectMake(_plotHeight + 10, chartPadding, _plotWidth, 0)];
    [_xAxisLabel setTextAlignment: NSTextAlignmentCenter];
    [_xAxisLabel setFont: [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize]];
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [_xAxisLabel setAutoresizingMask: mask];
    [self addSubview: _xAxisLabel];
}

//=============================================================================

- (void) setupYLabel
{
    _yAxisLabel = [[UILabel alloc] initWithFrame: CGRectMake(chartPadding, 10, _plotWidth, 0)];
    [_yAxisLabel setFont: [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize]];
    [self addSubview: _yAxisLabel];
}

//=============================================================================

- (void) setDataSetsWithArray: (NSArray*) dataSets
{
    _dataSets = [dataSets copy];
}

//=============================================================================

- (void) dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

//=============================================================================

#pragma mark - Draw Grid -

- (void) drawRect: (CGRect) rect
{
    [self plotChart];
    [self plotChartData];
}

//=============================================================================

- (void) plotChart
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        [self clearContext];
        
        self.showYValues = self.chartType == GMBarChart ? NO : self.showYValues;
        
        _leftPadding = self.showYValues ? ( ((CGRectGetWidth(self.frame) - 2 * chartPadding) / defaultXSquaresCount) * 3) : 0.0f;
        
        _plotWidth = CGRectGetWidth(self.frame) - 2 * chartPadding - _leftPadding;
        _plotHeight = CGRectGetHeight(self.frame) - chartTopPadding - chartBottomPadding;
        
        [self calcScale];
        [self calculateLinesNumber];
        [self arrangeLabels];
        [self drawGrid];
    }
}

//=============================================================================

- (void) clearContext
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, CGRectGetHeight(self.frame));
    CGContextAddLineToPoint(context, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGContextAddLineToPoint(context, CGRectGetWidth(self.frame), 0);
    CGContextAddLineToPoint(context, 0, 0);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
}

//=============================================================================

- (void) arrangeLabels
{
    [_xAxisLabel setTextColor:_xAxisColor];
    [_yAxisLabel setTextColor:_yAxisColor];
    
    CGFloat xTextHeight = [_xAxisLabel.text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize]];
    CGFloat yTextHeight = [_xAxisLabel.text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize]];
    
    [_xAxisLabel setFrame: CGRectMake(chartPadding, _plotHeight + chartTopPadding + xTextHeight/2.0, _plotWidth, xTextHeight)];
    [_yAxisLabel setFrame: CGRectMake(chartPadding, chartTopPadding - yTextHeight * 1.5, _plotWidth, yTextHeight)];
}

//=============================================================================

- (void) drawGrid
{
    [self calculateLinesNumber];
    [self drawXAxis];
    [self drawYAxis];
    if(self.showGrid)
    {
        [self drawVerticalLines];
        [self drawHorizontalLines];
    }
}

//=============================================================================

- (void) calculateLinesNumber
{
    _xGridLines = defaultGridLines;
    _yGridLines = defaultGridLines;
    
    CGFloat stepX = _plotWidth / defaultXSquaresCount;
    NSInteger fixedCount = _plotHeight / stepX;
    fixedCount = fixedCount -( fixedCount%2);
    _plotHeight -= (_plotHeight - stepX*fixedCount);
    
    _xGridLines = defaultXSquaresCount;
    _yGridLines = fixedCount;
    
    _labelsGrid = [NSMutableArray array];
    NSInteger count = self.showYValues? _yGridLines +1 : _yGridLines;
    for (short i = 0; i < count; i++)
    {
        NSMutableArray* innerArr = [NSMutableArray arrayWithCapacity: _xGridLines];
        for (short i = 0; i <= _xGridLines; i++)
        {
            [innerArr addObject: @0];
        }
        [_labelsGrid addObject: innerArr];
    }
}

//=============================================================================

- (void) drawXAxis
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultLineWidth);
    CGContextSetStrokeColorWithColor(context, [_xAxisColor CGColor]);
    
    CGContextMoveToPoint(context, chartPadding, _plotHeight + chartTopPadding);
    CGContextAddLineToPoint(context, _plotWidth + chartPadding+_leftPadding, _plotHeight + chartTopPadding);
    
    CGContextStrokePath(context);
}

//=============================================================================

- (void) drawText: (NSString*) text
          atPoint: (CGPoint) point
         andColor: (UIColor*) textColor
{
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize],
                                     NSForegroundColorAttributeName : textColor
                                     };
    [text drawAtPoint: point
       withAttributes: textAttributes];
}

//=============================================================================

- (void) drawYAxis
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultLineWidth);
    CGContextSetStrokeColorWithColor(context, [_yAxisColor CGColor]);
    
    CGContextMoveToPoint(context, chartPadding, chartTopPadding);
    CGContextAddLineToPoint(context, chartPadding, _plotHeight + chartTopPadding);
    
    CGContextStrokePath(context);
}

//=============================================================================

- (void) drawVerticalLines
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultGridLineWidth);
    CGContextSetStrokeColorWithColor(context, _defaultGridLineColor);
    
    CGFloat stepX = _plotWidth / _xGridLines;
    NSInteger howMany = _plotWidth/ stepX;
    
    for (NSInteger i = self.showYValues ? -1 : 0; i <= howMany; i++)
    {
        CGContextMoveToPoint(context,chartPadding + i * stepX + _leftPadding, chartTopPadding);
        CGContextAddLineToPoint(context, chartPadding + i * stepX + _leftPadding, _plotHeight + chartTopPadding);
    }
    
    CGContextStrokePath(context);
}

//=============================================================================

- (void) drawHorizontalLines
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultGridLineWidth);
    CGContextSetStrokeColorWithColor(context, _defaultGridLineColor);
    
    CGFloat stepY = _plotHeight/_yGridLines;
    
    for (NSInteger i = 1; i <= _yGridLines; i++)
    {
        CGContextMoveToPoint(context, chartPadding, _plotHeight + chartTopPadding - i * stepY);
        CGContextAddLineToPoint(context, _plotWidth + chartPadding + _leftPadding, _plotHeight + chartTopPadding - i * stepY);
    }
    
    CGContextStrokePath(context);
}

//=============================================================================

#pragma mark - Draw Data -

//=============================================================================

- (void) plotChartData
{
    [self plotGraph];
    [self plotLabels];
    if(!_xAxisLabel.text.length)
        [self drawXLegend];
    if (self.showYValues)
    {
        [self drawYLegend];
    }
    [self drawLowerLegend];
    [self printGrid];
}

//=============================================================================

- (void) calcScale
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        if(_dataSets.count)
        {
            _minX = MAXFLOAT;
            _minY = MAXFLOAT;
            
            _maxX = 0.0f;
            _maxY = 0.0f;
            
            for (GMDataSet *dataSet in _dataSets)
            {
                [dataSet sortPoints];
                if(dataSet.maxPoint.x > _maxX)
                    _maxX = dataSet.maxPoint.x;
                
                if(dataSet.minPoint.x < _minX)
                    _minX = dataSet.minPoint.x;
                
                if(dataSet.maxPoint.y > _maxY)
                    _maxY = dataSet.maxPoint.y;
                
                if(dataSet.minPoint.y < _minY)
                    _minY = dataSet.minPoint.y;
            }
            
            CGFloat avgToAdd = fabs(_minY - _maxY) / 10.0f;
            _minY = _minY - fmaxf(1.0, floorf(avgToAdd));
            _maxY = _maxY + fmaxf(1.0, floorf(avgToAdd));
            if(fabs(_minY - _maxY) < 0.1)
            {
                _minY -= floorf(_minY/2.0);
                _maxY += floorf(_maxY/2.0);
            }
            if(self.chartType == GMBarChart)
            {
                _minY = 0.0;
            }
            _minX = [[[NSDate dateWithTimeIntervalSinceReferenceDate:_minX] gm_startOfDay] timeIntervalSinceReferenceDate];
            _maxX = [[[NSDate dateWithTimeIntervalSinceReferenceDate:_maxX] gm_startOfDay] timeIntervalSinceReferenceDate];
        }
    }
}

//=============================================================================

- (void) plotGraph
{
    if(_dataSets.count)
    {
        for (GMDataSet *dataSet in _dataSets)
        {
            [dataSet sortPoints];
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetLineWidth(context, defaultLineWidth);
            CGContextSetStrokeColorWithColor(context,dataSet.plotColor ? [dataSet.plotColor CGColor] : [UIColor whiteColor].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            
            if(self.chartType == GMScatterChart)
            {
                if(!self.shouldUseBezier)
                {
                    for (NSInteger index = 0; index < [dataSet count]; index++)
                    {
                        GMDataPoint *dataPoint = [dataSet dataPointAtIndex:index];
                        CGFloat x = [self xCoordinatesForValue:dataPoint.xValue];
                        CGFloat y = [self yCoordinatesForValue:dataPoint.yValue];
                        
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
                            GMDataPoint *dataPoint1 = [dataSet dataPointAtIndex:index+1];
                            float x1 = [self xCoordinatesForValue:dataPoint1.xValue];
                            float y1 = [self yCoordinatesForValue:dataPoint1.yValue];
                            
                            for (CGFloat t = 0; t <= 1.0; t+=0.01)
                            {
                                float midX = (1 - t) * x + t * x1;
                                float midY = (1 - t) * y + t * y1;
                                
                                NSInteger row1 = (midX-_leftPadding-chartPadding) / (_plotWidth/_xGridLines);
                                NSInteger col1 = (_plotHeight  - (midY)+chartTopPadding) / (_plotHeight/_yGridLines);
                                                                
                                [self highlightCellInGridAtRow: row1
                                                     andColumn: _yGridLines - col1 -1
                                                     withIndex: [GMChartUtils gm_plotDirectionForPoint: CGPointMake(x, y)
                                                                                              endPoint: CGPointMake(x1, y1)]];
                            }
                        }
                        
                    }
                    CGContextSetStrokeColorWithColor(context,dataSet.plotColor ? [dataSet.plotColor CGColor] : [UIColor whiteColor].CGColor);
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
            else
            {
                CGFloat step = _plotHeight/_yGridLines;
                for (NSInteger index = 0; index < [dataSet count]; index++)
                {
                    GMDataPoint *dataPoint = [dataSet dataPointAtIndex:index];
                    CGFloat x = [self xCoordinatesForValue:dataPoint.xValue];
                    CGFloat y = [self yCoordinatesForValue:dataPoint.yValue];
                    
                    if(x < _plotWidth+chartPadding+_leftPadding)
                    {
                        [self drawRounedRectWithRect: CGRectMake(x + step/2.0, y, step, _plotHeight +chartTopPadding-y)
                                        cornerRaduis: step/2
                                               color: [UIColor gm_greenColor]
                                          forContext: context];
                    }
                }
            }
        }
    }
}

//=============================================================================

- (void) plotLabels
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        if(_dataSets.count && self.chartType == GMScatterChart)
        {
            for (GMDataSet *dataSet in _dataSets)
            {
                [dataSet sortPoints];
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetLineWidth(context, defaultLineWidth);
                
                for (NSInteger index = 0; index < [dataSet count]-1; index++)
                {
                    GMDataPoint *dataPoint = [dataSet dataPointAtIndex:index];
                    float x = [self xCoordinatesForValue:dataPoint.xValue];
                    float y = [self yCoordinatesForValue:dataPoint.yValue];
                    
                    NSInteger row = floorf((x-_leftPadding-chartPadding) / (_plotWidth/_xGridLines));
                    NSInteger col = floorf((_plotHeight  - (y)+chartTopPadding) / (_plotHeight/_yGridLines));
                    
                    
                    if(dataPoint.shouldShowLabel)
                    {
                        UIColor* colorForText = dataPoint.pointStyle == GMPointUpperStyle ? [UIColor gm_redColor] : [UIColor gm_greenColor];
                        [self drawCircleAtXCoordinate: x
                                          yCoordinate: y
                                            fillColor: colorForText
                                           andContext: context];
                        
                        GMPlotDirection direction = [_labelsGrid[_yGridLines-col-1][row] integerValue];
                        CGPoint textCell = [self closestFreeCellInGridAtRow: row
                                                                   atColumn: _yGridLines - col -1
                                                        withSearchDirection: [GMChartUtils invertedDirection:direction]];
                        
                        [self highlightCellInGridAtRow:textCell.x andColumn:textCell.y withIndex:-1];
                        
                        CGFloat stepY = _plotHeight/_yGridLines;
                        x = chartPadding + _leftPadding + textCell.x*stepY;
                        y = chartTopPadding + (textCell.y)*stepY;
                        
                        CGContextAddRect(context, CGRectMake(x, y, stepY, stepY));
                        
                        
                        
                        [self drawText: dataPoint.pointLabelText
                           xCoordinate: x
                           yCoordinate: y
                             fillColor: colorForText
                            pointStyle: dataPoint.pointStyle
                            andContext: context];
                        
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
       andContext: (CGContextRef) context
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize],
                                 NSForegroundColorAttributeName : color};
    
    CGFloat textHeight = [text gm_heightForFont:[GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize]];
    CGFloat textWidth = [text gm_widthForFont:[GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize]];
    
    if(pointStyle == GMPointUpperStyle)
    {
        x -= textWidth;
        y -= textHeight * 1.5;
    }
    else
    {
        y += textHeight / 2.0;
    }
    [text drawAtPoint: CGPointMake(x, y)
       withAttributes: attributes];
}

//=============================================================================

- (CGFloat) xCoordinatesForValue: (CGFloat) xValue
{
    /*CGFloat xOld = (xValue * _plotWidth) / _maxX;
     CGFloat xMinOffset = (_minX * _plotWidth) / _maxX;
     
     CGFloat scaleX = _plotWidth / (_plotWidth - xMinOffset);
     
     CGFloat res = (xOld - xMinOffset) * scaleX;*/
    
    CGFloat stepX = (_plotWidth / _xGridLines) * 2;
    CGFloat res = stepX * ((xValue - _minX)/SECS_PER_DAY);
    
    return chartPadding + res + _leftPadding;
}

//=============================================================================

- (CGFloat) yCoordinatesForValue: (CGFloat) yValue
{
    CGFloat yOld = (yValue * _plotHeight) / _maxY;
    CGFloat yMinOffset = (_minY * _plotHeight) / _maxY;
    
    CGFloat scaleY = _plotHeight / (_plotHeight - yMinOffset);
    
    CGFloat res = (yOld - yMinOffset) * scaleY;
    
    return chartTopPadding + _plotHeight - res;
}

//=============================================================================

- (void) drawXLegend
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultGridLineWidth);
    
    UIFont* textFont = [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize];
    
    NSInteger amountPerLine = SECS_PER_DAY/2;
    
    for (NSInteger i = 0; i < _xGridLines; i++)
    {
        if (i % 2 == 0)
        {
            CGFloat x = [self xCoordinatesForValue:_minX + i * amountPerLine];
            CGFloat y = _plotHeight + chartTopPadding;
            
            CGRect rect = CGRectMake(x - defaultSmallCircleRadius, y - defaultSmallCircleRadius, 2 * defaultSmallCircleRadius, 2 * defaultSmallCircleRadius);
            CGContextAddEllipseInRect(context, rect);
            
            UIColor *textColor = [UIColor gm_grayColor];
            if(self.chartType == GMBarChart)
            {
                textColor = [_dataSets[0] hasDataForDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_minX + i * amountPerLine]] ? [UIColor gm_greenColor] : [UIColor gm_grayColor];
            }
            NSDictionary *attributes = @{
                                         NSFontAttributeName : textFont,
                                         NSForegroundColorAttributeName : textColor};
            NSString* legendText = [NSString stringWithFormat:@"%@", [[self defaultDateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_minX + i * amountPerLine]]];
            
            CGFloat textHeight = [legendText gm_heightForFont: textFont];
            x -= [legendText gm_widthForFont: textFont] / 2.0;
            
            [legendText drawAtPoint: CGPointMake(x, y + textHeight/2.0)
                     withAttributes: attributes];
            
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }
}

//=============================================================================

- (void) drawYLegend
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultGridLineWidth);
    
    UIFont* textFont = [GMChartUtils gm_defaultLightFontWithSize:defaultFontSize-2.0];
    
    CGFloat stepY = (_maxY -_minY) / _yGridLines;
    
    for (NSInteger i = 1; i <= _yGridLines; i++)
    {
        if (i % 2 == 0 && [self yCoordinatesForValue:(i * stepY)]>=chartTopPadding)
        {
            CGFloat x = chartPadding;
            CGFloat y = [self yCoordinatesForValue:_minY + (i * stepY)];
            
            CGRect rect = CGRectMake(x - defaultSmallCircleRadius, y - defaultSmallCircleRadius, 2 * defaultSmallCircleRadius, 2 * defaultSmallCircleRadius);
            CGContextAddEllipseInRect(context, rect);
            
            NSDictionary *attributes = @{
                                         NSFontAttributeName : textFont,
                                         NSForegroundColorAttributeName : [UIColor gm_grayColor]};
            NSString* legendText = [NSString stringWithFormat:@"%.0f", _minY +(i * stepY) ];
            
            x += fminf(5.0, [legendText gm_widthForFont: textFont]);
            [legendText drawAtPoint: CGPointMake(x, y + fminf( 5.0f, [legendText gm_heightForFont: textFont] / 2.0))
                     withAttributes: attributes];
            
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }
}

//=============================================================================

- (NSDateFormatter*) defaultDateFormatter
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat: [defaultDateFormat copy]];
    [dateFormatter setTimeZone: [NSTimeZone defaultTimeZone]];
    return dateFormatter;
}

//=============================================================================

- (void) drawLowerLegend
{
    for (NSInteger i = 0; i < _dataSets.count; i++)
    {
        [self drawDataSetSquareAtIndex:i];
    }
}

//=============================================================================

- (void) drawDataSetSquareAtIndex: (NSInteger) index
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat x = chartPadding;
    
    if(index % 2 != 0)
    {
        x += _plotWidth / 2.0;
    }
    CGFloat y = _plotHeight + chartTopPadding + chartPadding;
    
    UIFont* textFont = [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize];
    NSDictionary* attributes = @{
                                 NSFontAttributeName : textFont,
                                 NSForegroundColorAttributeName : [UIColor gm_grayColor]};
    
    UIColor* legendColor = [_dataSets[index] plotColor] ? [_dataSets[index] plotColor] : [UIColor gm_grayColor];
    [self drawRounedRectWithRect: CGRectMake(x, y, defaultLegendSquare, defaultLegendSquare)
                    cornerRaduis: 5.0
                           color: legendColor
                      forContext: context];
    
    [[_dataSets[index] plotName] drawAtPoint: CGPointMake(x + chartPadding/2.0 + defaultLegendSquare, y + [[_dataSets[index] plotName] gm_heightForFont: textFont]/2.0)
                              withAttributes: attributes];
}

//=============================================================================

- (void) drawRounedRectWithRect: (CGRect) rect
                   cornerRaduis: (CGFloat) cornerRadius
                          color: (UIColor*) legendColor
                     forContext: (CGContextRef) context
{
    CGContextSetStrokeColorWithColor(context, legendColor.CGColor);
    CGContextSetFillColorWithColor(context, legendColor.CGColor);
    
    if(rect.size.height < rect.size.width)
    {
        CGRect circleRect = CGRectMake(rect.origin.x , rect.origin.y-rect.size.width, rect.size.width,  rect.size.width);
        CGContextFillEllipseInRect(context, circleRect);
    }
    else
    {
        UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect: rect
                                                              cornerRadius: cornerRadius];
        [bezierPath stroke];
        [bezierPath fill];
    }
    
}

//=============================================================================

- (void) highlightCellInGridAtRow: (NSInteger) row
                        andColumn: (NSInteger) column
                        withIndex: (GMPlotDirection) direction
{
    CGFloat stepY = _plotHeight/_yGridLines;
    
    if(row < 0 || row > _xGridLines)
        return;
    
    if(column < 0 || column+1 > _yGridLines)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGFloat x = chartPadding + _leftPadding + row*stepY;
    CGFloat y = chartTopPadding + (column)*stepY;
    
    CGContextAddRect(context, CGRectMake(x, y, stepY, stepY));
    
    
    _labelsGrid[column][row] = [NSNumber numberWithInteger:direction];
    
}

//=============================================================================

- (CGPoint) highlightedCellInGridAtRow: (NSInteger) row
                              atColumn: (NSInteger) column
                         withDirection: (GMPlotDirection) direction
                               andText: (NSString*) text
{
    CGFloat stepY = _plotHeight/_yGridLines;
    CGFloat stepX = _plotWidth / _xGridLines;
    
    CGFloat x = chartPadding + _leftPadding + row*stepY;
    CGFloat y = _plotHeight + chartTopPadding - (column+1)*stepY;
    
    CGFloat xTextWidth = [text gm_widthForFont: [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize]];
    CGFloat xTextHeight = [text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize]];
    
    if(direction == (GMPlotDirectionUp| GMPlotDirectionLeft))
    {
        return CGPointMake(x, y);
    }
    else
        if(direction == (GMPlotDirectionUp| GMPlotDirectionRight))
        {
            return CGPointMake(x+stepX-xTextWidth, y);
        }
        else
            if(direction == (GMPlotDirectionDown| GMPlotDirectionLeft))
            {
                return CGPointMake(x-5, y+stepX-xTextHeight/2.0);
            }
            else
                if(direction == (GMPlotDirectionDown| GMPlotDirectionRight))
                {
                    return CGPointMake(x+stepX, y+stepX*2-xTextHeight/2.0);
                }
    return CGPointMake(x, y);
}

//=============================================================================

- (CGPoint) closestFreeCellInGridAtRow: (NSInteger) x
                              atColumn: (NSInteger) y
                   withSearchDirection: (NSInteger) searchDirection
{
    if (self.showYValues)
    {
        if(x+1 < _xGridLines-1)
            x++;
    }
    if(x+1 >= _xGridLines)
        return CGPointMake(0, 0);
    
    NSInteger c1 = [_labelsGrid[y-1][x-1] integerValue];
    NSInteger c2 = [_labelsGrid[y-1][x] integerValue];
    NSInteger c3 = [_labelsGrid[y-1][x+1] integerValue];
    
    NSInteger c4 = [_labelsGrid[y][x-1] integerValue];
    NSInteger c5 = [_labelsGrid[y][x+1] integerValue];
    
    NSInteger c6 = [_labelsGrid[y+1][x-1] integerValue];
    NSInteger c7 = [_labelsGrid[y+1][x] integerValue];
    NSInteger c8 = [_labelsGrid[y+1][x+1] integerValue];
    
    
    if(searchDirection == (GMPlotDirectionUp| GMPlotDirectionLeft))
    {
        if(c1 == 0)
            return CGPointMake(x-1, y-1);
        if(c2 == 0)
            return CGPointMake(x, y-1);
        if(c4 == 0)
            return CGPointMake(x-1, y);
    }
    else
        if(searchDirection == (GMPlotDirectionUp| GMPlotDirectionRight))
        {
            if(c2 == 0)
                return CGPointMake(x, y-1);
            if(c3 == 0)
                return CGPointMake(x+1, y-1);
            if(c5 == 0)
                return CGPointMake(x+1, y);
        }
        else
            if(searchDirection == (GMPlotDirectionDown| GMPlotDirectionLeft))
            {
                if(c4 == 0)
                    return CGPointMake(x-1, y);
                if(c6 == 0)
                    return CGPointMake(x-1, y+1);
                if(c7 == 0)
                    return CGPointMake(x, y+1);
            }
            else
                if(searchDirection == (GMPlotDirectionDown| GMPlotDirectionRight))
                {
                    if(c5 == 0)
                        return CGPointMake(x+1, y);
                    if(c7 == 0)
                        return CGPointMake(x, y+1);
                    if(c8 == 0)
                        return CGPointMake(x+1, y+1);
                }
    return CGPointMake(0, 0);
}

//=============================================================================

- (void) printGrid
{
    NSString* str = @"";
    for (NSInteger i =0; i<[_labelsGrid count]; i++)
    {
        for (NSInteger j =0; j<[_labelsGrid[i] count]; j++)
        {
            str = [str stringByAppendingFormat:@"%@ ", _labelsGrid[i][j]];
        }
        str = [str stringByAppendingString:@"\n"];
        NSLog(@"%@", str);
        str = @"";
    }
}

@end
