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

static const CGFloat kDefaultGridLineWidth = 0.5f;
static const NSInteger kDefaultGridLines = 5;
static const CGFloat kDefaultSmallCircleRadius = 2.5;
static const NSString* const kDefaultDateFormat = @"EEE";
static const CGFloat kDefaultLegendSquare = 30.0f;
static const CGFloat kDefaultXSquaresCount = 14;
static const CGFloat kAxisLabelsPadding = 10;
static const CGFloat kAverageMinMaxDelimeter = 10;

static const CGFloat kDefaultChartPadding = 30.0f;
static const CGFloat kDefaultChartTopPadding = 60.0f;
static const CGFloat kDefaultChartBottomPadding = 120.0f;
static const CGFloat kDefaultMinGridSize = 30.0f;
static const NSInteger kDefaultCellsOffset = 3;
static const CGFloat kTextScaleHeight = 1.5;
static const CGFloat kTextLabelOffset = 5.0;
static const NSInteger kVerticalLinesStartIndex = -1;
const CGFloat GMChartViewDefaultFontSize = 10.5f;
const CGFloat GMChartViewDefaultCircleRadius = 2.5f;
const CGFloat GMChartViewDefaultLineWidth = 2.0f;

//=============================================================================

@implementation GMChartView

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (instancetype) initWithFrame: (CGRect) frame
{
    if(self == [super initWithFrame: frame])
    {
        [self setupDefaultViewLayout];
    }
    return self;
}

//=============================================================================

- (instancetype) initWithCoder: (NSCoder*) aDecoder
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
    _backgroundColor = [UIColor whiteColor];
    
    _leftPadding = 0.0f;
    
    _plotWidth = CGRectGetWidth(self.frame) - 2 * _chartPadding - _leftPadding;
    _plotHeight = CGRectGetHeight(self.frame) - _chartTopPadding - _chartBottomPadding;
    
    [self setupXLabel];
    [self setupYLabel];
    _xAxisLabel.text = @"";
    _yAxisLabel.text = @"";
    
    _defaultGridLineColor = [[UIColor lightGrayColor] CGColor];
    
    _dataSets = @[];
    
    _minX = MAXFLOAT;
    _minY = MAXFLOAT;
    
    _maxX = 0.0f;
    _maxY = 0.0f;
    
    _minGridSize = kDefaultMinGridSize;
    
    self.showGrid = YES;
    self.shouldAddMinYAverage = YES;
    
    self.chartPadding = kDefaultChartPadding;
    self.chartTopPadding = kDefaultChartTopPadding;
    self.chartBottomPadding = kDefaultChartBottomPadding;
    
    [self setShouldUseBezier: YES];
    [self setShouldPlotLabels: YES];
    
    [self setGridSize: GMGridSize16];
    [self setShouldUseBezier: YES];
    
    [self setChartInterpolation: GMChartInterpolationHermite];
    
    [self setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didRotateDeviceChangeNotification:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    _tileCache = [[NSMutableDictionary alloc] init];
}

//=============================================================================

-(void)didRotateDeviceChangeNotification:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

//=============================================================================

- (void) setupXLabel
{
    _xAxisLabel = [[UILabel alloc] initWithFrame: CGRectMake(_plotHeight + kAxisLabelsPadding, _chartPadding, _plotWidth, 0)];
    [_xAxisLabel setTextAlignment: NSTextAlignmentCenter];
    [_xAxisLabel setFont: [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize]];
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [_xAxisLabel setAutoresizingMask: mask];
    [self addSubview: _xAxisLabel];
}

//=============================================================================

- (void) setupYLabel
{
    _yAxisLabel = [[UILabel alloc] initWithFrame: CGRectMake(_chartPadding, kAxisLabelsPadding, _plotWidth, 0)];
    [_yAxisLabel setFont: [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize]];
    [self addSubview: _yAxisLabel];
}

//=============================================================================

- (void) setDataSetsWithArray: (NSArray*) dataSets
{
    _dataSets = [dataSets copy];
    [self clearTilesCache];
    [self setNeedsDisplay];
}

//=============================================================================

- (void) clearTilesCache
{
    [_tileCache removeAllObjects];
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
    UIImage *tileImage = [self cacheForRect: rect];
    
    if (tileImage)
    {
        CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, tileImage.CGImage);
        return;
    }
    
    [self prepareImageForRect: rect];
    
    [self plotChart];
    if ([_dataSets count])
        [self plotChartData];
    if ([self.delegate respondsToSelector: @selector(chartView:widthValueChanged:andHeightValueChanged:)])
    {
        [self.delegate chartView: self
               widthValueChanged: _plotWidth
           andHeightValueChanged: _plotHeight];
    }
    
    [self saveAndDrawImage: tileImage
                   forRect: rect];
}

