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
#import "NSString+FitMeUp.h"
#import "UIColor+FitMeUp.h"
#import "GMDataSet.h"
#import "NSDate+FitMeUp.h"
#import "GMChartUtils.h"

#define defaultFontSize  10.5f
#define defaultCircleRadius 2.5f
#define defaultLineWidth  2.0f

typedef NS_ENUM(NSUInteger, GMGridSize)
{
    GMGridSize16 = 0,
    GMGridSize18 = 1
};

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
@property (nonatomic) GMGridSize gridSize;
@property (nonatomic) BOOL shouldUseBezier;
@property (nonatomic) BOOL shouldPlotLabels;
@property (nonatomic) BOOL isStepUsed;
@property (nonatomic) BOOL shouldDrawCirclesOnAxis;
@property (nonatomic) CGFloat chartPadding;
@property (nonatomic) CGFloat chartTopPadding;
@property (nonatomic) CGFloat chartBottomPadding;
@property (nonatomic, copy) void (^frameSize)(CGFloat width, CGFloat height);

- (void) plotChart;
- (void) setDataSetsWithArray: (NSArray*) dataSets;
- (void) plotChartData;
- (void) calcScale;
- (void) plotDataSet: (GMDataSet*) dataSet
          withContet: (CGContextRef) context;

- (CGFloat) xCoordinatesForValue: (CGFloat) xValue;
- (CGFloat) yCoordinatesForValue: (CGFloat) xValue;
- (void) highlightCellInGridAtRow: (NSInteger) row
                        andColumn: (NSInteger) column
                        withIndex: (GMPlotDirection) direction;

- (void) drawRounedRectWithRect: (CGRect) rect
                   cornerRaduis: (CGFloat) cornerRadius
                          color: (UIColor*) legendColor
                     forContext: (CGContextRef) context;

- (void) drawCircleAtXCoordinate: (CGFloat) x
                     yCoordinate: (CGFloat) y
                       fillColor: (UIColor*) color
                      andContext: (CGContextRef) context;
- (void) drawCirclesOnAxisWithContext: (CGContextRef) context;
- (CGFloat) height;
- (CGFloat) width;
@end
