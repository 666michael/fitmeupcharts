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


const CGFloat defaultGridLineWidth = 0.5f;
const NSInteger defaultGridLines = 5;
const CGFloat defaultSmallCircleRadius = 2.5;
const NSString* defaultDateFormat = @"EEE";
const CGFloat defaultLegendSquare = 30.0f;
const CGFloat defaultXSquaresCount = 14;
const CGFloat axisLabelsPadding = 10;
const CGFloat averageMinMaxDelimeter = 10;

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
    
    [self setShouldUseBezier: YES];
    [self setShouldPlotLabels: YES];
    
    [self setGridSize: GMGridSize16];
    [self setShouldUseBezier: YES];
    
    [self setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [self setTranslatesAutoresizingMaskIntoConstraints: YES];
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
    _xAxisLabel = [[UILabel alloc] initWithFrame: CGRectMake(_plotHeight + axisLabelsPadding, _chartPadding, _plotWidth, 0)];
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
    _yAxisLabel = [[UILabel alloc] initWithFrame: CGRectMake(_chartPadding, axisLabelsPadding, _plotWidth, 0)];
    [_yAxisLabel setFont: [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
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
    if (!self.isCached)
    {
        NSLog(@"draw");
        [self plotChart];
        [self plotChartData];
        if ([self.delegate respondsToSelector: @selector(chartView:widthValueChanged:andHeightValueChanged:)])
        {
            [self.delegate chartView: self
                   widthValueChanged: _plotWidth
               andHeightValueChanged: _plotHeight];
        }
    }
}

//=============================================================================

- (void) plotChart
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        [self clearContext];
        
        _leftPadding = self.gridSize == GMGridSize18 ? ( ((CGRectGetWidth(self.frame) - 2 * _chartPadding) / defaultXSquaresCount) * 3) : 0.0f;
        
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
    
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextFillPath(context);
}

//=============================================================================

- (void) arrangeLabels
{
    [_xAxisLabel setTextColor:_xAxisColor];
    [_yAxisLabel setTextColor:_yAxisColor];
    
    CGFloat xTextHeight = [_xAxisLabel.text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
    CGFloat yTextHeight = [_xAxisLabel.text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize: defaultFontSize]];
    
    [_xAxisLabel setFrame: CGRectMake(_chartPadding, _plotHeight + _chartTopPadding + xTextHeight / 2.0, _plotWidth, xTextHeight)];
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
    NSInteger count = self.gridSize == GMGridSize18 ? _yGridLines + 1 : _yGridLines;
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
    
    for (NSInteger i = self.gridSize == GMGridSize18 ? -1 : 0; i <= howMany; i++)
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
    if (!_xAxisLabel.text.length)
        [self drawXLegend];
    if (self.gridSize == GMGridSize18)
    {
        [self drawYLegend];
    }
    if (self.isStepUsed)
    {
        [self drawLowerLegend];
    }
    if (self.shouldDrawCirclesOnAxis)
    {
        [self drawCirclesOnAxisWithContext: UIGraphicsGetCurrentContext()];
    }
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
            
            CGFloat avgToAdd = fabs(_minY - _maxY) / averageMinMaxDelimeter;
            //_minY = _minY - fmaxf(1.0, floorf(avgToAdd));
            _maxY = _maxY + fmaxf(1.0, floorf(avgToAdd));
            if(fabs(_minY - _maxY) < 0.1)
            {
                _minY -= floorf(_minY/2.0);
                _maxY += floorf(_maxY/2.0);
            }
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
                  withContext: context];
        }
    }
}

//=============================================================================

- (void) plotDataSet: (GMDataSet*) dataSet
         withContext: (CGContextRef) context
{
}

//=============================================================================

- (void) plotLabels
{
    
}

//=============================================================================

- (CGFloat) xCoordinatesForValue: (CGFloat) xValue
{
    CGFloat res = 0.0f;
    if (self.isStepUsed)
    {
        CGFloat stepX = (_plotWidth / _xGridLines) * 2;
        res = stepX * ((xValue - _minX) / SECS_PER_DAY);
    }
    else
    {
        CGFloat xOld = (xValue * _plotWidth) / _maxX;
        CGFloat xMinOffset = (_minX * _plotWidth) / _maxX;
        CGFloat scaleX = _plotWidth / (_plotWidth - xMinOffset);
        res = (xOld - xMinOffset) * scaleX;
    }
    
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
    if (!self.isStepUsed)
        return;
    
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
                    cornerRaduis: defaultSmallCircleRadius * 2
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
    if(row < 0 || row > _xGridLines)
        return;
    
    if(column < 0 || column + 1 > _yGridLines)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    _labelsGrid[column][row] = [NSNumber numberWithInteger:direction];
    
}

//=============================================================================

- (void) drawCirclesOnAxisWithContext: (CGContextRef) context;
{
    [self drawCircleAtXCoordinate: self.chartPadding + _leftPadding
                      yCoordinate: self.chartTopPadding
                        fillColor: [UIColor whiteColor]
                       andContext: context];
    [self drawCircleAtXCoordinate: self.chartPadding + _leftPadding
                      yCoordinate: _plotHeight + self.chartTopPadding
                        fillColor: [UIColor whiteColor]
                       andContext: context];
    [self drawCircleAtXCoordinate: self.chartPadding + _leftPadding + _plotWidth
                      yCoordinate: _plotHeight + self.chartTopPadding
                        fillColor: [UIColor whiteColor]
                       andContext: context];
    CGContextFillPath(context);
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

- (CGFloat) height
{
    _leftPadding = self.gridSize == GMGridSize18 ? ( ((CGRectGetWidth(self.frame) - 2 * _chartPadding) / defaultXSquaresCount) * 3) : 0.0f;
    [self calculateLinesNumber];
    return _plotHeight - self.chartTopPadding;
}

//=============================================================================

- (CGFloat) width
{
    return _plotWidth;
}

//=============================================================================


- (UIImage *)viewImage
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//=============================================================================

@end
