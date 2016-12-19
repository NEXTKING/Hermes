//
//  Transport_Group.h
//  Hermes
//
//  Created by Lutz  Thalmann on 31.10.11.
//  Updated by Lutz  Thalmann on 03.10.14.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Transport.h"
#import "Departure.h"
#import "Location.h"

@interface Transport_Group : NSManagedObject<DPHSynchronizable> {
}

+ (Transport_Group *)fromServerData:(NSDictionary *)serverData    inCtx:(NSManagedObjectContext *)aCtx;
+ (Transport_Group *)transport_GroupWithTask:(NSString *)aTask                   inCtx:(NSManagedObjectContext *)aCtx;
+ (Transport_Group *)transport_GroupWithTransportData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate           inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)withPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors
                    inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * contractee_code;
@property (nonatomic, strong) NSString * customer;
@property (nonatomic, strong) NSNumber * deliveryAction;
@property (nonatomic, strong) NSDate * deliveryDate;
@property (nonatomic, strong) NSNumber * deliveryDateFixed;
@property (nonatomic, strong) NSDate * deliveryFrom;
@property (nonatomic, strong) NSString * deliveryInfoText;
@property (nonatomic, strong) NSDate * deliveryUntil;
@property (nonatomic, strong) NSDate * execution_time;
@property (nonatomic, strong) NSNumber * handOutAgainstReceipt;
@property (nonatomic, strong) NSString * info_text;
@property (nonatomic, strong) NSNumber * isPickup;
@property (nonatomic, strong) NSDecimalNumber * paymentOnDelivery;
@property (nonatomic, strong) NSDecimalNumber * paymentOnPickup;
@property (nonatomic, strong) NSNumber * pickUpAction;
@property (nonatomic, strong) NSNumber * pickUpAgainstReceipt;
@property (nonatomic, strong) NSDate * pickUpDate;
@property (nonatomic, strong) NSNumber * pickUpDateFixed;
@property (nonatomic, strong) NSDate * pickUpFrom;
@property (nonatomic, strong) NSString * pickUpInfoText;
@property (nonatomic, strong) NSDate * pickUpUntil;
@property (nonatomic, strong) NSDecimalNumber * price;
@property (nonatomic, strong) NSString * task;
@property (nonatomic, strong) NSNumber * transport_group_id;
@property (nonatomic, strong) Location *addressee_id;
@property (nonatomic, strong) NSSet *departure_id;
@property (nonatomic, strong) Location *freightpayer_id;
@property (nonatomic, strong) Location *sender_id;
@property (nonatomic, strong) NSSet *transport_id;
@end

@interface Transport_Group (CoreDataGeneratedAccessors)

- (void)addDeparture_idObject:(Departure *)value;
- (void)removeDeparture_idObject:(Departure *)value;
- (void)addDeparture_id:(NSSet *)values;
- (void)removeDeparture_id:(NSSet *)values;

- (void)addTransport_idObject:(Transport *)value;
- (void)removeTransport_idObject:(Transport *)value;
- (void)addTransport_id:(NSSet *)values;
- (void)removeTransport_id:(NSSet *)values;

@end

@interface Transport_Group (Hermes)

- (NSArray *)transportSummaryWithSortDescriptors:(NSArray *)sortDescriptors;

+ (Transport_Group *) transportGroupForItem:(id) item ctx:(NSManagedObjectContext *)ctx createWhenNotExisting:(BOOL)createWhenNotExisting;

@end


@interface Transport_Group (Predicates)

+ (NSPredicate *) deletableOnEndOfTour;
+ (NSPredicate *) withoutReferences;
+ (NSPredicate *) withCode:(NSString *) code;
+ (NSPredicate *) withTourId:(int) tourId;
+ (NSPredicate *) withDayOfWeek:(int) dayOfWeek;
+ (NSPredicate *) withLocation:(Location *)location;
@end


