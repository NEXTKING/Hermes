//
//  Truck.h
//  Hermes
//
//  Created by Lutz  Thalmann on 07.02.11.
//  Updated by Lutz  Thalmann on 22.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "Trace_Log.h"
#import "Tour.h"

extern NSString * const TruckAttributeDeviceUdid;

@class Truck_Type;

@interface Truck :  NSManagedObject<DPHSynchronizable> {
}

+ (Truck *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (Truck *)truckWithTraceData:(NSDictionary *)traceData   inCtx:(NSManagedObjectContext *)aCtx;
+ (Truck *)truckWithTruckID:(NSNumber *)truckID inCtx:(NSManagedObjectContext *)aCtx;

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * description_text;
@property (nonatomic, retain) NSString * device_udid;
@property (nonatomic, retain) NSString * licensePlate;
@property (nonatomic, retain) NSNumber * truck_id;
@property (nonatomic, retain) NSSet *trace_log_id;
@property (nonatomic, retain) Truck_Type *truck_type_id;
@property (nonatomic, retain) NSSet *tour_truck_id;
@property (nonatomic, retain) NSSet *tour_trailer_id;

@end


@interface Truck (CoreDataGeneratedAccessors)

- (void)addTrace_log_idObject:(Trace_Log *)value;
- (void)removeTrace_log_idObject:(Trace_Log *)value;
- (void)addTrace_log_id:(NSSet *)values;
- (void)removeTrace_log_id:(NSSet *)values;

- (void)addTour_truck_idObject:(Tour *)value;
- (void)removeTour_truck_idObject:(Tour *)value;
- (void)addTour_truck_id:(NSSet *)values;
- (void)removeTour_truck_id:(NSSet *)values;

- (void)addTour_trailer_idObject:(Tour *)value;
- (void)removeTour_trailer_idObject:(Tour *)value;
- (void)addTour_trailer_id:(NSSet *)values;
- (void)removeTour_trailer_id:(NSSet *)values;

@end


@interface Truck (Predicates)
+ (NSPredicate *) withCode:(NSString *) code;
+ (NSPredicate *) withTruckId:(NSNumber *) truckId;
+ (NSPredicate *) withDeviceId:(NSString *) deviceUdid;
@end

