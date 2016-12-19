//
//  Location.h
//  Hermes
//
//  Created by Attila Teglas on 4/15/12.
//  Updated by Lutz Thalmann on 22.09.14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Departure.h"
#import "Location_Alias.h"
#import "Recipient.h"
#import "Tour_Exception.h"
#import "Transport.h"
#import "Transport_Group.h"

@class Location_Group;

@interface Location : NSManagedObject<DPHSynchronizable>

- (NSString *) formattedString;

+ (Location *)fromServerData:(NSDictionary *)serverData                      inCtx:(NSManagedObjectContext *)aCtx;
+ (Location *)locationWithDepartureData:(NSDictionary *)departureData		 inCtx:(NSManagedObjectContext *)aCtx;
+ (Location *)locationWithTour_Exception:(NSDictionary *)tourExceptionData   inCtx:(NSManagedObjectContext *)aCtx;
+ (Location *)locationWithTransportOrigin:(NSDictionary *)transportData		 inCtx:(NSManagedObjectContext *)aCtx;
+ (Location *)locationWithTransportDestination:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx;
+ (Location *)locationWithRecipientData:(NSDictionary *)recipientData        inCtx:(NSManagedObjectContext *)aCtx;
+ (Location *)withID:(NSNumber *)locationID                                  inCtx:(NSManagedObjectContext *)aCtx;
+ (Location *)withCode:(NSString *)aCode                                     inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)locationsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * contact_email;
@property (nonatomic, strong) NSString * contact_mobilePhone;
@property (nonatomic, strong) NSString * contact_name;
@property (nonatomic, strong) NSString * contact_phone;
@property (nonatomic, strong) NSString * country_code;
@property (nonatomic, strong) NSString * erase_flag;
@property (nonatomic, strong) NSNumber * force_signature;
@property (nonatomic, strong) NSDate * lastCustomerSurvey;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSString * location_code;
@property (nonatomic, strong) NSNumber * location_id;
@property (nonatomic, strong) NSString * location_name;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSString * notice;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSString * zip;
@property (nonatomic, strong) NSSet *departure_id;
@property (nonatomic, strong) Location *groupLocation_id;
@property (nonatomic, strong) NSSet *location_alias_id;
@property (nonatomic, strong) Location_Group *location_group_id;
@property (nonatomic, strong) NSSet *memberLocation_id;
@property (nonatomic, strong) Location *preferredDisposer_id;
@property (nonatomic, strong) Location *preferredDisposerOf_id;
@property (nonatomic, strong) Location *preferredSupplier_id;
@property (nonatomic, strong) Location *preferredSupplierOf_id;
@property (nonatomic, strong) NSSet *recipient_id;
@property (nonatomic, strong) Tour_Exception *tour_exception_id;
@property (nonatomic, strong) NSSet *transport_destination_id;
@property (nonatomic, strong) NSSet *transport_origin_id;
@property (nonatomic, strong) NSSet *transport_group_sender_id;
@property (nonatomic, strong) NSSet *transport_group_addressee_id;
@property (nonatomic, strong) NSSet *transport_group_freightpayer_id;
@property (nonatomic, strong) NSSet *transport_final_destination_id;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addDeparture_idObject:(Departure *)value;
- (void)removeDeparture_idObject:(Departure *)value;
- (void)addDeparture_id:(NSSet *)values;
- (void)removeDeparture_id:(NSSet *)values;

- (void)addLocation_alias_idObject:(Location_Alias *)value;
- (void)removeLocation_alias_idObject:(Location_Alias *)value;
- (void)addLocation_alias_id:(NSSet *)values;
- (void)removeLocation_alias_id:(NSSet *)values;

- (void)addMemberLocation_idObject:(Location *)value;
- (void)removeMemberLocation_idObject:(Location *)value;
- (void)addMemberLocation_id:(NSSet *)values;
- (void)removeMemberLocation_id:(NSSet *)values;

- (void)addRecipient_idObject:(Recipient *)value;
- (void)removeRecipient_idObject:(Recipient *)value;
- (void)addRecipient_id:(NSSet *)values;
- (void)removeRecipient_id:(NSSet *)values;

- (void)addTransport_destination_idObject:(Transport *)value;
- (void)removeTransport_destination_idObject:(Transport *)value;
- (void)addTransport_destination_id:(NSSet *)values;
- (void)removeTransport_destination_id:(NSSet *)values;

- (void)addTransport_origin_idObject:(Transport *)value;
- (void)removeTransport_origin_idObject:(Transport *)value;
- (void)addTransport_origin_id:(NSSet *)values;
- (void)removeTransport_origin_id:(NSSet *)values;

- (void)addTransport_group_sender_idObject:(Transport_Group *)value;
- (void)removeTransport_group_sender_idObject:(Transport_Group *)value;
- (void)addTransport_group_sender_id:(NSSet *)values;
- (void)removeTransport_group_sender_id:(NSSet *)values;

- (void)addTransport_group_addressee_idObject:(Transport_Group *)value;
- (void)removeTransport_group_addressee_idObject:(Transport_Group *)value;
- (void)addTransport_group_addressee_id:(NSSet *)values;
- (void)removeTransport_group_addressee_id:(NSSet *)values;

- (void)addTransport_group_freightpayer_idObject:(Transport_Group *)value;
- (void)removeTransport_group_freightpayer_idObject:(Transport_Group *)value;
- (void)addTransport_group_freightpayer_id:(NSSet *)values;
- (void)removeTransport_group_freightpayer_id:(NSSet *)values;

- (void)addTransport_final_destination_idObject:(Transport_Group *)value;
- (void)removeTransport_final_destination_idObject:(Transport_Group *)value;
- (void)addTransport_final_destination_id:(NSSet *)values;
- (void)removeTransport_final_destination_id:(NSSet *)values;



@end

@interface Location (Predicates)
+ (NSPredicate *) withLocationID:(NSNumber *) locationId;
@end
