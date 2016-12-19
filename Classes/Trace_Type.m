// 
//  Trace_Type.m
//  Hermes
//
//  Created by Lutz  Thalmann on 04.02.11.
//  Updated by Lutz  Thalmann on 19.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Trace_Type.h"
#import "Transport.h"
#import "LocalizedDescription.h"
#import "DSPF_Error.h"

NSString * const TraceTypeStringLoad = @"LOAD";
NSString * const TraceTypeStringUnload = @"UNLOAD";
NSString * const TraceTypeStringUntouched = @"UNTOUCHED";
NSString * const TraceTypeStringDeliverySignature = @"DELIVERYSIGNATURE";
NSString * const TraceTypeStringDeliveryPhoto = @"DELIVERYPHOTO";
NSString * const TraceTypeStringPickUpSignature = @"PICKUPSIGNATURE";
NSString * const TraceTypeStringPickUpPhoto = @"PICKUPPHOTO";
NSString * const TraceTypeStringPaymentOnDelivery = @"PAYMENTONDELIVERY";
NSString * const TraceTypeStringLocationPhoto = @"LOCATIONPHOTO";
NSString * const TraceTypeStringItemPhoto = @"ITEMPHOTO";
NSString * const TraceTypeStringEndOfTour = @"ENDOFTOUR";
NSString * const TraceTypeStringOutOfOrders = @"OUTOFORDERS";
NSString * const TraceTypeStringTourStopCancelled = @"TOURSTOPCANCELLED";
NSString * const TraceTypeStringTourCancelled = @"TOURCANCELLED";
NSString * const TraceTypeStringReuseTransportBox = @"REUSETRANSPORTBOX";



@implementation Trace_Type 

+ (Trace_Type *)trace_TypeWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Trace_Type *trace_Type  = nil;
	NSError    *error		= nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Trace_Type" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"trace_type_id = %@", [serverData valueForKey:@"id"]];
	
	// lastObject returns nil, if no data in db_handle
	trace_Type			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!trace_Type) {
			// INSERT new Object (db_handle returns nil without an error)
			trace_Type = [NSEntityDescription insertNewObjectForEntityForName:@"Trace_Type" inManagedObjectContext:aCtx];
			trace_Type.trace_type_id = [serverData valueForKey:@"id"];
		}
		// UPDATE properties for existing Object
		trace_Type.code			  = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"trace_type"]];
		trace_Type.description_text = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"description"]];
	}
	
	return trace_Type;
}

+ (Trace_Type *)trace_TypeWithTransportData:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx {
	Trace_Type *trace_Type  = nil;
	NSError    *error		= nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Trace_Type" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"trace_type_id = %@", [transportData valueForKey:@"trace_type_id"]];
	
	// lastObject returns nil, if no data in db_handle
	trace_Type			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!trace_Type) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_071", @"Transport-Prozess speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_028", @"ACHTUNG: Es wurden keine Daten für Trace-Type-ID %@ gefunden. Der Transport-Code %@ muss wieder abgeladen werden!"),
									  [transportData valueForKey:@"trace_type_id"], [transportData valueForKey:@"code"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return trace_Type;
}

+ (Trace_Type *)trace_TypeWithTraceData:(NSDictionary *)traceData inCtx:(NSManagedObjectContext *)aCtx {
	Trace_Type *trace_Type  = nil;
	NSError    *error		= nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Trace_Type" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"trace_type_id = %@", [traceData valueForKey:@"trace_type_id"]];
	
	// lastObject returns nil, if no data in db_handle
	trace_Type			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!trace_Type) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:@"Transport-Trace speichern"
						 messageText:[NSString stringWithFormat:@"ACHTUNG: Es wurden keine Daten für Trace-Type-ID %@ gefunden. Der Transport-Code %@ muss wieder abgeladen werden!",
									  [traceData valueForKey:@"trace_type_id"], [traceData valueForKey:@"code"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return trace_Type;
}

+ (NSArray  *)trace_TypesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *trace_Types = nil;
	NSError  *error		  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Trace_Type" inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
	// db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	trace_Types			   = [aCtx executeFetchRequest:db_handle error:&error];
	if (aPredicate) {
		if (!trace_Types || trace_Types.count == 0) {
			NSLog(@"Trace_Types has no records for %@", [aPredicate predicateFormat]);
		}
	}
	
	return trace_Types;
}

