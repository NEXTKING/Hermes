//
//  Tour_Exception.h
//  Hermes
//
//  Created by iLutz on 15.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Tour_Exception : NSManagedObject <DPHSynchronizable>

+ (Tour_Exception *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (Tour_Exception *)todaysTourExceptionForLocation:(Location *)aLocation;
+ (NSArray  *)tour_ExceptionWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSDate * to_date;
@property (nonatomic, strong) NSNumber * tour_exception_id;
@property (nonatomic, strong) NSDate * from_date;
@property (nonatomic, strong) NSString * tour_exception_reason;
@property (nonatomic, strong) Location *location_id;

@end
