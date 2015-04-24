//
//  GMCoreDataHelper.m
//  FitmeupChart
//
//  Created by Anton Gubarenko on 22.04.15.
//  Copyright (c) 2015 Anton Gubarenko. All rights reserved.
//

#import "GMCoreDataHelper.h"
#import "GMDatePoint.h"
#import "NSDate+FitMeUp.h"
#import "UIColor+FitMeUp.h"

@implementation GMCoreDataHelper
#define debug 1
#define SECS_PER_DAY (86400)

#pragma mark - FILES
NSString *storeFilename = @"DataModel.sqlite";

#pragma mark - PATHS
- (NSString *)applicationDocumentsDirectory {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
}

- (NSURL *)applicationStoresDirectory {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    NSURL *storesDirectory =
    [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]]
     URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error]) {
            if (debug==1) {
                NSLog(@"Successfully created Stores directory");}
        }
        else {NSLog(@"FAILED to create Stores directory: %@", error);}
    }
    return storesDirectory;
}

- (NSURL *)storeURL {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[self applicationStoresDirectory]
            URLByAppendingPathComponent:storeFilename];
}

#pragma mark - SETUP
- (id)init {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {return nil;}
    
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc]
                    initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc]
                initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    return self;
}

- (void)loadStore {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) {return;} // Don't load store if it's already loaded
    NSError *error = nil;
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:[self storeURL]
                                              options:nil error:&error];
    if (!_store) {NSLog(@"Failed to add store. Error: %@", error);abort();}
    else         {if (debug==1) {NSLog(@"Successfully added store: %@", _store);}}
}

- (void)setupCoreData {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self loadStore];
}

#pragma mark - SAVING
- (void)saveContext {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        NSError *error = nil;
        if ([_context save:&error]) {
            NSLog(@"_context SAVED changes to persistent store");
        } else {
            NSLog(@"Failed to save _context: %@", error);
        }
    } else {
        NSLog(@"SKIPPED _context save, there are no changes!");
    }
}

+ (GMDataSet*) testDataSet
{
    //TEST
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat: @"dd.MM.yyyy"];
    NSDictionary *data1 = @{
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"03.06.2014"] timeIntervalSinceReferenceDate]]: @67.0,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"08.07.2014"]  timeIntervalSinceReferenceDate]]: @67.2,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"09.07.2014"]  timeIntervalSinceReferenceDate]]: @67.3,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"11.07.2014"]  timeIntervalSinceReferenceDate]]: @67.1,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"13.07.2014"]  timeIntervalSinceReferenceDate]]: @66.6,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"15.07.2014"]  timeIntervalSinceReferenceDate]]: @67.1,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"16.07.2014"]  timeIntervalSinceReferenceDate]]: @66.6,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"19.07.2014"]  timeIntervalSinceReferenceDate]]: @67.1,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"21.07.2014"]  timeIntervalSinceReferenceDate]]: @67.1,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"22.07.2014"]  timeIntervalSinceReferenceDate]]: @66.0,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"23.07.2014"]  timeIntervalSinceReferenceDate]]: @66.5,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"25.07.2014"]  timeIntervalSinceReferenceDate]]: @66.3,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"27.07.2014"]  timeIntervalSinceReferenceDate]]: @66.0,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"28.07.2014"]  timeIntervalSinceReferenceDate]]: @66.7,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"01.08.2014"]  timeIntervalSinceReferenceDate]]: @66.3,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"02.08.2014"]  timeIntervalSinceReferenceDate]]: @66.5,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"04.08.2014"]  timeIntervalSinceReferenceDate]]: @66.3,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"07.08.2014"]  timeIntervalSinceReferenceDate]]: @66.0,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"10.08.2014"]  timeIntervalSinceReferenceDate]]: @65.9,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"12.08.2014"]  timeIntervalSinceReferenceDate]]: @66.1,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"13.08.2014"]  timeIntervalSinceReferenceDate]]: @64.9,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"17.08.2014"]  timeIntervalSinceReferenceDate]]: @64.8,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"20.08.2014"]  timeIntervalSinceReferenceDate]]: @65.1,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"21.08.2014"]  timeIntervalSinceReferenceDate]]: @64.0,
                            [NSNumber numberWithInteger:[[dateFormat dateFromString: @"11.11.2014"]  timeIntervalSinceReferenceDate]]: @61.5,
                            [NSNumber numberWithInteger:[[NSDate date]  timeIntervalSinceReferenceDate]]: @0.0};
    GMDataSet *dataSet = [[GMDataSet alloc] initWithDictionary:data1];

    
    [dataSet sortPoints];
    [dataSet setPlotColor: [UIColor gm_greenColor]];
    
    return dataSet;
}
@end
