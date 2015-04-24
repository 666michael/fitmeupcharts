//
//  GMDataSetProtocol.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 24.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMDataSet;

@protocol GMDataSetProtocol <NSObject>

@optional

- (CGFloat) xCoordForValue: (CGFloat) xValue
             forDataSet: (GMDataSet*) dataSet;
- (CGFloat) yCoordForValue: (CGFloat) yValue
             forDataSet: (GMDataSet*) dataSet;

@end
