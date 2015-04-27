//
//  GMChartMidget.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 13.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMPlainChartView.h"
#import "GMChartMidgetProtocol.h"

typedef NS_ENUM(NSUInteger, GMChartLastDateType)
{
    GMChartLastDateTypeNone = 0,
    GMChartLastDateTypeCurrentDateWithLastValue,
    GMChartLastDateTypeCurrentDateWithZeroValue
};

@interface GMChartMidget : UIView

@property (nonatomic) GMDataSet *totalDataSet;
@property (nonatomic) NSDate *startDate;
@property (nonatomic, weak) NSObject<GMChartMidgetProtocol> *delegate;
@property (nonatomic) GMChartLastDateType lastDateType;

- (void) redrawView;

@end
