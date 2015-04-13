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
    [self addSubview: self.chartView];
    
    [self.chartView setShowGrid: NO];
    [self.chartView setShowYValues: YES];
    
    [self.chartView setXAxisColor: [UIColor greenColor]];
    [self.chartView setYAxisColor: [UIColor lightGrayColor]];
}

//=============================================================================

@end
