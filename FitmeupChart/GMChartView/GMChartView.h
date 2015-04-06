//
//  GMChartView.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GMDataSet.h"
#import "GMDataPoint.h"
#import "GMDatePoint.h"

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
    CGFloat _leftPadding;
    
    NSMutableArray* _labelsGrid;
}

@property (nonatomic, strong) UIColor* yAxisColor;
@property (nonatomic, strong) UIColor* xAxisColor;

@property (nonatomic, strong) UILabel* yAxisLabel;
@property (nonatomic, strong) UILabel* xAxisLabel;
@property (nonatomic) BOOL showGrid;
@property (nonatomic) BOOL showYValues;
@property (nonatomic) BOOL shouldUseBezier;

- (void) plotChart;
- (void) setDataSetsWithArray: (NSArray*) dataSets;
- (void) plotChartData;

@end
