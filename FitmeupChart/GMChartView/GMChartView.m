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

//=============================================================================

const CGFloat chartPadding = 30.0f;
const CGFloat chartTopPadding = 60.0f;
const CGFloat chartBottomPadding = 120.0f;
const CGFloat defaultLineWidth = 2.0f;
const CGFloat defaultGridLineWidth = 0.5f;
const NSInteger defaultGridLines = 5;
const CGFloat defaultFontSize = 21.0f;
const CGFloat defaultCircleRadius = 5;
const CGFloat defaultSmallCircleRadius = 2.5;
const NSString* defaultDateFormat = @"EEE";
const CGFloat defaultLegendSquare = 30.0f;

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
    
    _plotWidth = CGRectGetWidth(self.frame) - 2 * chartPadding;
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
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didRotateDeviceChangeNotification:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
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
    [_xAxisLabel setFont: [UIFont systemFontOfSize:defaultFontSize]];
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [_xAxisLabel setAutoresizingMask: mask];
    [self addSubview: _xAxisLabel];
}

//=============================================================================

- (void) setupYLabel
{
    _yAxisLabel = [[UILabel alloc] initWithFrame: CGRectMake(chartPadding, 10, _plotWidth, 0)];
    [_yAxisLabel setFont: [UIFont systemFontOfSize:defaultFontSize]];
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
        
        _plotWidth = CGRectGetWidth(self.frame) - 2 * chartPadding;
        _plotHeight = CGRectGetHeight(self.frame) -  chartTopPadding - chartBottomPadding;
        
        [self arrangeLabels];
        [self calcScale];
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
    
    CGFloat xTextHeight = [_xAxisLabel.text gm_heightForFont: [UIFont systemFontOfSize:defaultFontSize]];
    CGFloat yTextHeight = [_xAxisLabel.text gm_heightForFont: [UIFont systemFontOfSize:defaultFontSize]];
    
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
    
    NSInteger amountOfDays = (_maxX - _minX)/SECS_PER_DAY;
    CGFloat stepX = _plotWidth / amountOfDays;
    /*_minGridSize = stepX;
    
    stepX = _plotWidth / _xGridLines;
    CGFloat stepY = _plotHeight / _yGridLines;
    
    CGFloat epsilon = 1.0;
    while(fabsf(stepX - stepY) > epsilon || stepX - _minGridSize > epsilon)
    {
        if ((stepX - stepY) > epsilon)
        {
            _xGridLines++;
        }
        else
            if ((stepY - stepX) > epsilon)
            {
                _yGridLines++;
            }
        stepX = _plotWidth / _xGridLines;
        stepY = _plotHeight / _yGridLines;
        if(fabsf(stepX - stepY) < epsilon && stepX - _minGridSize > epsilon)
        {
            _xGridLines++;
            _yGridLines++;
        }
    }
    NSLog(@"diff %f", _minGridSize/stepX);*/
    //_minX -= (SECS_PER_DAY)*1.2;
    //_maxX += (SECS_PER_DAY)*1.2;
    //_minX - 0
    _xGridLines = (_plotWidth/stepX);
    _yGridLines = (_plotHeight/stepX);
}

//=============================================================================

- (void) drawXAxis
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultLineWidth);
    CGContextSetStrokeColorWithColor(context, [_xAxisColor CGColor]);
    
    CGContextMoveToPoint(context, chartPadding, _plotHeight + chartTopPadding);
    CGContextAddLineToPoint(context, _plotWidth + chartPadding, _plotHeight + chartTopPadding);
    
    CGContextStrokePath(context);
}

//=============================================================================

- (void) drawText: (NSString*) text
          atPoint: (CGPoint) point
         andColor: (UIColor*) textColor
{
    UIFont *font = [UIFont systemFontOfSize:defaultFontSize];
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : textColor
                                     };
    [text drawAtPoint:point withAttributes:textAttributes];
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
    
    for (NSInteger i = 1; i <= howMany; i++)
    {
        CGContextMoveToPoint(context,chartPadding + i * stepX, chartTopPadding);
        CGContextAddLineToPoint(context, chartPadding + i * stepX, _plotHeight + chartTopPadding);
    }
    
    CGContextStrokePath(context);
}

//=============================================================================

