//
//  GMChartMidgetProtocol.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 22.04.15.
//  Copyright (c) 2015 Anton Gubarenko. All rights reserved.
//

#ifndef FitmeupChart_GMChartMidgetProtocol_h
#define FitmeupChart_GMChartMidgetProtocol_h

#import <UIKit/UIKit.h>

@class GMChartMidget;

@protocol GMChartMidgetProtocol <NSObject>

@optional

- (void) chartMidget: (GMChartMidget*) midget
    startDateChanged: (NSDate*) date;

@end


#endif
