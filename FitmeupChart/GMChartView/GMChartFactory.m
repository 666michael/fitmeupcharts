//
//  GMChartFactory.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMChartFactory.h"
#import "GMPlainChartView.h"
#import "GMBarChartView.h"

//=============================================================================

@implementation GMChartFactory

//=============================================================================

#pragma mark - Methods -

//=============================================================================

+ (GMChartView*) plainChartWithFrame: (CGRect) frame
{
    return [[GMPlainChartView alloc] initWithFrame:frame];
}

//=============================================================================

+ (GMChartView*) barChartWithFrame: (CGRect) frame
{
    return [[GMBarChartView alloc] initWithFrame:frame];
}

//=============================================================================

@end