//=============================================================================

- (UIImage*) cacheForRect: (CGRect) rect
{
    return [_tileCache objectForKey: [self cacheKeyForRect: rect]];
}

//=============================================================================

- (NSString*) cacheKeyForRect: (CGRect) rect
{
   return [NSString stringWithFormat:@"%f%f%f%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

//=============================================================================

- (void) prepareImageForRect: (CGRect) rect
{
    // prepare to draw the tile image
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // filp coords
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
}

//=============================================================================

- (void) saveAndDrawImage: (UIImage*) tileImage
                  forRect: (CGRect) rect
{
    tileImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_tileCache setObject: tileImage
                   forKey: [self cacheKeyForRect: rect]];
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, tileImage.CGImage);
}

//=============================================================================

- (void) plotChart
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil)
    {
        return;
    }
    [self clearContext];
    
    if(self.gridSize == GMGridSize18)
    {
        CGFloat yLabelsOffset = (((CGRectGetWidth(self.frame) - 2 * _chartPadding) /kDefaultXSquaresCount) * kDefaultCellsOffset);
        _leftPadding =  yLabelsOffset;
    }
    else
    {
        _leftPadding = 0.0f;
    }
    
    _plotWidth = CGRectGetWidth(self.frame) - 2 * _chartPadding - _leftPadding;
    _plotHeight = CGRectGetHeight(self.frame) - _chartTopPadding - _chartBottomPadding;
    [self calcScale];
    [self calculateLinesNumber];
    [self arrangeLabels];
    [self drawGrid];
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
    
    CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
    CGContextFillPath(context);
}

//=============================================================================

- (void) arrangeLabels
{
    [_xAxisLabel setTextColor:_xAxisColor];
    [_yAxisLabel setTextColor:_yAxisColor];
    
    CGFloat xTextHeight = [_xAxisLabel.text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize]];
    CGFloat yTextHeight = [_xAxisLabel.text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize]];
    
    [_xAxisLabel setFrame: CGRectMake(_chartPadding, _plotHeight + _chartTopPadding + xTextHeight / 2.0, _plotWidth, xTextHeight)];
    [_yAxisLabel setFrame: CGRectMake(_chartPadding, _chartTopPadding - yTextHeight * kTextScaleHeight, _plotWidth, yTextHeight)];
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
    _xGridLines = kDefaultGridLines;
    _yGridLines = kDefaultGridLines;
    
    CGFloat stepX = _plotWidth /kDefaultXSquaresCount;
    NSInteger fixedCount = _plotHeight / stepX;
    
    fixedCount = fixedCount - (fixedCount % 2);
    
    _plotHeight -= (_plotHeight - stepX * fixedCount);
    
    _xGridLines =kDefaultXSquaresCount;
    _yGridLines = fixedCount;
    
    _labelsGrid = [NSMutableArray array];
    
    NSInteger count = 0;
    if (self.gridSize == GMGridSize18)
    {
        count = _yGridLines + 1;
    }
    else
    {
        count = _yGridLines;
    };
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
    
    CGContextSetLineWidth(context, kDefaultGridLineWidth);
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
                                     NSFontAttributeName : [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize],
                                     NSForegroundColorAttributeName : textColor
                                     };
    [text drawAtPoint: point
       withAttributes: textAttributes];
}

//=============================================================================

- (void) drawYAxis
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, kDefaultGridLineWidth);
    CGContextSetStrokeColorWithColor(context, [_yAxisColor CGColor]);
    
    CGContextMoveToPoint(context, _chartPadding, _chartTopPadding);
    CGContextAddLineToPoint(context, _chartPadding, _plotHeight + _chartTopPadding);
    
    CGContextStrokePath(context);
}

//=============================================================================

