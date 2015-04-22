//
//  GMChartMidget.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 13.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMPlainChartView.h"

@interface GMChartMidget : UIView

@property (nonatomic) GMDataSet *totalDataSet;
@property (nonatomic) UIView *timeFlagView;
@property (nonatomic) GMPlainChartView *chartView;
@property (nonatomic) NSDate *startDate;

@end
