//
//  ViewController.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 Anton Gubarenko. All rights reserved.
//

#import "ViewController.h"
#import "GMChartView.h"
#import "GMChartFactory.h"
#import "UIColor+FitMeUp.h"
#define SECS_PER_DAY (86400)

@interface ViewController ()
@property (strong, nonatomic) IBOutlet GMChartView *chartView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initChart];
}

- (void)initChart
{
    self.chartView = [GMChartFactory plainChartWithFrame: CGRectMake(20, 20, CGRectGetWidth(self.view.frame)-40, CGRectGetHeight(self.view.frame)-40)];
    
    GMDataSet *dataSet = [GMDataSet new];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd/ HH:mm"];
    
    GMDatePoint *pt1 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-3 * SECS_PER_DAY] yValue:5000];
    [pt1 setShouldShowLabel:YES];
    [pt1 setPointLabelText:@"10"];
    [pt1 setPointStyle:GMPointLowerStyle];
    GMDatePoint *pt4 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:0] yValue:26];
    [pt4 setShouldShowLabel:YES];
    [pt4 setPointLabelText:@"26"];
    [pt4 setPointStyle:GMPointLowerStyle];
    GMDatePoint *pt5 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:1 * SECS_PER_DAY] yValue:1];
    [pt5 setShouldShowLabel:YES];
    [pt5 setPointLabelText:@"28"];
    [pt5 setPointStyle:GMPointUpperStyle];
    GMDatePoint *pt7 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:3 * SECS_PER_DAY] yValue:2];
    GMDatePoint *pt8 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:4 * SECS_PER_DAY] yValue:1];
    [pt8 setShouldShowLabel:YES];
    [pt8 setPointLabelText:@"15"];
    [pt8 setPointStyle:GMPointUpperStyle];
    [dataSet addDataPoint:pt1];
    [dataSet addDataPoint:pt4];
    [dataSet addDataPoint:pt5];
    [dataSet addDataPoint:pt7];
    [dataSet addDataPoint:pt8];
    [dataSet setPlotColor:[UIColor gm_greenColor]];
    [dataSet setPlotName:@"proteins"];
    
    GMDataSet *dataSet1 = [[GMDataSet alloc] init];
    
    GMDatePoint *pt12 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-3 * SECS_PER_DAY]  yValue:66.5];
    GMDatePoint *pt13 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-2 * SECS_PER_DAY]  yValue:65.9];
    GMDatePoint *pt14 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:-1  *SECS_PER_DAY]  yValue:66.1];
    GMDatePoint *pt15 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:0]  yValue:64.9];
    GMDataPoint *pt16 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:1 * SECS_PER_DAY]  yValue:64.8];
    GMDataPoint *pt17 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:2  *SECS_PER_DAY]  yValue:65.1];
    GMDataPoint *pt18 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:3 * SECS_PER_DAY]  yValue:64.0];
    GMDataPoint *pt19 = [[GMDatePoint alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:4 * SECS_PER_DAY]  yValue:65.5];
    
    //[dataSet1 addDataPoint:pt11];
    [dataSet1 addDataPoint:pt12];
    [dataSet1 addDataPoint:pt13];
    [dataSet1 addDataPoint:pt14];
    [dataSet1 addDataPoint:pt15];
    [dataSet1 addDataPoint:pt16];
    [dataSet1 addDataPoint:pt17];
    [dataSet1 addDataPoint:pt18];
    [dataSet1 addDataPoint:pt19];
    
    [dataSet1 setPlotColor:[UIColor gm_redColor]];
    [dataSet1 setPlotName:@"calories"];
    
    [dataSet1 setPlotColor:[UIColor gm_redColor]];
    [dataSet1 setPlotName:@"calories"];
    
    self.chartView.xAxisLabel.text = @"";
    self.chartView.yAxisLabel.text = @"our recommendations";
    [self.chartView setGridSize: GMGridSize18];
    
    [self.chartView setDataSetsWithArray:@[dataSet1]];
    [self.view addSubview:self.chartView];
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
