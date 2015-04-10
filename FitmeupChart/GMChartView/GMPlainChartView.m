//
//  GMPlainChartView.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 10.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMPlainChartView.h"

//=============================================================================

@implementation GMPlainChartView

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self == nil)
        return nil;
    
    self.chartType = GMScatterChart;
    
    return self;
}

//=============================================================================

@end
