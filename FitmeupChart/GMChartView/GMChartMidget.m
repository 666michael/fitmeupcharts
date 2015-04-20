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

@implementation GMChartMidget

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
    self.chartView = [[GMPlainChartView alloc] initWithFrame: self.bounds];
    
    
    [self.chartView.xAxisLabel setText: @""];
    [self.chartView.yAxisLabel setText: @""];
    
    [self.chartView setShowGrid: YES];
    
    [self.chartView setShouldPlotLabels: NO];
    [self.chartView setShouldUseBezier: YES];
    
    [self.chartView setChartTopPadding: 20.0f];
    [self.chartView setChartBottomPadding: 0.0f];
    
    [self.chartView setGridSize: GMGridSize16];
    
    [self.chartView setXAxisColor: [UIColor whiteColor]];
    [self.chartView setYAxisColor: [UIColor gm_greenColor]];
    [self.chartView setShouldDrawCirclesOnAxis: YES];
    self.totalDataSet = [[GMDataSet alloc] init];
    
    //TEST
    for (NSInteger ind = 0; ind < 30; ind++)
    {
        GMDatePoint *pt = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:ind * SECS_PER_DAY]  yValue:66.5 + arc4random()%4];
        [self.totalDataSet addDataPoint:pt];
    }
    [self.totalDataSet setPlotColor: [UIColor gm_greenColor]];
    [self.chartView setDataSetsWithArray: @[self.totalDataSet]];
    [self addSubview: self.chartView];
    
    [self setupTimeFlag];
}

//=============================================================================

- (void) setupTimeFlag
{
    self.timeFlagView = [[UIView alloc] initWithFrame: CGRectMake(self.chartView.chartPadding, self.chartView.chartTopPadding, [self.chartView width], [self.chartView height])];
    [self.timeFlagView setBackgroundColor: [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [self addSubview: self.timeFlagView];
    
    UIView *flagView = [[UIView alloc] initWithFrame: CGRectMake([self.chartView width] - flagRange, 0, flagRange, flagRange)];
    [flagView setBackgroundColor: [UIColor whiteColor]];
    [flagView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin )];
    [flagView setTranslatesAutoresizingMaskIntoConstraints: YES];
    
    UIView *lineView = [[UIView alloc] initWithFrame: CGRectMake([self.chartView width] - lineWidth, 0, lineWidth, flagRange/5)];
    [lineView setBackgroundColor: [UIColor whiteColor]];
    [lineView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin )];
    [lineView setTranslatesAutoresizingMaskIntoConstraints: YES];
    
    [self.timeFlagView addSubview: flagView];
    [self.timeFlagView addSubview: lineView];
    
    [self.chartView setFrameSize: ^(CGFloat width, CGFloat height) {
        [self.timeFlagView setFrame: CGRectMake(self.chartView.chartPadding, self.chartView.chartTopPadding, width, height)];
        [[[self.timeFlagView subviews] firstObject] setFrame: CGRectMake(width - flagRange, 0, flagRange, flagRange)];
        [[[self.timeFlagView subviews] lastObject] setFrame: CGRectMake(width - lineWidth, 0, lineWidth, height)];
        [self setWidthForTimeFlagWithValue: width - [self stepWidth]];
        [self setMaxWidth];
    }];
}

//=============================================================================

- (void) setMaxWidth
{
    _maxWidth = CGRectGetWidth(self.timeFlagView.frame);
}

//=============================================================================

#pragma mark - Resize -

//=============================================================================

- (void)touchesBegan: (NSSet*) touches
           withEvent: (UIEvent*) event
{
    _isResizing = NO;
    
    UITouch *touch = [touches anyObject];
    
    if([self touchIsInRange: touch])
    {
        _touchStart = [touch locationInView:self];
        _widthStart = CGRectGetWidth(self.timeFlagView.frame);
        _isResizing = YES;
        NSLog(@"start x: %0.0f y: %0.0f", _touchStart.x, _touchStart.y);
    }
}

//=============================================================================

- (BOOL) touchIsInRange: (UITouch*) touch
{
    return fabs([touch locationInView:self].x - CGRectGetMaxX(self.timeFlagView.frame))< flagRange;
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

- (void) setWidthForTimeFlagWithValue: (CGFloat) width
{
    [self.timeFlagView setFrame: CGRectMake(self.chartView.chartPadding, self.chartView.chartTopPadding, width, CGRectGetHeight(self.timeFlagView.frame))];
    [[[self.timeFlagView subviews] firstObject] setFrame: CGRectMake(width - flagRange, 0, flagRange, flagRange)];
    [[[self.timeFlagView subviews] lastObject] setFrame: CGRectMake(width - lineWidth, 0, lineWidth, CGRectGetHeight(self.timeFlagView.frame))];
}

//=============================================================================

- (BOOL) touchIsInChart: (UITouch*) touch
{
    CGFloat xCoord = [touch locationInView:self].x;
    return  self.chartView.chartPadding <= xCoord && xCoord <= self.chartView.chartPadding + _maxWidth;
}

//=============================================================================

- (void)touchesEnded: (NSSet*) touches
           withEvent: (UIEvent*) event
{
    if (_isResizing)
    {
        UITouch *touch = [touches anyObject];
        if ([self touchIsInChart: touch])
        {
            CGFloat countOfSteps = [touch locationInView: self].x / [self stepWidth];
            
            [self setWidthForTimeFlagWithValue: countOfSteps * [self stepWidth]];
            _isResizing = NO;
        }
    }
}

//=============================================================================

- (CGFloat) stepWidth
{
    NSInteger days = [self.totalDataSet count];
    return (CGRectGetWidth(self.timeFlagView.frame) / days) * daysInStep;
}


@end
