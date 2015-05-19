//
//  GMShadowLayer.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 19.05.15.
//  Copyright (c) 2015 Anton Gubarenko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface GMShadowLayer : CAShapeLayer

@property (nonatomic, strong) UIBezierPath *midgetPath;
@property (nonatomic) CGRect clipRect;

@end
