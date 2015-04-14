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
    
    _plotWidth = CGRectGetWidth(self.frame) - 2 * _chartPadding - _leftPadding;
    _plotHeight = CGRectGetHeight(self.frame) - _chartTopPadding - _chartBottomPadding;
    
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
    
    self.chartPadding = 30.0f;
    self.chartTopPadding = 60.0f;
    self.chartBottomPadding = 120.0f;
    
    [self setShowYValues: YES];
    [self setShouldUseBezier: NO];
    [self setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [self setTranslatesAutoresizingMaskIntoConstraints: YES];
}

//=============================================================================

- (void) setupXLabel
{
    _xAxisLabel = [[UILabel alloc] initWithFrame: CGRectMake(_plotHeight + 10, _chartPadding, _plotWidth, 0)];
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
    _yAxisLabel = [[UILabel alloc] initWithFrame: CGRectMake(_chartPadding, 10, _plotWidth, 0)];
    [_yAxisLabel setFont: [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
    [self addSubview: _yAxisLabel];
}

//=============================================================================

- (void) setDataSetsWithArray: (NSArray*) dataSets
{
    _dataSets = [dataSets copy];
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
        
        _leftPadding = self.showYValues ? ( ((CGRectGetWidth(self.frame) - 2 * _chartPadding) / defaultXSquaresCount) * 3) : 0.0f;
        
        _plotWidth = CGRectGetWidth(self.frame) - 2 * _chartPadding - _leftPadding;
        _plotHeight = CGRectGetHeight(self.frame) - _chartTopPadding - _chartBottomPadding;
        
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
    
    CGFloat xTextHeight = [_xAxisLabel.text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
    CGFloat yTextHeight = [_xAxisLabel.text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
    
    [_xAxisLabel setFrame: CGRectMake(_chartPadding, _plotHeight + _chartTopPadding + xTextHeight/2.0, _plotWidth, xTextHeight)];
    [_yAxisLabel setFrame: CGRectMake(_chartPadding, _chartTopPadding - yTextHeight * 1.5, _plotWidth, yTextHeight)];
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
    fixedCount = fixedCount - (fixedCount % 2);
    _plotHeight -= (_plotHeight - stepX * fixedCount);
    
    _xGridLines = defaultXSquaresCount;
    _yGridLines = fixedCount;
    
    _labelsGrid = [NSMutableArray array];
    NSInteger count = self.showYValues ? _yGridLines + 1 : _yGridLines;
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
    
    CGContextMoveToPoint(context, _chartPadding, _plotHeight + _chartTopPadding);
    CGContextAddLineToPoint(context, _plotWidth + _chartPadding+_leftPadding, _plotHeight + _chartTopPadding);
    
    CGContextStrokePath(context);
}

//=============================================================================

- (void) drawText: (NSString*) text
          atPoint: (CGPoint) point
         andColor: (UIColor*) textColor
{
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize],
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
    
    CGContextMoveToPoint(context, _chartPadding, _chartTopPadding);
    CGContextAddLineToPoint(context, _chartPadding, _plotHeight + _chartTopPadding);
    
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
        CGContextMoveToPoint(context, _chartPadding + i * stepX + _leftPadding, _chartTopPadding);
        CGContextAddLineToPoint(context, _chartPadding + i * stepX + _leftPadding, _plotHeight + _chartTopPadding);
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
        CGContextMoveToPoint(context, _chartPadding, _plotHeight + _chartTopPadding - i * stepY);
        CGContextAddLineToPoint(context, _plotWidth + _chartPadding + _leftPadding, _plotHeight + _chartTopPadding - i * stepY);
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
    //[self printGrid];
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
            
            _minX = [[[NSDate dateWithTimeIntervalSinceReferenceDate: _minX] gm_startOfDay] timeIntervalSinceReferenceDate];
            _maxX = [[[NSDate dateWithTimeIntervalSinceReferenceDate: _maxX] gm_startOfDay] timeIntervalSinceReferenceDate];
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
            
            [self plotDataSet: dataSet
                   withContet: context];
        }
    }
}

- (void) plotDataSet: (GMDataSet*) dataSet
          withContet: (CGContextRef) context
{
}

//=============================================================================

- (void) plotLabels
{
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
                    
                    NSInteger row = floorf((x - _leftPadding - _chartPadding) / (_plotWidth / _xGridLines));
                    NSInteger col = floorf((y - _chartTopPadding) / (_plotHeight / _yGridLines));
                    
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
                            GMPlotDirection direction = [_labelsGrid[col][row] integerValue];
                            
                            [self drawText: dataPoint.pointLabelText
                               xCoordinate: x
                               yCoordinate: y
                                 fillColor: colorForText
                                pointStyle: dataPoint.pointStyle
                                 direction: direction
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
        direction: (GMPlotDirection) direction
       andContext: (CGContextRef) context
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize],
                                 NSForegroundColorAttributeName : color};
    
    CGFloat textHeight = [text gm_heightForFont:[GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
    CGFloat textWidth = [text gm_widthForFont:[GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
    
    CGFloat step = (_plotHeight / _yGridLines);
    CGFloat rawY = y - _chartTopPadding;
    
    NSInteger col = (x - _leftPadding - _chartPadding) / step;
    NSInteger row = (y - _chartTopPadding) / step;
    
    CGFloat colLeft = fmodf(rawY, step);
    //NSLog(@"%ld - %ld", (long)row, (long)col);
    if(colLeft < step / 2.0)
    {
        //[self drawCircleAtXCoordinate:x yCoordinate:y - colLeft fillColor:[UIColor blueColor] andContext:UIGraphicsGetCurrentContext()];
        y -= colLeft;
    }
    else
    {
        if(fabs(colLeft - step / 2.0) < 1.0)
        {
            NSLog(@"%f", fabs(colLeft - step/2.0));
            //[self drawCircleAtXCoordinate:x yCoordinate:y + ((_plotHeight / _yGridLines) - colLeft) fillColor:[UIColor blueColor] andContext:UIGraphicsGetCurrentContext()];
            y -= step ;
            y += (step - colLeft);
            
        }
        else
        {
            y += (step - colLeft);
        }
    }
    
    if(direction == (GMPlotDirectionLeft | GMPlotDirectionUp))
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
                NSString *directionStr = [self directionCellInGridAtRow: row
                                                               atColumn: col];
                
                //NSLog(@"direction %@", directionStr);
                y = [self adjustY: y
                      basedOnPath: directionStr];
                x = [self adjustX: x
                      basedOnPath: directionStr];
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
                NSString *directionStr = [self directionCellInGridAtRow: row
                                                               atColumn: col];
                y = [self adjustY: y
                      basedOnPath: directionStr];
                x = [self adjustX: x
                      basedOnPath: directionStr];
            }
        }
        
    }
    [text drawAtPoint: CGPointMake(x, y)
       withAttributes: attributes];
}

//=============================================================================

- (CGFloat) xCoordinatesForValue: (CGFloat) xValue
{
    CGFloat stepX = (_plotWidth / _xGridLines) * 2;
    CGFloat res = stepX * ((xValue - _minX) / SECS_PER_DAY);
    
    return _chartPadding + res + _leftPadding;
}

//=============================================================================

- (CGFloat) yCoordinatesForValue: (CGFloat) yValue
{
    CGFloat yOld = (yValue * _plotHeight) / _maxY;
    CGFloat yMinOffset = (_minY * _plotHeight) / _maxY;
    
    CGFloat scaleY = _plotHeight / (_plotHeight - yMinOffset);
    
    CGFloat res = (yOld - yMinOffset) * scaleY;
    
    return _chartTopPadding + _plotHeight - res;
}

//=============================================================================

- (void) drawXLegend
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultGridLineWidth);
    
    UIFont* textFont = [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize];
    
    NSInteger amountPerLine = SECS_PER_DAY/2;
    
    for (NSInteger i = 0; i < _xGridLines; i++)
    {
        if (i % 2 == 0)
        {
            CGFloat x = [self xCoordinatesForValue:_minX + i * amountPerLine];
            CGFloat y = _plotHeight + _chartTopPadding;
            
            CGRect rect = CGRectMake(x - defaultSmallCircleRadius, y - defaultSmallCircleRadius, 2 * defaultSmallCircleRadius, 2 * defaultSmallCircleRadius);
            CGContextAddEllipseInRect(context, rect);
            
            UIColor *textColor = [self colorForDataSet: _dataSets[0]
                                              withDate: [NSDate dateWithTimeIntervalSinceReferenceDate:_minX + i * amountPerLine]];
            
            NSDictionary *attributes = @{
                                         NSFontAttributeName : textFont,
                                         NSForegroundColorAttributeName : textColor};
            NSString* legendText = [NSString stringWithFormat:@"%@", [[self defaultDateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate: _minX + i * amountPerLine]]];
            
            CGFloat textHeight = [legendText gm_heightForFont: textFont];
            x -= [legendText gm_widthForFont: textFont] / 2.0;
            
            [legendText drawAtPoint: CGPointMake(x, y + textHeight / 2.0)
                     withAttributes: attributes];
            
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }
}

