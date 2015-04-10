//
//  GMBarChartView.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 10.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMBarChartView.h"

//=============================================================================

@implementation GMBarChartView

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self == nil)
        return nil;
    
    self.chartType = GMBarChart;
    
    return self;
}

//=============================================================================

@end
