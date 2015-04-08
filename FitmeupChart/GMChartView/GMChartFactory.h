//
//  GMChartFactory.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GMChartView;

@interface GMChartFactory : NSObject

+ (GMChartView*) plainChartWithFrame: (CGRect) frame;
+ (GMChartView*) barChartWithFrame: (CGRect) frame;

@end
