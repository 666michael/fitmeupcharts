//
//  GMDataPoint.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    GMPointUpperStyle = 0,
    GMPointLowerStyle = 1
}GMPointStyle;

@interface GMDataPoint : NSObject

@property (nonatomic) CGFloat xValue;
@property (nonatomic) CGFloat yValue;
@property (nonatomic, copy) NSString* pointLabelText;
@property (nonatomic) GMPointStyle pointStyle;
@property (nonatomic, strong) UIColor* pointColor;
@property (nonatomic) BOOL shouldShowLabel;

- (id) initWithXValue: (CGFloat) xValue
               yValue: (CGFloat) yValue;


@end
