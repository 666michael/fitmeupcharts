//
//  GMDataPoint.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 12.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, GMPointStyle)
{
    GMPointStyleъ = 0,
    GMPointLowerStyle = 1
};

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
