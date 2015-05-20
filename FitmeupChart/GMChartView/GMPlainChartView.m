//
//  GMPlainChartView.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 10.04.15.
//  Copyright (c) 2015 CleverBits. All rights reserved.
//

//=============================================================================

#import "GMPlainChartView.h"
#import "GMChartView.h"
#import "GMDataSetProtocol.h"

//=============================================================================

typedef NS_ENUM(NSUInteger, GMPointDirection)
{
    GMPointUpToUp = 0,
    GMPointUpToDown,
    GMPointDownToUp,
    GMPointDownToDown,
    GMPointNone
};

static const CGFloat kShadowRadius = 40.0f;

//=============================================================================

@implementation GMPlainChartView

//=============================================================================

#pragma mark - Init -

//=============================================================================

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self == nil)
    {
        return nil;
    }
    return self;
}

//=============================================================================

- (void) plotDataSet: (GMDataSet*) dataSet
         withContext: (CGContextRef) context
{
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: [[UIColor gm_greenColor] colorWithAlphaComponent: self.glowIntensity]];
    [shadow setShadowOffset: CGSizeMake(0, 0)];
    [shadow setShadowBlurRadius: kShadowRadius];
    
    if (!self.shouldUseBezier)
    {
        for (NSInteger index = 0; index < [dataSet count]; index++)
        {
            GMDataPoint *dataPoint = [dataSet dataPointAtIndex: index];
            CGFloat x = [self xCoordinatesForValue: dataPoint.xValue];
            CGFloat y = [self yCoordinatesForValue: dataPoint.yValue];
            
            if(index == 0)
            {
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, x, y);
            }
            else
            {
                CGContextAddLineToPoint(context, x, y);
            }
        }
        CGContextSetStrokeColorWithColor(context, dataSet.plotColor ? [dataSet.plotColor CGColor] : [UIColor whiteColor].CGColor);
        CGContextDrawPath(context, kCGPathStroke);
    }
    else
    {
        [dataSet setDataSource: self];
        UIBezierPath *path = nil;
        
        switch (self.chartInterpolation)
        {
            case GMChartInterpolationHermite:
            {
                path = [GMChartUtils gm_interpolateCGPointsWithHermiteForDataSet: [dataSet pointsArray]];
                break;
            }
            case GMChartInterpolationQuad:
            {
                path = [GMChartUtils gm_quadCurvedPathWithPoints: [dataSet pointsArray]];
                break;
            }
                break;
            default:
                break;
        }
        if(path)
        {            
            
            CGContextSetStrokeColorWithColor(context, dataSet.plotColor ? [dataSet.plotColor CGColor] : [UIColor whiteColor].CGColor);
            CGContextAddPath(context, [path CGPath]);
            CGContextDrawPath(context, kCGPathStroke);
            
            [path addLineToPoint: CGPointMake([[[dataSet pointsArray] lastObject] CGPointValue].x, self.chartTopPadding * 2 + [self height])];
            [path addLineToPoint: CGPointMake([[[dataSet pointsArray] firstObject] CGPointValue].x, self.chartTopPadding * 2 + [self height])];
            [path closePath];
            _glowPath = [path copy];
            
            CGContextSaveGState(context);
            UIRectClip(path.bounds);
            CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
            
            CGContextSetAlpha(context, CGColorGetAlpha([shadow.shadowColor CGColor]));
            CGContextBeginTransparencyLayer(context, NULL);
            {
                UIColor* opaqueShadow = [shadow.shadowColor colorWithAlphaComponent: 1];
                CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [opaqueShadow CGColor]);
                CGContextSetBlendMode(context, kCGBlendModeSourceOut);
                CGContextBeginTransparencyLayer(context, NULL);
                
                [opaqueShadow setFill];
                [path fill];
                
                CGContextEndTransparencyLayer(context);
            }
            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
            
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
}

//=============================================================================

- (UIColor*) colorForDataSet: (GMDataSet*) dataSet
                    withDate: (NSDate*) date
{
    return [UIColor gm_greenColor];
}