- (void) drawVerticalLines
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, kDefaultGridLineWidth);
    CGContextSetStrokeColorWithColor(context, _defaultGridLineColor);
    
    CGFloat stepX = _plotWidth / _xGridLines;
    NSInteger howMany = _plotWidth/ stepX;
    
    NSInteger startIndex = 0;
    if (self.gridSize == GMGridSize18)
    {
        startIndex = kVerticalLinesStartIndex;
    }
    
    for (NSInteger i = startIndex; i <= howMany; i++)
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
    
    CGContextSetLineWidth(context, kDefaultGridLineWidth);
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
    {
        [self drawXLegend];
    }
    if (self.gridSize == GMGridSize18)
    {
        [self drawYLegend];
    }
    if (self.isStepUsed)
    {
        //[self drawLowerLegend];
    }
    if (self.shouldDrawCirclesOnAxis)
    {
        [self drawCirclesOnAxisWithContext: UIGraphicsGetCurrentContext()];
    }
}

//=============================================================================

- (void) calcScale
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil)
    {
        return;
    }
    
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
        
        CGFloat avgToAdd = fabs(_minY - _maxY) / kAverageMinMaxDelimeter;
        if (self.shouldAddMinYAverage)
            _minY = _minY - fmaxf(5.0, floorf(avgToAdd));
        _maxY = _maxY + fmaxf(1.0, floorf(avgToAdd));
        if(fabs(_minY - _maxY) < 0.1)
        {
            _minY -= floorf(_minY/2.0);
            _maxY += floorf(_maxY/2.0);
        }
    }
}

//=============================================================================

