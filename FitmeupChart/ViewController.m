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
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd/ HH:mm"];
    
    NSDictionary *data1 = @{
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: -3 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @10,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: -2 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @15,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: -1 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @9,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: 0] timeIntervalSinceReferenceDate]]: @26,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: 1 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @28,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: 2 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @21,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: 3 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @4};
    GMDataSet *dataSet = [[GMDataSet alloc] initWithDictionary:data1];
    [dataSet setPlotColor:[UIColor gm_greenColor]];
    [dataSet setPlotName:@"proteins"];
    
    NSDictionary *data2 = @{
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: -3 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @25,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: -2 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @31,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: -1 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @20,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: 0] timeIntervalSinceReferenceDate]]: @45,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: 3 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @51,
                            [NSNumber numberWithInteger:[[NSDate dateWithTimeIntervalSinceNow: 5 * SECS_PER_DAY] timeIntervalSinceReferenceDate]]: @48};
    GMDataSet *dataSet1 = [[GMDataSet alloc] initWithDictionary:data2];
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
