//
//  ViewController.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 Anton Gubarenko. All rights reserved.
//

#import "ViewController.h"
#import "GMChartView.h"
#import "UIColor+FitMeUp.h"
#define SECS_PER_DAY (86400)

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GMChartView *chartView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initChart];
}

- (void)initChart
{
    GMDataSet *dataSet = [GMDataSet new];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd/ HH:mm"];
    
    GMDatePoint *pt1 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-3 * SECS_PER_DAY]  yValue:10];
    [pt1 setShouldShowLabel:YES];
    [pt1 setPointLabelText:@"10"];
    [pt1 setPointStyle:GMPointLowerStyle];
    GMDatePoint *pt2 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-2 * SECS_PER_DAY]  yValue:15];
    GMDatePoint *pt3 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-1 * SECS_PER_DAY]  yValue:9];
    GMDatePoint *pt4 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:0]  yValue:26];
    GMDatePoint *pt5 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:1 * SECS_PER_DAY]  yValue:28];
    [pt5 setShouldShowLabel:YES];
    [pt5 setPointLabelText:@"28"];
    [pt5 setPointStyle:GMPointUpperStyle];
    GMDatePoint *pt6 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:2 * SECS_PER_DAY]  yValue:21];
    GMDatePoint *pt7 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:3 * SECS_PER_DAY]  yValue:4];
    [pt7 setShouldShowLabel:YES];
    [pt7 setPointLabelText:@"4"];
    [pt7 setPointStyle:GMPointUpperStyle];
    
    [dataSet addDataPoint:pt1];
    [dataSet addDataPoint:pt2];
    [dataSet addDataPoint:pt3];
    [dataSet addDataPoint:pt4];
    [dataSet addDataPoint:pt5];
    [dataSet addDataPoint:pt6];
    [dataSet addDataPoint:pt7];
    [dataSet setPlotColor:[UIColor gm_greenColor]];
    [dataSet setPlotName:@"proteins"];
    
    GMDataSet *dataSet1 = [[GMDataSet alloc] init];
    GMDatePoint *pt11 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-5 * SECS_PER_DAY]  yValue:18];
    [pt11 setShouldShowLabel:YES];
    [pt11 setPointLabelText:@"18"];
    [pt11 setPointStyle:GMPointLowerStyle];
    GMDatePoint *pt12 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-3 * SECS_PER_DAY]  yValue:25];
    GMDatePoint *pt13 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-2 * SECS_PER_DAY]  yValue:31];
    GMDatePoint *pt14 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-1 * SECS_PER_DAY]  yValue:20];
    GMDatePoint *pt15 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:0]  yValue:45];
    GMDataPoint *pt16 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:3 * SECS_PER_DAY]  yValue:51];
    GMDatePoint *pt17 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:5 * SECS_PER_DAY]  yValue:48];
    [pt17 setShouldShowLabel:YES];
    [pt17 setPointLabelText:@"48"];
    [pt17 setPointStyle:GMPointUpperStyle];
    
    [dataSet1 addDataPoint:pt11];
    [dataSet1 addDataPoint:pt12];
    [dataSet1 addDataPoint:pt13];
    [dataSet1 addDataPoint:pt14];
    [dataSet1 addDataPoint:pt15];
    [dataSet1 addDataPoint:pt16];
    [dataSet1 addDataPoint:pt17];
    
    [dataSet1 setPlotColor:[UIColor gm_redColor]];
    [dataSet1 setPlotName:@"calories"];
    
    self.chartView.xAxisLabel.text = @"";
    self.chartView.yAxisLabel.text = @"weight";
    
    [self.chartView setDataSetsWithArray:@[dataSet, dataSet1]];
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
    //[self.chartView setNeedsDisplay];
}

@end