- (UIColor*) colorForDataSet: (GMDataSet*) dataSet
                    withDate: (NSDate*) date
{
    return [UIColor gm_grayColor];
}

//=============================================================================

- (void) drawYLegend
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultGridLineWidth);
    
    UIFont* textFont = [GMChartUtils gm_defaultLightFontWithSize:defaultFontSize - 2.0];
    
    CGFloat stepY = (_maxY -_minY) / _yGridLines;
    
    for (NSInteger i = 1; i <= _yGridLines; i++)
    {
        if (i % 2 == 0 && [self yCoordinatesForValue:(i * stepY)] >= _chartTopPadding)
        {
            CGFloat x = _chartPadding;
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
    CGFloat x = _chartPadding;
    
    if(index % 2 != 0)
    {
        x += _plotWidth / 2.0;
    }
    CGFloat y = _plotHeight + _chartTopPadding + _chartPadding;
    
    UIFont* textFont = [GMChartUtils gm_defaultBoldFontWithSize:defaultFontSize];
    NSDictionary* attributes = @{
                                 NSFontAttributeName : textFont,
                                 NSForegroundColorAttributeName : [UIColor gm_grayColor]};
    
    UIColor* legendColor = [_dataSets[index] plotColor] ? [_dataSets[index] plotColor] : [UIColor gm_grayColor];
    [self drawRounedRectWithRect: CGRectMake(x, y, defaultLegendSquare, defaultLegendSquare)
                    cornerRaduis: 5.0
                           color: legendColor
                      forContext: context];
    
    [[_dataSets[index] plotName] drawAtPoint: CGPointMake(x + _chartPadding/2.0 + defaultLegendSquare, y + [[_dataSets[index] plotName] gm_heightForFont: textFont] / 2.0)
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
        CGRect circleRect = CGRectMake(rect.origin.x , rect.origin.y - rect.size.width, rect.size.width,  rect.size.width);
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
    CGFloat x = _chartPadding + _leftPadding + row*stepY;
    CGFloat y = _chartTopPadding + (column)*stepY;
    
    //CGContextAddRect(context, CGRectMake(x, y, stepY, stepY));
    
    
    _labelsGrid[column][row] = [NSNumber numberWithInteger:direction];
    
}

#pragma mark - TEST -

//=============================================================================

- (CGPoint) highlightedCellInGridAtRow: (NSInteger) row
                              atColumn: (NSInteger) column
                         withDirection: (GMPlotDirection) direction
                               andText: (NSString*) text
{
    CGFloat stepY = _plotHeight/_yGridLines;
    CGFloat stepX = _plotWidth / _xGridLines;
    
    CGFloat x = _chartPadding + _leftPadding + row*stepY;
    CGFloat y = _plotHeight + _chartTopPadding - (column+1)*stepY;
    
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

- (NSString*) directionCellInGridAtRow: (NSInteger) x
                              atColumn: (NSInteger) y
{
    if(y+1 >= _yGridLines)
        return @"";
    if(x+1 >= _xGridLines)
        return @"";
    NSInteger c1 = [_labelsGrid[x-1][y-1] integerValue];
    //NSInteger c2 = [_labelsGrid[x][y-1] integerValue];
    NSInteger c3 = [_labelsGrid[x+1][y-1] integerValue];
    
    NSInteger center = [_labelsGrid[x][y] integerValue];
    
    if (c1==c3 && c1==0)
    {
        c1 = center;
    }
    
    NSInteger c4 = [_labelsGrid[x-1][y+1] integerValue];
    //NSInteger c5 = [_labelsGrid[x][y+1] integerValue];
    NSInteger c6 = [_labelsGrid[x+1][y+1] integerValue];
    
    if(c1 !=0 || c4 != 0)
    {
        if(c1 == (GMPlotDirectionUp| GMPlotDirectionLeft) && (c4 ==  (GMPlotDirectionUp| GMPlotDirectionLeft) || center ==  (GMPlotDirectionUp| GMPlotDirectionLeft)))
        {
            return @"UU";
        }
        else
            if(c1 == (GMPlotDirectionDown| GMPlotDirectionLeft) && (c4 ==  (GMPlotDirectionUp| GMPlotDirectionLeft) || center ==  (GMPlotDirectionUp| GMPlotDirectionLeft)))
            {
                return @"DU";
            }
            else
                if(c1 == (GMPlotDirectionUp| GMPlotDirectionLeft) && (c4 ==  (GMPlotDirectionDown| GMPlotDirectionLeft)|| center ==  (GMPlotDirectionDown| GMPlotDirectionLeft)))
                {
                    return @"UD";
                }
                else
                    if(c1 == (GMPlotDirectionDown| GMPlotDirectionLeft) && (c4 ==  (GMPlotDirectionDown| GMPlotDirectionLeft)|| center ==  (GMPlotDirectionDown| GMPlotDirectionLeft)))
                    {
                        return @"DD";
                    }
    }
    else
    {
        if(c3 == (GMPlotDirectionUp| GMPlotDirectionLeft) && (c6 ==  (GMPlotDirectionUp| GMPlotDirectionLeft)|| center ==  (GMPlotDirectionUp| GMPlotDirectionLeft)))
        {
            return @"UU";
        }
        else
            if(c3 == (GMPlotDirectionDown| GMPlotDirectionLeft) && (c6 ==  (GMPlotDirectionUp| GMPlotDirectionLeft)|| center ==  (GMPlotDirectionUp| GMPlotDirectionLeft)))
            {
                return @"DU";
            }
            else
                if(c3 == (GMPlotDirectionUp| GMPlotDirectionLeft) && (c6 ==  (GMPlotDirectionDown| GMPlotDirectionLeft)|| center ==  (GMPlotDirectionDown| GMPlotDirectionLeft)))
                {
                    return @"UD";
                }
                else
                    if(c3 == (GMPlotDirectionDown| GMPlotDirectionLeft) && (c6 ==  (GMPlotDirectionDown| GMPlotDirectionLeft)|| center ==  (GMPlotDirectionDown| GMPlotDirectionLeft)))
                    {
                        return @"DD";
                    }
    }
    
    return @"";
}

- (CGFloat) adjustY: (CGFloat) y
        basedOnPath: (NSString*) path
{
    CGFloat stepY = _plotHeight/_yGridLines;
    if([path isEqualToString:@"DD"])
    {
        return y - stepY;
    }
    if([path isEqualToString:@"UD"])
    {
        return y - stepY;
    }
    return y;
}

- (CGFloat) adjustX: (CGFloat) x
        basedOnPath: (NSString*) path
{
    CGFloat stepY = _plotHeight/_yGridLines;
    if([path isEqualToString:@"DD"])
    {
        return x + 3;
    }
    if([path isEqualToString:@"UU"])
    {
        return x + 3;
    }
    if([path isEqualToString:@"UD"])
    {
        return x + 3;
    }
    return x;
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
