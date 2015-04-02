//
//  GMChartView.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GMDataSet.h"
#import "GMDataPoint.h"
#import "GMDatePoint.h"

typedef enum {
    Grid18x10 = 0,
    Grid16x10
}ChartGridType;

@interface GMChartView : UIView
{
    NSArray* _dataSets;
    CGFloat _plotWidth;
    CGFloat _plotHeight;
    NSInteger _xGridLines;
    NSInteger _yGridLines;
    CGColorRef _defaultGridLineColor;
    
    CGFloat _minX;
    CGFloat _minY;
    CGFloat _maxX;
    CGFloat _maxY;
    CGFloat _minGridSize;
}

@property (nonatomic, strong) UIColor* yAxisColor;
@property (nonatomic, strong) UIColor* xAxisColor;

@property (nonatomic, strong) UILabel* yAxisLabel;
@property (nonatomic, strong) UILabel* xAxisLabel;
@property (nonatomic) BOOL showGrid;
@property (nonatomic) BOOL showYValues;
@property (nonatomic) ChartGridType gridType;

- (void) plotChart;
- (void) setDataSetsWithArray: (NSArray*) dataSets;
- (void) plotChartData;

@end
