//
//  Transport.h
//  dphHermes
//
//  Created by Lutz  Thalmann on 01.07.14.
//  Updated by Lutz  Thalmann on 24.09.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Item.h"
#import "Payment_Type.h"
#import "Term.h"
#import "Trace_Log.h"
#import "Trace_Type.h"
#import "Transport_Box.h"
#import "Transport_Packaging.h"

@class Transport_Group;
@class Location;
@class Departure;
@class Tour;

enum {
    Unit =                          1 << 0,
    OpenUnit =                      1 << 1,
    TransportationUnit =            1 << 2,
    Pallet =                        1 << 3,
    OpenPallet =                    1 << 4,
    TransportationPallet =          1 << 5,
    RollContainer =                 1 << 6,
    OpenRollContainer =             1 << 7,
    TransportationRollContainer =   1 << 8,
    Pick =                          1 << 9
};
typedef NSInteger TransportTypes;

@interface Cargo : NSObject<DPHSynchronizable>

@end

@interface Transport : NSManagedObject<DPHSynchronizable>

+ (Transport *)fromServerData:(NSDictionary *)serverData         inCtx:(NSManagedObjectContext *)ctx;
+ (Transport *)transportWithDictionaryData:(NSDictionary *)dictionaryData inCtx:(NSManagedObjectContext *)ctx;
+ (Transport *)transportWithTraceData:(NSDictionary *)traceData           inCtx:(NSManagedObjectContext *)ctx;
+ (Transport *)transportWithCargoData:(NSDictionary *)cargoData           inCtx:(NSManagedObjectContext *)ctx;

+ (NSArray *)withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)ctx;
+ (NSArray *)transportsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)ctx;
+ (Location *)destinationForTransportCode:(NSString *)aTransportCode inCtx:(NSManagedObjectContext *)ctx;
+ (Location *)destinationFromBarcode:(NSString *) barcode inCtx:(NSManagedObjectContext *) aCtx;

+ (NSInteger  )transportsCount:(NSArray *)transports;

+ (NSInteger) countOf:(TransportTypes)types forTourDeparture:(Departure *)departure ctx:(NSManagedObjectContext *)ctx;
+ (NSInteger) countOf:(TransportTypes)types forTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup ctx:(NSManagedObjectContext *)ctx;

+ (NSInteger) countOf:(TransportTypes)types fromTourDeparture:(Departure *)departure ctx:(NSManagedObjectContext *)ctx;
+ (NSInteger) countOf:(TransportTypes)types fromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup ctx:(NSManagedObjectContext *)ctx;

+ (NSDecimalNumber *)transportsOpenPriceForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)ctx;
+ (NSDecimalNumber *)transportsPriceForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)ctx;

+ (NSDecimalNumber *)transportsPriceFromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)ctx;

// ------------ use -countOf:.... instead

// for tour
+ (NSInteger  )transportsOpenPalletCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                                 inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger  )transportsOpenRollContainerCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                                        inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger  )transportsOpenUnitCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                               inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger  )transportsTransportationPalletCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                                           inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger  )transportsTransportationRollContainerCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                                                  inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger  )transportsTransportationUnitCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                                         inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger  )transportsPalletCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                             inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger  )transportsRollContainerCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                                    inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger  )transportsUnitCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                           inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger  )transportsPickCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                           inCtx:(NSManagedObjectContext *)ctx;
// ------------

+ (BOOL)hasStagingInfo:(NSString *) stagingInfo toLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx;
+ (BOOL)hasStagingInfo:(NSString *) stagingInfo forLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx;

+ (BOOL)shouldUnloadTransportCode:(NSString *)aTransportCode atLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                            inCtx:(NSManagedObjectContext *)ctx;
+ (BOOL)shouldUnloadTransportItems:(NSString *)aTransportCode atLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                             inCtx:(NSManagedObjectContext *)ctx;

+ (BOOL)shouldLoadTransportCode:(NSString *)aTransportCode transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)ctx;
+ (BOOL)shouldLoadTransportItems:(NSString *)aTransportCode transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)ctx;

+ (BOOL)hasTransportCodesFromDeparture:(NSNumber *)aDepartureID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)ctx;
+ (BOOL)hasTransportUloadCodesFromLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)ctx;

+ (BOOL)hasReasonCodesFromDeparture:(NSNumber *)aDepartureID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)ctx;
+ (NSArray *)coordinateForTransportCode:(NSString *)aTransportCode   inCtx:(NSManagedObjectContext *)ctx;

