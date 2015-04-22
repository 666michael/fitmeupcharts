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

//=============================================================================

const CGFloat flagRange = 20;
const CGFloat daysInStep = 7;
const CGFloat lineWidth = 2;

//=============================================================================

@interface GMChartMidget()
@property (nonatomic) CGPoint touchStart;
@property (nonatomic) CGFloat widthStart;
@property (nonatomic) BOOL isResizing;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat fullWidth;
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

    [self.chartView.xAxisLabel setText: @""];
    [self.chartView.yAxisLabel setText: @""];
    
    [self.chartView setShowGrid: NO];
    
    [self.chartView setShouldPlotLabels: NO];
    [self.chartView setShouldUseBezier: YES];
    
    [self.chartView setChartTopPadding: 20.0f];
    [self.chartView setChartBottomPadding: 0.0f];
    
    [self.chartView setGridSize: GMGridSize16];
    
    [self.chartView setXAxisColor: [UIColor gm_greenColor]];
    [self.chartView setYAxisColor: [UIColor whiteColor]];
    [self.chartView setShouldDrawCirclesOnAxis: YES];
    self.totalDataSet = [GMDataSet new];
    
    //TEST
    for (NSInteger ind = 7; ind <= 14; ind++)
    {
        GMDatePoint *pt = [[GMDatePoint alloc] initWithDate: [[NSDate dateWithTimeIntervalSinceNow: ind * SECS_PER_DAY] gm_startOfDay]
                                                     yValue: 76.5 + arc4random() % 4];
        [self.totalDataSet addDataPoint: pt];
    }
    
    for (NSInteger ind = -7; ind <= 0; ind++)
    {
        GMDatePoint *pt = [[GMDatePoint alloc] initWithDate: [[NSDate dateWithTimeIntervalSinceNow: ind * SECS_PER_DAY] gm_startOfDay]
                                                     yValue: 66.5 + arc4random() % 4];
        [self.totalDataSet addDataPoint: pt];
    }
    
    for (NSInteger ind = -21; ind <= -14; ind++)
    {
        GMDatePoint *pt = [[GMDatePoint alloc] initWithDate: [[NSDate dateWithTimeIntervalSinceNow: ind * SECS_PER_DAY] gm_startOfDay]
                                                     yValue: 70.5 + arc4random() % 4];
        [self.totalDataSet addDataPoint: pt];
    }
    [self.totalDataSet sortPoints];
    [self.totalDataSet setPlotColor: [UIColor gm_greenColor]];
    [self.chartView setDataSetsWithArray: @[self.totalDataSet]];
    [self addSubview: self.chartView];
    
    [self setupTimeFlag];
}

//=============================================================================

- (void) setupTimeFlag
{
    self.timeFlagView = [[UIView alloc] initWithFrame: CGRectMake(self.chartView.chartPadding, self.chartView.chartTopPadding, [self.chartView width], [self.chartView height])];
    [self.timeFlagView setBackgroundColor: [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.3]];
    [self addSubview: self.timeFlagView];
    
    UIView *flagView = [[UIView alloc] initWithFrame: CGRectMake([self.chartView width] - flagRange, 0, flagRange, flagRange)];
    [flagView setBackgroundColor: [UIColor whiteColor]];
    [flagView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin )];
    [flagView setTranslatesAutoresizingMaskIntoConstraints: YES];
    
    UIView *lineView = [[UIView alloc] initWithFrame: CGRectMake([self.chartView width] - lineWidth, 0, lineWidth, flagRange/5)];
    [lineView setBackgroundColor: [UIColor whiteColor]];
    [lineView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin )];
    [lineView setTranslatesAutoresizingMaskIntoConstraints: YES];
    
    flagView.layer.mask = [self triangleMask];
    [self.timeFlagView addSubview: flagView];
    [self.timeFlagView addSubview: lineView];
    
    [self.chartView setFrameSize: ^(CGFloat width, CGFloat height){
        _fullWidth = width;
        [self.timeFlagView setFrame: CGRectMake(self.chartView.chartPadding, self.chartView.chartTopPadding, width, height)];
        [[[self.timeFlagView subviews] firstObject] setFrame: CGRectMake(width - flagRange, 0, flagRange, flagRange)];
        [[[self.timeFlagView subviews] lastObject] setFrame: CGRectMake(width - lineWidth, 0, lineWidth, height)];
        [self setWidthForTimeFlagWithValue: width - [self stepWidth]];
        [self setMaxWidth];
    }];
}

//=============================================================================

- (CAShapeLayer *) triangleMask
{
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint: CGPointMake(0, 0)];
    [trianglePath addLineToPoint: CGPointMake(flagRange,0)];
    [trianglePath addLineToPoint: CGPointMake(flagRange, flagRange)];
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
        _touchStart = [touch locationInView: self];
        _widthStart = CGRectGetWidth(self.timeFlagView.frame);
        _isResizing = YES;
    }
}

//=============================================================================

- (BOOL) touchIsInRange: (UITouch *) touch
{
    return fabs([touch locationInView: self].x - CGRectGetMaxX(self.timeFlagView.frame)) < flagRange;
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
    [[[self.timeFlagView subviews] firstObject] setFrame: CGRectMake(width - flagRange, 0, flagRange, flagRange)];
    [[[self.timeFlagView subviews] lastObject] setFrame: CGRectMake(width - lineWidth, 0, lineWidth, CGRectGetHeight(self.timeFlagView.frame))];
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
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate: [[self.totalDataSet dataPointAtIndex: 0] xValue]];
       
        if([touch locationInView: self].x >=  self.chartView.chartPadding + _maxWidth)
        {
            [self setWidthForTimeFlagWithValue: _maxWidth];
             self.startDate =  [startDate dateByAddingTimeInterval: (_maxWidth / [self stepWidth]) * SECS_PER_WEEK];
        }
        else
            if([touch locationInView: self].x <=  self.chartView.chartPadding)
            {
                [self setWidthForTimeFlagWithValue: 0];
                self.startDate = startDate;
            } else
            {
                CGFloat countOfSteps = floorf([touch locationInView: self].x / [self stepWidth]);
                
                [self setWidthForTimeFlagWithValue: countOfSteps * [self stepWidth]];
                self.startDate =  [startDate dateByAddingTimeInterval: countOfSteps * SECS_PER_WEEK];
            }
        _isResizing = NO;
    }
}

//=============================================================================

- (CGFloat) stepWidth
{
    NSInteger days = [self.totalDataSet daysInSet];
    return (_fullWidth / days) * daysInStep;
}

//=============================================================================

@end