- (void) plotGraph
{
    if(_dataSets.count == 0)
    {
        return;
    }
    for (GMDataSet *dataSet in _dataSets)
    {
        [dataSet sortPoints];
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, GMChartViewDefaultLineWidth);
        CGContextSetStrokeColorWithColor(context,dataSet.plotColor ? [dataSet.plotColor CGColor] : [UIColor whiteColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        
        [self plotDataSet: dataSet
              withContext: context];
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
        res =  [self stepScaleForXValue: xValue];
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

- (CGFloat) stepScaleForXValue: (CGFloat) xValue
{
    CGFloat scale = 0.0f;
    CGFloat stepX = (_plotWidth / _xGridLines) * 2;
    switch ([[_dataSets firstObject] dataGrouping])
    {
        case GMDataGroupDays:
            scale = stepX * ((xValue - _minX) / (SECS_PER_DAY));
            break;
        case GMDataGroupWeeks:
        case GMDataGroupMonth:
        case GMDataGroupYears:
            scale = stepX * [[_dataSets firstObject] indexOfPointWithXValue: xValue];
            break;
        default:
            break;
    }
    return scale;
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
    
    CGContextSetLineWidth(context, kDefaultGridLineWidth);
    
    UIFont* textFont = [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize];
    
    NSInteger amountPerLine = (SECS_PER_DAY) / 2;
    CGFloat stepX = (_plotWidth / _xGridLines) * 2;
    
    for (NSInteger i = 0; i < _xGridLines; i++)
    {
        if (i % 2 == 0)
        {
            UIColor *textColor = [self colorForDataSet: _dataSets[0]
                                              withDate: [NSDate dateWithTimeIntervalSinceReferenceDate:_minX + i * amountPerLine]];
            
            CGFloat x =  0.0f;
            switch ([[_dataSets firstObject] dataGrouping])
            {
                case GMDataGroupDays:
                    x = [self xCoordinatesForValue:_minX + i * amountPerLine];
                    break;
                case GMDataGroupWeeks:
                case GMDataGroupMonth:
                case GMDataGroupYears:
                    x =  self.chartPadding + _leftPadding + (stepX / 2.0)* i;
                    textColor = [UIColor gm_greenColor];
                    break;
                default:
                    break;
            }
            
            CGFloat y = _plotHeight + _chartTopPadding;
            
            CGRect rect = CGRectMake(x - kDefaultSmallCircleRadius, y -kDefaultSmallCircleRadius, 2 *kDefaultSmallCircleRadius, 2 *kDefaultSmallCircleRadius);
            CGContextAddEllipseInRect(context, rect);         
            
            NSDictionary *attributes = @{
                                         NSFontAttributeName : textFont,
                                         NSForegroundColorAttributeName : textColor};
            NSString* legendText = @"";
            if( [[_dataSets firstObject] dataGrouping] == GMDataGroupDays)
            {
                legendText = [NSString stringWithFormat:@"%@", [[self defaultDateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate: _minX + i * amountPerLine]]];
            }
            else
            {
                legendText = [[_dataSets firstObject] dateStringForPointAtIndex: i/2];
            }
            
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
    
    CGContextSetLineWidth(context, kDefaultGridLineWidth);
    
    UIFont* textFont = [GMChartUtils gm_defaultLightFontWithSize: GMChartViewDefaultFontSize - 2.0];
    
    CGFloat stepY = (_maxY -_minY) / _yGridLines;
    
    for (NSInteger i = 1; i <= _yGridLines; i++)
    {
        if (i % 2 == 0 && [self yCoordinatesForValue:(i * stepY)] >= _chartTopPadding)
        {
            CGFloat x = _chartPadding;
            CGFloat y = [self yCoordinatesForValue:_minY + (i * stepY)];
            
            CGRect rect = CGRectMake(x -kDefaultSmallCircleRadius, y -kDefaultSmallCircleRadius, 2 *kDefaultSmallCircleRadius, 2 *kDefaultSmallCircleRadius);
            CGContextAddEllipseInRect(context, rect);
            
            NSDictionary *attributes = @{
                                         NSFontAttributeName : textFont,
                                         NSForegroundColorAttributeName : [UIColor whiteColor]};
            NSString* legendText = [NSString stringWithFormat:@"%.0f", _minY +(i * stepY) ];
            
            x += fminf(kTextLabelOffset, [legendText gm_widthForFont: textFont]);
            [legendText drawAtPoint: CGPointMake(x, y + fminf(kTextLabelOffset, [legendText gm_heightForFont: textFont] / 2.0))
                     withAttributes: attributes];
            
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }
}

//=============================================================================

- (NSDateFormatter*) defaultDateFormatter
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat: [kDefaultDateFormat copy]];
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
    
    UIFont* textFont = [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize];
    NSDictionary* attributes = @{
                                 NSFontAttributeName : textFont,
                                 NSForegroundColorAttributeName : [UIColor gm_grayColor]};
    
    UIColor* legendColor = [_dataSets[index] plotColor] ? [_dataSets[index] plotColor] : [UIColor gm_grayColor];
    [self drawRounedRectWithRect: CGRectMake(x, y,kDefaultLegendSquare,kDefaultLegendSquare)
                    cornerRaduis:kDefaultSmallCircleRadius * 2
                           color: legendColor
                      forContext: context];
    
    [[_dataSets[index] plotName] drawAtPoint: CGPointMake(x + _chartPadding/2.0 +kDefaultLegendSquare, y + [[_dataSets[index] plotName] gm_heightForFont: textFont] / 2.0)
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
    {
        return;
    }
    
    if(column < 0 || column + 1 > _yGridLines)
    {
        return;
    }
    
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
    [self drawCircleAtXCoordinate: self.chartPadding + _leftPadding + _plotWidth
                      yCoordinate: self.chartTopPadding
                        fillColor: [UIColor whiteColor]
                       andContext: context];
    CGContextFillPath(context);
    
    [self drawCircleAtXCoordinate: self.chartPadding + _leftPadding
                      yCoordinate: _plotHeight + self.chartTopPadding
                        fillColor: [UIColor gm_greenColor]
                       andContext: context];
    [self drawCircleAtXCoordinate: self.chartPadding + _leftPadding + _plotWidth
                      yCoordinate: _plotHeight + self.chartTopPadding
                        fillColor: [UIColor gm_greenColor]
                       andContext: context];
    
    [self drawCircleAtXCoordinate: self.chartPadding
                      yCoordinate: [self yCoordinatesForValue: [[_dataSets[0] firstDataPoint] yValue]]
                        fillColor: [UIColor gm_greenColor]
                       andContext: context];
    
    [self drawCircleAtXCoordinate: self.chartPadding + _leftPadding + _plotWidth
                      yCoordinate: [self yCoordinatesForValue: [[_dataSets[0] lastDataPoint] yValue]]
                        fillColor: [UIColor gm_greenColor]
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
    CGRect rect = CGRectMake(x - GMChartViewDefaultCircleRadius, y - GMChartViewDefaultCircleRadius, 2 * GMChartViewDefaultCircleRadius, 2 * GMChartViewDefaultCircleRadius);
    CGContextAddEllipseInRect(context, rect);
}

//=============================================================================

- (CGFloat) height
{
    if(self.gridSize == GMGridSize18)
    {
        CGFloat yLabelsOffset = (((CGRectGetWidth(self.frame) - 2 * _chartPadding) /kDefaultXSquaresCount) * kDefaultCellsOffset);
        _leftPadding =  yLabelsOffset;
    }
    else
    {
        _leftPadding = 0.0f;
    }
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