@dynamic code;
@dynamic trace_type_id;
@dynamic description_text;
@dynamic featureCode;
@dynamic supertype_id;
@dynamic transport_id;
@dynamic trace_log_id;
@dynamic subtype_id;

@end


@implementation Trace_Type(Additions)

- (NSString *) localizedDescriptionText {
    NSString *result = self.description_text;
    
    NSError *error = nil;
    NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
    db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([LocalizedDescription class]) inManagedObjectContext:[self managedObjectContext]];
    db_handle.predicate    = [LocalizedDescription withCode:NSStringFromClass([Trace_Type class]) language:currentLocaleCode() key:self.code];
    
    LocalizedDescription *description = [[[self managedObjectContext] executeFetchRequest:db_handle error:&error] lastObject];
    if (error != nil) {
        NSLog(@"Could not fetch %@ for key: %@", NSStringFromClass([LocalizedDescription class]), self.code);
    } else {
        if (description != nil) {
            result = description.text;
        }
    }
    
    return result;
}

- (BOOL) isTypeInWorkingRange {
    return [self.trace_type_id intValue] < 80;
}

+ (NSString *) traceTypeStringFromValue:(TraceTypeValue) traceTypeValue {
    NSString *result = @"";
    switch (traceTypeValue) {
        case TraceTypeValueMissing:
            result= @"";
            break;
        case TraceTypeValueLoad:
            result = TraceTypeStringLoad;
            break;
        case TraceTypeValueUnload:
            result = TraceTypeStringUnload;
            break;
        case TraceTypeValueUntouched:
            result = TraceTypeStringUntouched;
            break;
        case TraceTypeValueDeliveryPhoto:
            result = TraceTypeStringDeliveryPhoto;
            break;
        case TraceTypeValueDeliverySignature:
            result = TraceTypeStringDeliverySignature;
            break;
        case TraceTypeValuePickUpSignature:
            result = TraceTypeStringPickUpSignature;
            break;
        case TraceTypeValuePickUpPhoto:
            result = TraceTypeStringPickUpPhoto;
            break;
        case TraceTypeValuePaymentOnDelivery:
            result = TraceTypeStringPaymentOnDelivery;
            break;
        case TraceTypeValueLocationPhoto:
            result = TraceTypeStringLocationPhoto;
            break;
        case TraceTypeValueItemPhoto:
            result = TraceTypeStringItemPhoto;
            break;
        case TraceTypeValueEndOfTour:
            result = TraceTypeStringEndOfTour;
            break;
        case TraceTypeValueOutOfOrders:
            result = TraceTypeStringOutOfOrders;
            break;
        case TraceTypeValueTourStopCancelled:
            result = TraceTypeStringTourStopCancelled;
            break;
        case TraceTypeValueTourCancelled:
            result = TraceTypeStringTourCancelled;
            break;
        case TraceTypeValueReuseBox:
            result = TraceTypeStringReuseTransportBox;
            break;
        default:
            break;
    }
    return result;
}

@end


@implementation Trace_Type(Predicates)

+ (NSPredicate *) predicateForTraceTypesForDeadEnd {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"trace_type_id BETWEEN {91, 93}"];
    
    if (PFBrandingSupported(BrandingViollier, nil)) {
        predicate = [NSPredicate predicateWithFormat:@"trace_type_id BETWEEN {91, 91}"];
    } else if (PFBrandingSupported(BrandingOerlikon, nil)) {
        predicate = [NSPredicate predicateWithFormat:@"trace_type_id IN {91, 94} OR trace_type_id BETWEEN {96, 99}"];
    } else if (PFBrandingSupported(BrandingUnilabs, nil)) {
        predicate = [NSPredicate predicateWithFormat:@"trace_type_id IN {91, 97, 92, 93, 94, 95}"];
    }
    
    return predicate;
}

+ (NSArray *) defaultSortDescriptors {
    return @[[NSSortDescriptor sortDescriptorWithKey:@"trace_type_id" ascending:YES]];
}

@end