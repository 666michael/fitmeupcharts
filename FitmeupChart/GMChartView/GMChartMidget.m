//
//  GMChartMidget.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 13.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMChartMidget.h"
#import "GMPlainChartView.h"
#import "GMDataSet.h"
#import "GMCoreDataHelper.h"
#import "GMDatePoint.h"

//=============================================================================

const CGFloat kFlagRange = 20;
const CGFloat kDaysInStep = 7;
const CGFloat kLineWidth = 2;

//=============================================================================

@interface GMChartMidget() <GMChartViewProtocol>

@property (nonatomic) CGPoint touchStart;
@property (nonatomic) CGFloat widthStart;
@property (nonatomic) BOOL isResizing;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat fullWidth;
@property (nonatomic) UIView *innerFlagView;
@property (nonatomic) UIView *innerLineView;
@property (nonatomic) UIView *timeFlagView;
@property (nonatomic) GMPlainChartView *chartView;
@property (nonatomic) UIImageView *imageCacheView;
@end

//=============================================================================

@implementation GMChartMidget

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    if (self == nil)
        return nil;
    
    [self setupDefaultViewLayout];

    return self;
}

//=============================================================================

- (id) initWithCoder: (NSCoder*) aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self == nil)
        return nil;
    
    [self setupDefaultViewLayout];

    return self;
}

//=============================================================================

- (void) setupDefaultViewLayout
{
    self.chartView = [[GMPlainChartView alloc] initWithFrame: self.bounds];
    [self addSubview: self.chartView];
    [self.chartView setChartInterpolation: GMChartInterpolationQuad];
    [self.chartView.xAxisLabel setText: @""];
    [self.chartView.yAxisLabel setText: @""];
    
    [self.chartView setShowGrid: NO];
    [self.chartView setShouldAddMinYAverage: YES];
    
    [self.chartView setShouldPlotLabels: NO];
    [self.chartView setShouldUseBezier: YES];
    [self.chartView setIsStepUsed: NO];
    
    [self.chartView setChartTopPadding: 20.0f];
    [self.chartView setChartBottomPadding: 0.0f];
    
    [self.chartView setGridSize: GMGridSize16];
    
    [self.chartView setXAxisColor: [UIColor gm_greenColor]];
    [self.chartView setYAxisColor: [UIColor whiteColor]];
    [self.chartView setShouldDrawCirclesOnAxis: YES];
    [self.chartView setBackgroundColor: [UIColor gm_backgroundColor]];
    
    self.totalDataSet = [GMCoreDataHelper testDataSet];
    self.lastDateType = GMChartLastDateTypeCurrentDateWithLastValue;
    switch (self.lastDateType)
    {
        case GMChartLastDateTypeCurrentDateWithLastValue:
        {
            [self.totalDataSet addDataPoint: [[GMDatePoint alloc] initWithDate: [NSDate date]  yValue: [[self.totalDataSet lastDataPoint] yValue]]];
            break;
        }
        case GMChartLastDateTypeCurrentDateWithZeroValue:
        {
            [self.totalDataSet addDataPoint: [[GMDatePoint alloc] initWithDate: [NSDate date]  yValue: 0.0f]];
            break;
        }
        default:
            break;
    }
    
    [self.chartView setDataSetsWithArray: @[self.totalDataSet]];
    self.chartView.delegate = self;
    
    //[self setupImageView];
    
    self.flagColor = [UIColor whiteColor];
    [self setupTimeFlag];
}

//=============================================================================

- (void) setupTimeFlag
{
    self.timeFlagView = [[UIView alloc] initWithFrame: CGRectMake(self.chartView.chartPadding, self.chartView.chartTopPadding, [self.chartView width], [self.chartView height])];
    [self.timeFlagView setBackgroundColor: [UIColor clearColor]];
    [self addSubview: self.timeFlagView];
    
    self.innerFlagView = [[UIView alloc] initWithFrame: CGRectMake([self.chartView width] - kFlagRange, 0, kFlagRange, kFlagRange)];
    [self.innerFlagView setBackgroundColor: self.flagColor];
    [self.innerFlagView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin )];
    [self.innerFlagView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    self.innerLineView = [[UIView alloc] initWithFrame: CGRectMake([self.chartView width] - kLineWidth, 0, kLineWidth, kFlagRange/5)];
    [self.innerLineView setBackgroundColor: self.flagColor];
    [self.innerLineView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin )];
    [self.innerLineView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    self.innerFlagView.layer.mask = [self triangleMask];
    [self.timeFlagView addSubview: self.innerFlagView];
    [self.timeFlagView addSubview: self.innerLineView];
}

- (void) setupImageView
{
    self.imageCacheView = [[UIImageView alloc] initWithFrame: CGRectMake(0, self.frame.origin.y + [self.chartView height], [self.chartView width],  CGRectGetHeight(self.frame))];
    //[self.imageCacheView setContentMode: UIViewContentModeScaleAspectFill];
    //[self.imageCacheView setBackgroundColor: [UIColor redColor]];
    [self.imageCacheView setAlpha: 0.3];
    [self.imageCacheView  setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [self.imageCacheView  setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self addSubview: self.imageCacheView];
}

//=============================================================================

- (CAShapeLayer*) triangleMask
{
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint: CGPointMake(0, 0)];
    [trianglePath addLineToPoint: CGPointMake(kFlagRange,0)];
    [trianglePath addLineToPoint: CGPointMake(kFlagRange, kFlagRange)];
    [trianglePath closePath];
    
    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
    [triangleMaskLayer setPath: trianglePath.CGPath];
    
    return triangleMaskLayer;
}

//=============================================================================

- (void) setMaxWidth
{
    _maxWidth = CGRectGetWidth(self.timeFlagView.frame);
}

