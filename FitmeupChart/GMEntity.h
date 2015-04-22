//
//  GMEntity.h
//  FitmeupChart
//
//  Created by Anton Gubarenko on 22.04.15.
//  Copyright (c) 2015 Anton Gubarenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GMEntity : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * weight;

@end
