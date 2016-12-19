// 
//  Truck.m
//  Hermes
//
//  Created by Lutz  Thalmann on 07.02.11.
//  Updated by Lutz  Thalmann on 22.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Truck.h"
#import "Truck_Type.h"

#import "DSPF_Error.h"

NSString * const TruckAttributeDeviceUdid = @"device_udid";

@implementation Truck

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"Trucks", @"Trucks");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfTrucks";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (Truck *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Truck	 *truck = nil;
	NSError  *error = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Truck class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [Truck withTruckId:[serverData valueForKey:@"id"]];
	
	// lastObject returns nil, if no data in db_handle
	truck				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!truck) {
			// INSERT new Object (db_handle returns nil without an error)
			truck = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Truck class]) inManagedObjectContext:aCtx];
			truck.truck_id = [NSNumber numberWithInt:[[serverData valueForKey:@"id"] intValue]];
		}
		// UPDATE properties for existing Object
		truck.truck_type_id    = [Truck_Type truck_TypeWithTruckData:serverData inCtx:aCtx];
		truck.code			   = [serverData stringForKey:@"code"];
		truck.description_text = [serverData stringForKey:@"description"];
        if (PFBrandingSupported(BrandingTechnopark, nil))
            truck.device_udid = PFDeviceId();
        else
            truck.device_udid	   = [serverData stringForKey:@"sn"];
        truck.licensePlate     = [serverData stringForKey:@"license_plate"];
	}
	
	return truck;
}

+ (Truck *)truckWithTraceData:(NSDictionary *)traceData inCtx:(NSManagedObjectContext *)aCtx {
	Truck	 *truck = nil;
	NSError  *error = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Truck class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [Truck withTruckId:[traceData valueForKey:@"truck_id"]];
	
	// lastObject returns nil, if no data in db_handle
	truck				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!truck) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_073", @"Transport-Fahrzeug speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_030", @"ACHTUNG: Es wurden keine Daten für Truck-ID %@ gefunden. "
									  "Die T&T-Daten werden unvollständig gespeichert und an die Zentrale übermittelt!"),
									  [[traceData valueForKey:@"truck_id"] intValue]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return truck;
}

+ (Truck *)truckWithTruckID:(NSNumber *)truckID inCtx:(NSManagedObjectContext *)aCtx {
    return [[self withPredicate:[Truck withTruckId:truckID] inCtx:aCtx] lastObject];
}

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
    return [Truck withPredicate:aPredicate sortDescriptors:nil inCtx:aCtx];
}

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *trucks = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Truck class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	trucks				   = [aCtx executeFetchRequest:db_handle error:&error];

	return trucks;
}

@dynamic code;
@dynamic description_text;
@dynamic device_udid;
@dynamic licensePlate;
@dynamic truck_id;
@dynamic trace_log_id;
@dynamic truck_type_id;
@dynamic tour_truck_id;
@dynamic tour_trailer_id;

@end


@implementation Truck (Predicates)

+ (NSPredicate *) withTruckId:(NSNumber *) truckId {
    return [NSPredicate predicateWithFormat:@"truck_id = %i", [truckId intValue]];
}

+ (NSPredicate *) withDeviceId:(NSString *) deviceUdid {
    return [NSPredicate predicateWithFormat:@"device_udid = %@", deviceUdid];
}

+ (NSPredicate *) withCode:(NSString *) code {
    return [NSPredicate predicateWithFormat:@"code = %@", code];
}

@end