//=============================================================================

#pragma mark - Resize -

//=============================================================================

- (void) touchesBegan: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    _isResizing = NO;
    
    UITouch *touch = [touches anyObject];
    
    if ([self touchIsInRange: touch])
    {
        _widthStart = CGRectGetWidth(self.timeFlagView.frame);
        _touchStart = CGPointMake(_widthStart + self.chartView.chartPadding, 0);
        _isResizing = YES;
    }
}

//=============================================================================

- (BOOL) touchIsInRange: (UITouch *) touch
{
    return fabs([touch locationInView: self].x - CGRectGetMaxX(self.timeFlagView.frame)) < kFlagRange;
}

//=============================================================================

- (void) touchesMoved: (NSSet *)touches
            withEvent: (UIEvent *)event
{
    if (_isResizing)
    {
        if ([self touchIsInChart: [touches anyObject]])
        {
            CGFloat newWidth = _widthStart - (_touchStart.x - [[touches anyObject] locationInView: self].x);
            [self setWidthForTimeFlagWithValue: newWidth];
        }
    }
}

//=============================================================================

- (void) setWidthForTimeFlagWithValue: (CGFloat) width
{
    [self.timeFlagView setFrame: CGRectMake(self.chartView.chartPadding, self.chartView.chartTopPadding, width, CGRectGetHeight(self.timeFlagView.frame))];
    [self.innerFlagView setFrame: CGRectMake(width - kFlagRange, 0, kFlagRange, kFlagRange)];
    [self.innerLineView setFrame: CGRectMake(width - kLineWidth, 0, kLineWidth, CGRectGetHeight(self.timeFlagView.frame))];
}

//=============================================================================

- (BOOL) touchIsInChart: (UITouch *) touch
{
    CGFloat xCoord = [touch locationInView: self].x;
    return  self.chartView.chartPadding <= xCoord && xCoord <= self.chartView.chartPadding + _maxWidth;
}

//=============================================================================

- (void)touchesEnded: (NSSet *) touches
           withEvent: (UIEvent *) event
{
    if (_isResizing)
    {
        UITouch *touch = [touches anyObject];
        if([touch locationInView: self].x >=  self.chartView.chartPadding + _maxWidth)
        {
            [self setMaxFlagValue];
        }
        else
            if([touch locationInView: self].x <=  self.chartView.chartPadding)
            {
                [self setMinFlagValue];
            }
            else
            {
                CGFloat rawX = [touch locationInView: self].x - self.chartView.chartPadding;
                NSLog(@"%0.0f from %0.0f", rawX, _fullWidth);

                NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate: [[self.totalDataSet dataPointAtIndex: 0] xValue]];
                CGFloat countOfSteps = floorf(rawX / [self stepWidth]);
                self.startDate =  [startDate dateByAddingTimeInterval: countOfSteps * SECS_PER_WEEK];
            }
        if (self.delegate && [self.delegate respondsToSelector: @selector(chartMidget:startDateChanged:)])
        {
            [self.delegate chartMidget: self
                      startDateChanged: [self.startDate gm_startOfDay]];
        }
        _isResizing = NO;
    }
}

//=============================================================================

- (void) setMaxFlagValue
{
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate: [[self.totalDataSet dataPointAtIndex: 0] xValue]];
   
    [self setWidthForTimeFlagWithValue: _fullWidth- [self stepWidth]];
    self.startDate =  [startDate dateByAddingTimeInterval: ((_fullWidth- [self stepWidth]) / [self stepWidth]) * SECS_PER_WEEK];
}

//=============================================================================

- (void) setMinFlagValue
{
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate: [[self.totalDataSet dataPointAtIndex: 0] xValue]];
    [self setWidthForTimeFlagWithValue: 0];
    self.startDate = startDate;
}

//=============================================================================

- (CGFloat) stepWidth
{
    NSInteger days = [self.totalDataSet daysInSet];
    return (_fullWidth / days) * kDaysInStep;
}

- (NSInteger) stepsTotal
{
    return (_fullWidth / [self stepWidth]);
}

//=============================================================================

#pragma mark - ChartView Delegate -

//=============================================================================

- (void)    chartView: (GMChartView *) chartView
    widthValueChanged: (CGFloat) widthValue
andHeightValueChanged: (CGFloat) heightValue
{
    [self setInitialWidth: widthValue
                andHeight: heightValue];
}

//=============================================================================

- (void) setInitialWidth: (CGFloat) width
               andHeight: (CGFloat) height
{
    _fullWidth = width;
    [self.timeFlagView setFrame: CGRectMake(self.chartView.chartPadding, self.chartView.chartTopPadding, width, height)];
    [self.innerFlagView setFrame: CGRectMake(width - kFlagRange, 0, kFlagRange, kFlagRange)];
    [self.innerLineView setFrame: CGRectMake(width - kLineWidth, 0, kLineWidth, height)];
    [self setWidthForTimeFlagWithValue: width - [self stepWidth]];
    [self setMaxWidth];
    [self.imageCacheView setFrame: CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    if (self.delegate && [self.delegate respondsToSelector: @selector(chartMidget:startDateChanged:)])
    {
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate: [[self.totalDataSet dataPointAtIndex: 0] xValue]];
        self.startDate =  [startDate dateByAddingTimeInterval: ((width - [self stepWidth]) / [self stepWidth]) * SECS_PER_WEEK];
        [self.delegate chartMidget: self
                  startDateChanged: [self.startDate gm_startOfDay]];
    }
}

//=============================================================================

- (void) redrawView
{
    [self.chartView clearTilesCache];
    [self.chartView setNeedsDisplay];
}

//=============================================================================

@end