- (void) drawHorizontalLines
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, defaultGridLineWidth);
    CGContextSetStrokeColorWithColor(context, _defaultGridLineColor);
    
    CGFloat stepY = _plotHeight / _yGridLines;
    NSInteger howManyHorizontal = _plotHeight / stepY;
    
    for (NSInteger i = 1; i <= howManyHorizontal; i++)
    {
        CGContextMoveToPoint(context, chartPadding, _plotHeight + chartTopPadding - i * stepY);
        CGContextAddLineToPoint(context, _plotWidth + chartPadding, _plotHeight + chartTopPadding - i * stepY);
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
    [self drawYLegend];
    [self drawLowerLegend];
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
            _minY = _minY - avgToAdd;
            _maxY = _maxY + avgToAdd;
            
            _minX = [[[NSDate dateWithTimeIntervalSinceReferenceDate:_minX] gm_startOfDay] timeIntervalSinceReferenceDate] - 86400;
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
            }
            CGContextSetStrokeColorWithColor(context,dataSet.plotColor ? [dataSet.plotColor CGColor] : [UIColor whiteColor].CGColor);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
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
                    GMDataPoint *dataPoint = [dataSet dataPointAtIndex:index];
                    float x = [self xCoordinatesForValue:dataPoint.xValue];
                    float y = [self yCoordinatesForValue:dataPoint.yValue];
                    
                    if(dataPoint.shouldShowLabel)
                    {
                        UIColor* colorForText = dataPoint.pointStyle == GMPointUpperStyle ? [UIColor gm_redColor] : [UIColor gm_greenColor];
                        
                        [self drawCircleAtXCoordinate:x
                                          yCoordinate:y
                                            fillColor:colorForText
                                           andContext:context];
                        
                        [self drawText:dataPoint.pointLabelText
                           xCoordinate:x yCoordinate:y
                             fillColor:colorForText
                            pointStyle:dataPoint.pointStyle
                            andContext:context];
                        
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
    UIFont* textFont = [UIFont boldSystemFontOfSize:defaultFontSize];
    
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : textFont,
                                 NSForegroundColorAttributeName : color};
    
    CGFloat textHeight = [text gm_heightForFont:textFont];
    CGFloat textWidth = [text gm_widthForFont:textFont];
    
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
    CGFloat xOld = (xValue * _plotWidth) / _maxX;
    CGFloat xMinOffset = (_minX * _plotWidth) / _maxX;
    
    CGFloat scaleX = _plotWidth / (_plotWidth - xMinOffset);
    
    CGFloat res = (xOld - xMinOffset) * scaleX;
    return chartPadding + res;
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
    
    UIFont* textFont = [UIFont boldSystemFontOfSize:defaultFontSize-15];
    
    NSInteger amountOfDays = (_maxX - _minX)/SECS_PER_DAY;
    CGFloat stepX = _plotWidth / amountOfDays;
    NSInteger howMany = _plotWidth / stepX;
    
    for (NSInteger i = 0; i <= amountOfDays; i++)
    {
        if (YES)
        {
            CGFloat x = chartPadding + i * stepX;
            CGFloat y = _plotHeight + chartTopPadding;
            
            CGRect rect = CGRectMake(x - defaultSmallCircleRadius, y - defaultSmallCircleRadius, 2 * defaultSmallCircleRadius, 2 * defaultSmallCircleRadius);
            CGContextAddEllipseInRect(context, rect);
            
            NSDictionary *attributes = @{
                                         NSFontAttributeName : textFont,
                                         NSForegroundColorAttributeName : [UIColor gm_greenColor]};
            NSString* legendText = [NSString stringWithFormat:@"%@", [[self defaultDateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_minX + i * SECS_PER_DAY]]];
            
            CGFloat textHeight = [legendText gm_heightForFont: textFont];
            if(i == howMany)
            {
                x -= [legendText gm_widthForFont: textFont];
            }
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
    
    UIFont* textFont = [UIFont boldSystemFontOfSize:defaultFontSize-10];
    
    CGFloat stepY = _plotHeight / _yGridLines;
    
    for (NSInteger i = 0; i <= _yGridLines; i++)
    {
        if (i % 2 == 0 || i == _yGridLines)
        {
            CGFloat x = chartPadding;
            CGFloat y = (_plotHeight - i * stepY)+ chartTopPadding;
            
            CGRect rect = CGRectMake(x - defaultSmallCircleRadius, y - defaultSmallCircleRadius, 2 * defaultSmallCircleRadius, 2 * defaultSmallCircleRadius);
            CGContextAddEllipseInRect(context, rect);
            
            NSDictionary *attributes = @{
                                         NSFontAttributeName : textFont,
                                         NSForegroundColorAttributeName : [UIColor gm_grayColor]};
            NSString* legendText = [NSString stringWithFormat:@"%0.0f", (i * (_maxY - _minY)/_yGridLines) +_minY ];
            
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
    CGFloat y = _plotHeight + chartTopPadding + chartPadding*1.5;
    
    UIFont* textFont = [UIFont boldSystemFontOfSize:defaultFontSize-10];
    NSDictionary* attributes = @{
                                 NSFontAttributeName : textFont,
                                 NSForegroundColorAttributeName : [UIColor gm_grayColor]};
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect :CGRectMake(x, y, defaultLegendSquare, defaultLegendSquare)
                                                          cornerRadius: 5.0];
    
    UIColor* legendColor = [_dataSets[index] plotColor] ? [_dataSets[index] plotColor] : [UIColor gm_grayColor];
    CGContextSetStrokeColorWithColor(context, legendColor.CGColor);
    CGContextSetFillColorWithColor(context, legendColor.CGColor);
    [bezierPath stroke];
    [bezierPath fill];
    
    [[_dataSets[index] plotName] drawAtPoint: CGPointMake(x + chartPadding/2.0 + defaultLegendSquare, y + [[_dataSets[index] plotName] gm_heightForFont: textFont]/2.0)
             withAttributes: attributes];
}

//=============================================================================

@end
