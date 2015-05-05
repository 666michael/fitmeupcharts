//
//  GMChartViewProtocol.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 22.04.15.
//  Copyright (c) 2015 Anton Gubarenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GMChartView;

@protocol GMChartViewProtocol <NSObject>

@optional

- (void)    chartView: (GMChartView*) chartView
    widthValueChanged: (CGFloat) widthValue
andHeightValueChanged: (CGFloat) heightValue;
@end
