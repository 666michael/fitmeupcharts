//
//  GMChartFactory.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMChartFactory.h"
#import "GMChartView.h"

//=============================================================================

@implementation GMChartFactory

//=============================================================================

#pragma mark - Methods -

//=============================================================================

+ (GMChartView*) plainChartWithFrame: (CGRect) frame
{
    GMChartView *chartView = [[GMChartView alloc] initWithFrame:frame];
    [chartView setShowYValues: YES];
    [chartView setShouldUseBezier: NO];
    [chartView setChartType: GMScatterChart];
    [chartView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [chartView setTranslatesAutoresizingMaskIntoConstraints: YES];
    return chartView;
}

//=============================================================================

+ (GMChartView*) barChartWithFrame: (CGRect) frame
{
    GMChartView *chartView = [[GMChartView alloc] initWithFrame:frame];
    [chartView setShowYValues: YES];
    [chartView setShouldUseBezier: YES];
    [chartView setChartType: GMBarChart];
    [chartView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [chartView setTranslatesAutoresizingMaskIntoConstraints: YES];
    return chartView;
}

//=============================================================================

@end
