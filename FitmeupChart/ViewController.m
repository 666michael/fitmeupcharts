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

@interface ViewController ()
@property (strong, nonatomic) IBOutlet GMChartMidget *chartView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initChart];
}

- (void)initChart
{
}

- (IBAction)changeFrameAction:(id)sender
{
    [self.chartView setFrame: CGRectMake(0, 94, 320 - arc4random() % 50, 279)];
}

- (IBAction)changeWithRedrawAction:(id)sender
{
    [self.chartView setFrame: CGRectMake(0, 94, 320 - arc4random() % 50, 279)];
    [self.chartView redrawView];
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
