//
//  Tour.h
//  Hermes
//
//  Created by Lutz  Thalmann on 07.02.11.
//  Updated by Lutz  Thalmann on 24.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "Departure.h"
#import "Tour.h"
#import "Transport.h"
#import "Truck.h"
#import "User.h"

extern NSString * const TourTaskLoadingOnly;
extern NSString * const TourTaskNormalDrive;
extern NSString * const TourTaskAdjustingOnly;
extern NSString * const TourTaskTourAbbruch;


@interface Tour :  NSManagedObject<DPHSynchronizable> {
}

+ (Tour *)fromServerData:(NSDictionary *)serverData       inCtx:(NSManagedObjectContext *)aCtx;
+ (Tour *)tourWithDepartureData:(NSDictionary *)departureData inCtx:(NSManagedObjectContext *)aCtx;
+ (Tour *)tourWithTransportData:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx;
+ (Tour *)currentTourWithTransportData:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx;
+ (Tour *)tourWithCargoData:(NSDictionary *)cargoData         inCtx:(NSManagedObjectContext *)aCtx;
+ (Tour *)tourWithTourID:(NSNumber *)tourID inCtx:(NSManagedObjectContext *)aCtx;

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * description_text;
@property (nonatomic, retain) NSString * device_udid;
@property (nonatomic, retain) NSNumber * isDriverEditable;
@property (nonatomic, retain) NSNumber * isShuttleTour;
@property (nonatomic, retain) NSString * shuttleIncludeZipCodes;
@property (nonatomic, retain) NSString * shuttleOmitZipCodes;
@property (nonatomic, retain) NSNumber * tour_id;
@property (nonatomic, retain) NSNumber * useMultiUserModeToLoad;
@property (nonatomic, retain) NSNumber * useMultiUserModeToUnload;
@property (nonatomic, retain) NSDate * validFrom;
@property (nonatomic, retain) NSDate * validUntil;
@property (nonatomic, retain) NSSet *departure_id;
@property (nonatomic, retain) NSSet *transport_id;
@property (nonatomic, retain) Truck *truck_id;
@property (nonatomic, retain) Truck *trailer_id;
@property (nonatomic, retain) Tour *grouptour_id;
@property (nonatomic, retain) User *driver_id;
@property (nonatomic, retain) NSSet *subtour_id;

@end


@interface Tour (CoreDataGeneratedAccessors)

- (void)addDeparture_idObject:(Departure *)value;
- (void)removeDeparture_idObject:(Departure *)value;
- (void)addDeparture_id:(NSSet *)values;
- (void)removeDeparture_id:(NSSet *)values;

- (void)addTransport_idObject:(Transport *)value;
- (void)removeTransport_idObject:(Transport *)value;
- (void)addTransport_id:(NSSet *)values;
- (void)removeTransport_id:(NSSet *)values;

- (void)addSubtour_idObject:(Tour *)value;
- (void)removeSubtour_idObject:(Tour *)value;
- (void)addSubtour_id:(NSSet *)values;
- (void)removeSubtour_id:(NSSet *)values;

@end

@interface Tour (Predicates)
+ (NSPredicate *) withDeviceId:(NSString *) deviceId;
+ (NSPredicate *) withTourId:(NSNumber *) tourId;
+ (NSPredicate *) withCode:(NSString *) code;
@end

