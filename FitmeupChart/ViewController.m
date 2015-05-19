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
    [self.view setBackgroundColor: [UIColor gm_backgroundColor]];
}

- (void)initChart
{
    if (!self.chartView)
    {
        self.chartView = [GMChartFactory plainChartWithFrame: CGRectMake(0, 50.0f, CGRectGetWidth(self.view.frame), 214.0f)];
        [self.view addSubview: self.chartView];
    }
    
    [self.chartView setChartInterpolation: GMChartInterpolationHermite];
    [self.chartView.xAxisLabel setText: @""];
    [self.chartView.yAxisLabel setText: @""];
    
    [self.chartView setChartTopPadding: 20.0f];
    [self.chartView setChartBottomPadding: 0.0f];
    
    [self.chartView setXAxisColor: [UIColor gm_greenColor]];
    [self.chartView setYAxisColor: [UIColor gm_greenColor]];
    [self.chartView setIsStepUsed: YES];
    [self.chartView setGridSize: GMGridSize18];
    [self.chartView setShouldDrawCirclesOnAxis: NO];
    [self.chartView setBackgroundColor: [UIColor gm_backgroundColor]];
    
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
    NSLog(@"start grouping");
    [self.currentDateLabel setText: [NSString stringWithFormat: @"%@", date]];
    [self.chartView setDataSetsWithArray: @[[[GMCoreDataHelper testDataSetWithStartDate: date] sortedGroupsWithAverageType: GMDataAverageArithmetic]]];
}

@end