//=============================================================================

- (void) plotLabels
{
    if (!self.shouldPlotLabels)
    {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil)
    {
        return;
    }
    if (_dataSets.count==0)
    {
        return;
    }
    for (GMDataSet *dataSet in _dataSets)
    {
        [dataSet sortPoints];
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, GMChartViewDefaultLineWidth);
        
        for (NSInteger index = 0; index < [dataSet count]; index++)
        {
            GMDataPoint *dataPoint = [dataSet dataPointAtIndex: index];
            CGFloat x = [self xCoordinatesForValue: dataPoint.xValue];
            CGFloat y = [self yCoordinatesForValue: dataPoint.yValue];
            
            NSInteger row = ceilf((x - _leftPadding - self.chartPadding) / (_plotWidth / _xGridLines));
            NSInteger col = ceilf((y - self.chartTopPadding) / (_plotHeight / _yGridLines));
            
            if (row == _xGridLines)
                row--;
            
            if (dataPoint.shouldShowLabel)
            {
                
                UIColor* colorForText = dataPoint.pointStyle == GMPointStyleUpper ? [UIColor gm_redColor] : [UIColor gm_greenColor];
                [self drawCircleAtXCoordinate: x
                                  yCoordinate: y
                                    fillColor: colorForText
                                   andContext: context];
                if(col< _yGridLines && row < _xGridLines)
                {
                    [self drawText: dataPoint.pointLabelText
                       xCoordinate: x
                       yCoordinate: y
                         fillColor: colorForText
                        pointStyle: dataPoint.pointStyle
                         direction: [self directionOfPointAtIndex: index
                                                            inSet: dataSet]
                        andContext: context];
                }
                CGContextDrawPath(context, kCGPathFillStroke);
            }
        }
    }
}

//=============================================================================

- (void) drawText: (NSString*) text
      xCoordinate: (CGFloat) x
      yCoordinate: (CGFloat) y
        fillColor: (UIColor*) color
       pointStyle: (GMPointStyle) pointStyle
        direction: (GMPointDirection) direction
       andContext: (CGContextRef) context
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize],
                                 NSForegroundColorAttributeName : color};
    
    CGFloat textHeight = [text gm_heightForFont: [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize]];
    CGFloat textWidth = [text gm_widthForFont: [GMChartUtils gm_defaultBoldFontWithSize: GMChartViewDefaultFontSize]];
    
    CGFloat step = (_plotHeight / _yGridLines);
    CGFloat rawY = y - self.chartTopPadding;
    
    NSInteger col = (x - _leftPadding - self.chartPadding) / step;
    
    CGFloat colLeft = fmod(rawY, step);
    
    if (colLeft < step / 2.0)
    {
        y -= colLeft;
    }
    else
    {
        y += (step - colLeft);
    }
    
    if(direction == GMPointDownToUp || direction == GMPointUpToUp)
    {
        if (col == 0)
        {
            y += (step - colLeft);
        }
        else
        {
            if (col == _xGridLines)
            {
                x -= step;
                y -= step;
            }
            else
            {
                y = [self adjustedY: y
                        basedOnPath: direction
                           andSpace: colLeft];
                x = [self adjustedX: x
                        basedOnPath: direction];
            }
        }
    }
    else
    {
        if (col == 0)
        {
            x -= step;
            y -= step;
        }
        else
        {
            if (col == _xGridLines)
            {
                x -= textWidth;
                if (colLeft < 1.0)
                {
                    y += step;
                    y -= textHeight;
                }
                else
                {
                    y -= step;
                }
            }
            else
            {
                y = [self adjustedY: y
                        basedOnPath: direction
                           andSpace: colLeft];
                x = [self adjustedX: x
                        basedOnPath: direction];
            }
        }
        
    }
    //[self drawCircleAtXCoordinate:x yCoordinate:y fillColor:[UIColor blueColor] andContext:UIGraphicsGetCurrentContext()];
    [text drawAtPoint: CGPointMake(x, y)
       withAttributes: attributes];
}

