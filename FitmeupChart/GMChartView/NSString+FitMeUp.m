//
//  NSString+FitMeUp.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 13.03.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import <UIKit/UIKit.h>

//=============================================================================

@implementation NSString (Chart)

//=============================================================================

- (CGFloat) gm_heightForFont: (UIFont*) font
{
    CGSize maximumSize = CGSizeMake(300, 9999);
    return [self boundingRectWithSize:maximumSize
                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                           attributes:@{
                                        NSFontAttributeName : font}
                              context:nil].size.height;
}

//=============================================================================

- (CGFloat) gm_widthForFont: (UIFont*) font
{
    CGSize maximumSize = CGSizeMake(300, 9999);
    return [self boundingRectWithSize:maximumSize
                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                           attributes:@{
                                        NSFontAttributeName : font}
                              context:nil].size.width;
}

//=============================================================================

@end
