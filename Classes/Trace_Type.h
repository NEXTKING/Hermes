//
//  Trace_Type.h
//  Hermes
//
//  Created by Lutz  Thalmann on 04.02.11.
//  Updated by Lutz  Thalmann on 19.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "Trace_Log.h"

@class Transport;

extern NSString * const TraceTypeStringLoad;
extern NSString * const TraceTypeStringUnload;
extern NSString * const TraceTypeStringUntouched;
extern NSString * const TraceTypeStringReuseTransportBox;
/*
 
 < 80   Arbeitscodes
 80-90  Spezial-Aktionen
 90     Ausreden
 100-200 Subtypen von den Ausreden
 1000-1009 Workflow-Steuerung
 
 */

typedef enum : NSInteger {
    TraceTypeValueMissing = -1,
    TraceTypeValueLoad = 1,
    TraceTypeValueUnload = 2,
    TraceTypeValueUntouched = 9,
    TraceTypeValueDeliverySignature = 81,
    TraceTypeValueDeliveryPhoto = 82,
    TraceTypeValuePickUpSignature = 83,
    TraceTypeValuePickUpPhoto = 84,
    TraceTypeValuePaymentOnDelivery = 85,
    TraceTypeValueLocationPhoto = 88,
    TraceTypeValueItemPhoto = 89,
    TraceTypeValueEndOfTour = 90,
    TraceTypeValueOutOfOrders = 91,
    TraceTypeValueTourStopCancelled = 1001,
    TraceTypeValueTourCancelled = 1002,
    TraceTypeValueReuseBox = 1010,
    TraceTypeValueReorder = 6001,
    TraceTypeValueTimeChange = 6002
} TraceTypeValue;

@interface Trace_Type :  NSManagedObject {
}

+ (Trace_Type *)trace_TypeWithServerData:(NSDictionary *)serverData       inCtx:(NSManagedObjectContext *)aCtx;
+ (Trace_Type *)trace_TypeWithTransportData:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx;
+ (Trace_Type *)trace_TypeWithTraceData:(NSDictionary *)traceData         inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray    *)trace_TypesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSNumber * trace_type_id;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSString * featureCode;
@property (nonatomic, strong) Trace_Type *supertype_id;
@property (nonatomic, strong) NSSet* transport_id;
@property (nonatomic, strong) NSSet* trace_log_id;
@property (nonatomic, strong) NSSet* subtype_id;

@end


@interface Trace_Type (CoreDataGeneratedAccessors)
- (void)addTransport_idObject:(Transport *)value;
- (void)removeTransport_idObject:(Transport *)value;
- (void)addTransport_id:(NSSet *)value;
- (void)removeTransport_id:(NSSet *)value;

- (void)addTrace_log_idObject:(Trace_Log *)value;
- (void)removeTrace_log_idObject:(Trace_Log *)value;
- (void)addTrace_log_id:(NSSet *)value;
- (void)removeTrace_log_id:(NSSet *)value;

- (void)addSubtype_idObject:(Trace_Type *)value;
- (void)removeSubtype_idObject:(Trace_Type *)value;
- (void)addSubtype_id:(NSSet *)values;
- (void)removeSubtype_id:(NSSet *)values;

@end


@interface Trace_Type(Additions)
- (NSString *) localizedDescriptionText;
- (BOOL) isTypeInWorkingRange;
+ (NSString *) traceTypeStringFromValue:(TraceTypeValue) traceTypeValue;
@end


@interface Trace_Type(Predicates)

+ (NSPredicate *) predicateForTraceTypesForDeadEnd;

+ (NSArray *) defaultSortDescriptors;

@end