//=============================================================================

- (GMPointDirection) directionOfPointAtIndex: (NSInteger) index
                                       inSet: (GMDataSet*) dataSet
{
    if ([dataSet count] < 3)
    {
        return GMPointNone;
    }
    NSInteger direction = GMPointNone;
    if (index==0)
    {
        CGFloat curPt = [[dataSet dataPointAtIndex: index] yValue];
        CGFloat rightPt = [[dataSet dataPointAtIndex: index + 1] yValue];
        if (curPt < rightPt)
        {
            direction = GMPointUpToUp;
        }
        else
        {
            direction = GMPointDownToDown;
        }
    }
    
    if (index == [dataSet count]-1)
    {
        CGFloat leftPt = [[dataSet dataPointAtIndex: index - 1] yValue];
        CGFloat curPt = [[dataSet dataPointAtIndex: index] yValue];
        if (leftPt < curPt)
        {
            direction = GMPointUpToUp;
        }
        else
        {
            direction = GMPointDownToDown;
        }
    }
    
    if (index != 0 && index != [dataSet count]-1 )
    {
        CGFloat leftPt = [[dataSet dataPointAtIndex: index - 1] yValue];
        CGFloat curPt = [[dataSet dataPointAtIndex: index] yValue];
        CGFloat rightPt = [[dataSet dataPointAtIndex: index + 1] yValue];
        
        if (leftPt < curPt && curPt < rightPt)
        {
            direction = GMPointUpToUp;
        }
        
        if (leftPt < curPt && curPt > rightPt)
        {
            direction = GMPointUpToDown;
        }
        
        if (leftPt > curPt && curPt < rightPt)
        {
            direction = GMPointDownToUp;
        }
        
        if (leftPt > curPt && curPt > rightPt)
        {
            direction = GMPointDownToDown;
        }
    }
    return direction;
}

//=============================================================================

- (CGFloat) adjustedY: (CGFloat) y
          basedOnPath: (GMPointDirection) path
             andSpace: (CGFloat) space
{
    CGFloat newY = y;
    CGFloat stepY = _plotHeight/_yGridLines;
    if (path == GMPointDownToDown)
    {
        newY = y - stepY;
    }
    
    if (path == GMPointUpToDown)
    {
        newY = y - (space>stepY/2.0 ? stepY : stepY);
    }
    
    if (path == GMPointDownToUp)
    {
        newY = y +  (space<stepY/2.0 ? stepY : 0);
    }
    
    if (path == GMPointNone)
    {
        newY = y + (space<stepY/2.0 ? stepY : stepY-space);
    }
    
    if (newY < self.chartTopPadding)
    {
        newY += stepY;
    }
    if (newY > (self.chartTopPadding + [self height]))
    {
        newY -= stepY * 2.0;
    }
    return newY;
}

//=============================================================================

- (CGFloat) adjustedX: (CGFloat) x
          basedOnPath: (GMPointDirection) path
{
    if (path == GMPointDownToDown)
    {
        return x + GMChartViewDefaultCircleRadius;
    }
    
    if (path == GMPointUpToUp)
    {
        return x + GMChartViewDefaultCircleRadius;
    }
    
    if (path == GMPointUpToDown)
    {
        return x + GMChartViewDefaultCircleRadius*2;
    }
    
    if (path == GMPointDownToUp)
    {
        return x + GMChartViewDefaultCircleRadius;
    }
    return x;
}

//=============================================================================

#pragma mark - DataSet DataSource

//=============================================================================

- (CGFloat) xCoordForValue: (CGFloat) xValue
                forDataSet: (GMDataSet * )dataSet
{
    return [self xCoordinatesForValue: xValue];
}

//=============================================================================

- (CGFloat) yCoordForValue: (CGFloat) yValue
                forDataSet: (GMDataSet * )dataSet
{
    return [self yCoordinatesForValue: yValue];
}

//=============================================================================

@end
