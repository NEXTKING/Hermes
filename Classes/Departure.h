//
//  Departure.h
//  Hermes
//
//  Created by Lutz Thalmann on 19.09.14
//  Updated by Lutz Thalmann on 25.09.14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Tour.h"
#import "Location.h"
#import "Transport_Group.h"
#import "Transport.h"

typedef enum : NSInteger {
    LocationGroupValueWerk = 1,
    LocationGroupValueOrt = 2,
    LocationGroupValuePost = 3
} LocationGroupValue;

@interface Schedule : NSObject<DPHSynchronizable>

@end

@interface Departure : NSManagedObject<DPHSynchronizable>

+ (Departure *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (Departure *)departureWithTransportData:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx;
+ (Departure *)departureWithDepartureID:(NSNumber *)departureID inCtx:(NSManagedObjectContext *)aCtx;

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)distinctLocationsFromDeparturesWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors
                                    inCtx:(NSManagedObjectContext *)aCtx;
+ (NSInteger )currentDepartureSequenceInCtx:(NSManagedObjectContext *)aCtx;

+ (NSArray *) departuresOfCurrentlyDrivenTourInCtx:(NSManagedObjectContext *) ctx;
+ (NSArray *) tourDeparturesInCtx:(NSManagedObjectContext *)ctx sortedAscending:(BOOL) ascending;

+ (Departure *)firstTourDepartureInCtx:(NSManagedObjectContext *) ctx;
+ (Departure *)lastTourDepartureInCtx:(NSManagedObjectContext *) ctx;

@property (nonatomic, strong) NSDate * arrival;
@property (nonatomic, strong) NSDate * arrivalDate;
@property (nonatomic, strong) NSNumber * canceled;
@property (nonatomic, strong) NSNumber * confirmed;
@property (nonatomic, strong) NSNumber * currentTourBit;
@property (nonatomic, strong) NSNumber * currentTourStatus;
@property (nonatomic, strong) NSNumber * dayOfWeek;
@property (nonatomic, strong) NSDate * departure;
@property (nonatomic, strong) NSNumber * departure_id;
@property (nonatomic, strong) NSDate * departureDate;
@property (nonatomic, strong) NSString * infoMessage;
@property (nonatomic, strong) NSDate * infoMessageDate;
@property (nonatomic, strong) NSString * infoText;
@property (nonatomic, strong) NSNumber * onDemand;
@property (nonatomic, strong) NSNumber * predefinedOrder;
@property (nonatomic, strong) NSNumber * preferredHandoverStop;
@property (nonatomic, strong) NSNumber * sequence;
@property (nonatomic, strong) Location *location_id;
@property (nonatomic, strong) Tour *tour_id;
@property (nonatomic, strong) Transport_Group *transport_group_id;
@property (nonatomic, strong) NSSet *transport_id;
@property (nonatomic, strong) NSSet *transport_target_id;
@end

@interface Departure (Predicates)

+ (NSPredicate *) withOnDemand:(BOOL) onDemand;
+ (NSPredicate *) withStatusLT:(NSInteger)maximumTourStatus;
+ (NSPredicate *) withCurrentBitSet:(BOOL)currentTourBitSet;
+ (NSPredicate *) withTour:(NSNumber *)tourId dayOfWeek:(NSNumber *)dow;
+ (NSPredicate *) withLocationType:(NSInteger)locationGroupId;
+ (NSPredicate *) withLocationCode:(NSString *)locationCode;
+ (NSPredicate *) forDestinationList:(NSInteger) destinationList;
+ (NSPredicate *) withLocation:(Location *)location;

@end

@interface Departure (CoreDataGeneratedAccessors)

- (void)addTransport_idObject:(Transport *)value;
- (void)removeTransport_idObject:(Transport *)value;
- (void)addTransport_id:(NSSet *)values;
- (void)removeTransport_id:(NSSet *)values;

- (void)addTransport_target_idObject:(Transport *)value;
- (void)removeTransport_target_idObject:(Transport *)value;
- (void)addTransport_target_id:(NSSet *)values;
- (void)removeTransport_target_id:(NSSet *)values;

@end
