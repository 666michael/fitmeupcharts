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

//=============================================================================

@interface GMChartMidget ()



@end

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
    
    [self.chartView setShowGrid: NO];

    [self.chartView setShouldPlotLabels: NO];
    [self.chartView setShouldUseBezier: YES];
    
    [self.chartView setChartTopPadding: 20.0f];
    [self.chartView setChartBottomPadding: 0.0f];

    [self.chartView setGridSize: GMGridSize16];
    
    [self.chartView setXAxisColor: [UIColor lightGrayColor]];
    [self.chartView setYAxisColor: [UIColor lightGrayColor]];
    [self.chartView setShouldDrawCirclesOnAxis: YES];
    GMDataSet *dataSet1 = [[GMDataSet alloc] init];
    
    //TEST
    for (NSInteger ind = 0; ind < 30; ind++)
    {
        GMDatePoint *pt = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:ind * SECS_PER_DAY]  yValue:66.5 + arc4random()%4];
        [dataSet1 addDataPoint:pt];
    }
    [dataSet1 setPlotColor: [UIColor lightGrayColor]];
    [self.chartView setDataSetsWithArray: @[dataSet1]];
    [self addSubview: self.chartView];
}

//=============================================================================

@end
