//
//  GMPlainChartViewController.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 13.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMPlainChartViewController.h"
#import "GMPlainChartView.h"
#import "GMChartMidget.h"

//=============================================================================

@interface GMPlainChartViewController ()

@property (weak, nonatomic) IBOutlet GMPlainChartView *plainChart;
@property (weak, nonatomic) IBOutlet GMChartMidget *midgetChart;

@end

//=============================================================================

@implementation GMPlainChartViewController

//=============================================================================

#pragma mark - View LyfeCycle -

//=============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.midgetChart.chartView setChartTopPadding: 0.0f];
    [self.midgetChart.chartView setChartBottomPadding: 0.0f];
}

//=============================================================================

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//=============================================================================

#pragma mark - View Rotation -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

//=============================================================================

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.chartView setNeedsDisplay];
}

//=============================================================================
@end
