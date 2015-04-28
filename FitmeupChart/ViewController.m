//
//  ViewController.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 Anton Gubarenko. All rights reserved.
//

#import "ViewController.h"
#import "GMChartMidget.h"
#import "GMChartFactory.h"
#import "UIColor+FitMeUp.h"
#import "GMCoreDataHelper.h"

@interface ViewController () <GMChartMidgetProtocol>

@property (strong, nonatomic) IBOutlet GMChartView *chartView;
@property (strong, nonatomic) IBOutlet GMChartMidget *chartMidget;
@property (weak, nonatomic) IBOutlet UILabel *currentDateLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initChart];
}

- (void)initChart
{
    GMDataSet *dataSet1 = [[GMDataSet alloc] init];
    
    GMDatePoint *pt12 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-3 * SECS_PER_DAY]  yValue:66.5];
    GMDatePoint *pt13 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-2 * SECS_PER_DAY]  yValue:65.9];
    GMDatePoint *pt14 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-1  *SECS_PER_DAY]  yValue:66.1];
    GMDatePoint *pt15 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:0]  yValue:64.9];
    GMDataPoint *pt16 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:1 * SECS_PER_DAY]  yValue:64.8];
    GMDataPoint *pt17 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:2  *SECS_PER_DAY]  yValue:65.1];
    GMDataPoint *pt18 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:3 * SECS_PER_DAY]  yValue:64.0];
    
    //[dataSet1 addDataPoint:pt11];
    [dataSet1 addDataPoint:pt12];
    [dataSet1 addDataPoint:pt13];
    [dataSet1 addDataPoint:pt14];
    [dataSet1 addDataPoint:pt15];
    [dataSet1 addDataPoint:pt16];
    [dataSet1 addDataPoint:pt17];
    [dataSet1 addDataPoint:pt18];
    //[dataSet1 addDataPoint:pt19];
    [dataSet1 setPlotColor: [UIColor gm_greenColor]];
    
    [self.chartView setChartInterpolation: GMChartInterpolationHermite];
    [self.chartView.xAxisLabel setText: @""];
    [self.chartView.yAxisLabel setText: @""];
    
    [self.chartView setChartTopPadding: 20.0f];
    [self.chartView setChartBottomPadding: 0.0f];
    
    [self.chartView setGridSize: GMGridSize16];
    
    [self.chartView setXAxisColor: [UIColor gm_greenColor]];
    [self.chartView setYAxisColor: [UIColor gm_greenColor]];
    [self.chartView setShouldDrawCirclesOnAxis: YES];
    [self.chartView setIsStepUsed: YES];
    [self.chartView setGridSize: GMGridSize18];
    [self.chartView setShouldDrawCirclesOnAxis: NO];
    [self.chartView setDataSetsWithArray: @[dataSet1]];
    
    [self.chartMidget setDelegate: self];
}

- (IBAction)changeFrameAction:(id)sender
{
    //[self.chartView setFrame: CGRectMake(0, 94, 320 - arc4random() % 50, 279)];
}

- (IBAction)changeWithRedrawAction:(id)sender
{
    //[self.chartView setFrame: CGRectMake(0, 94, 320 - arc4random() % 50, 279)];
    //[self.chartView redrawView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

#pragma mark - GMChartMidget Protocol -

- (void) chartMidget: (GMChartMidget*) midget
    startDateChanged: (NSDate*) date
{
    [self.currentDateLabel setText: [NSString stringWithFormat: @"%@", date]];
    [self.chartView setDataSetsWithArray: @[[GMCoreDataHelper testDataSetWithStartDate: date]]];
}

@end