+ (NSArray *) allInfoSigns;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * currency;
@property (nonatomic, strong) NSNumber * isPallet;
@property (nonatomic, strong) NSNumber * occurrences;
@property (nonatomic, strong) NSDecimalNumber * price;
@property (nonatomic, strong) NSString * stagingArea;
@property (nonatomic, strong) NSString * stagingInfo;
@property (nonatomic, strong) NSNumber * transport_id;
@property (nonatomic, strong) NSDecimalNumber * weight;
@property (nonatomic, strong) NSNumber * isCodeNotScannable;
@property (nonatomic, strong) NSNumber * isPickUpOnly;
@property (nonatomic, strong) NSNumber * requestType;
@property (nonatomic, strong) NSDecimalNumber * paymentOnPickUp;
@property (nonatomic, strong) NSDecimalNumber * paymentOnDelivery;
@property (nonatomic, strong) NSDecimalNumber * netWeight;
@property (nonatomic, strong) NSString * pickUpDocumentNumber;
@property (nonatomic, strong) NSString * deliveryDocumentNumber;
@property (nonatomic, strong) NSString * infoMessage;
@property (nonatomic, strong) NSString * infoText;
@property (nonatomic, strong) NSNumber * temperatureLimit;
@property (nonatomic, strong) NSString * temperatureZone;
@property (nonatomic, strong) NSNumber * itemQTY;
@property (nonatomic, strong) NSString * itemQTYUnit;
@property (nonatomic, strong) NSString * requestBarcode;
@property (nonatomic, strong) NSDate * executionFrom;
@property (nonatomic, strong) NSDate * executionUntil;
@property (nonatomic, strong) Departure *from_departure_id;
@property (nonatomic, strong) Location *from_location_id;
@property (nonatomic, strong) Item *item_id;
@property (nonatomic, strong) Payment_Type *payment_type_id;
@property (nonatomic, strong) Term *term_id;
@property (nonatomic, strong) Location *to_location_id;
@property (nonatomic, strong) Tour *tour_id;
@property (nonatomic, strong) NSSet *trace_log_id;
@property (nonatomic, strong) Trace_Type *trace_type_id;
@property (nonatomic, strong) Transport_Box *transport_box_id;
@property (nonatomic, strong) Transport_Group *transport_group_id;
@property (nonatomic, strong) Transport_Packaging *transport_packaging_id;
@property (nonatomic, strong) Transport *grouptransport_id;
@property (nonatomic, strong) Location *final_destination_id;
@property (nonatomic, strong) NSSet *subtransport_id;
@property (nonatomic, strong) Departure *to_departure_id;
@end

@interface Transport (CoreDataGeneratedAccessors)

- (void)addTrace_log_idObject:(Trace_Log *)value;
- (void)removeTrace_log_idObject:(Trace_Log *)value;
- (void)addTrace_log_id:(NSSet *)values;
- (void)removeTrace_log_id:(NSSet *)values;

- (void)addSubtransport_idObject:(Transport *)value;
- (void)removeSubtransport_idObject:(Transport *)value;
- (void)addSubtransport_id:(NSSet *)values;
- (void)removeSubtransport_id:(NSSet *)values;

@end


@interface Transport (Predicates)

+ (NSPredicate *) withCode:(NSString *)code;
+ (NSPredicate *) withCodes:(NSArray *)codes;
+ (NSPredicate *) withBoxCode:(NSString *)boxCode;
+ (NSPredicate *) withToLocation:(Location *) toLocation;
+ (NSPredicate *) withToLocationId:(NSNumber *) toLocationId;
+ (NSPredicate *) withFromLocation:(Location *) fromLocation;
+ (NSPredicate *) withFromLocationId:(NSNumber *) fromLocationId;
+ (NSPredicate *) withFromDepartureLocation:(Location *) fromDepartureLocation;
+ (NSPredicate *) withFromDepartureLocationId:(NSNumber *) fromDepartureLocationId;
+ (NSPredicate *) withTransportGroup:(Transport_Group *) transportGroup;
+ (NSPredicate *) withTransportGroupId:(NSNumber *) transportGroupId;
+ (NSPredicate *) withItemsCategoryCodes:(NSArray *) categoryCodesOrNil;
+ (NSPredicate *) ofTourWithId:(NSNumber *)tourIdOrNil;
+ (NSPredicate *) withoutItem;
+ (NSPredicate *) withFromDeparture:(Departure *) fromDeparture;
+ (NSPredicate *) withFromDepartureId:(NSNumber *) fromDepartureId;
+ (NSPredicate *) withMaskedCode;
+ (NSPredicate *) withTraceLogCodes:(NSArray *)traceLogCodesOrNil;
+ (NSPredicate *) withTraceLogCodeOver80;
+ (NSPredicate *) withoutTracelogEntries;
+ (NSPredicate *) havingTraceLogEntriesOlderThan:(NSDate *) minDate;
+ (NSPredicate *) havingTraceLog:(BOOL) havingTraceLogEntries withCategoryCodes:(NSArray *) categoryCodes ofTour:(NSNumber *) tourIdOrNil;
+ (NSPredicate *) deletableOnEndOfTour;
   
@end

@interface Transport (Validation)
+ (NSString *) transportDestinationFromBarcode:(NSString *) barcode;
+ (NSString *) transportCodeFromBarcode:(NSString *) barcode;
+ (NSString *) trailerFromBarcode:(NSString *) barcode;
+ (NSRange) rangeOfTrailerFromBarcode:(NSString *) barcode;
+ (NSRange) rangeOfTrailerPattern:(NSString *) pattern fromBarcode:(NSString *) barcode;
+ (BOOL) validateTransportWithCode:(NSString *) transportCode;
+ (BOOL) canPlaceTransportWithCode:(NSString *) sourceTransportCode toTransportWithCode:(NSString *)targetTransportCode;
+ (BOOL) validateTextInput:(NSString *) code;
@end

@interface Transport (BarcodeSupport)
+ (NSString *) replaceAliasFromTransportCode:(NSString *) transportCode ctx:(NSManagedObjectContext *) ctx;
@end


@interface Transport (TraceLogGeneration)
+ (NSMutableDictionary *) dictionaryWithCode:(NSString *)transportCode traceType:(TraceTypeValue)traceType
                                   fromDeparture:(Departure *) departure toLocation:(Location *) toLocation finalDestination:(Location *) finalDestination
                                    isPallet:(NSNumber *) isPallet;
+ (NSMutableDictionary *) dictionaryWithCode:(NSString *)transportCode traceType:(TraceTypeValue)traceType
                               fromDeparture:(Departure *) departure toLocation:(Location *) toLocation;
+ (void) addLocation:(CLLocation *) location toTraceLogDict:(NSMutableDictionary *)transport;
+ (void) addTransportBox:(Transport_Box *) box toTraceLogDict:(NSMutableDictionary *)transport;
@end
