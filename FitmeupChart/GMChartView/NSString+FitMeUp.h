//
//  NSString+FitMeUp.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 13.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (FitMeUp)

- (CGFloat) gm_heightForFont: (UIFont*) font;
- (CGFloat) gm_widthForFont: (UIFont*) font;

@end
