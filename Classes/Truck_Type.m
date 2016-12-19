// 
//  Truck_Type.m
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Updated by Lutz  Thalmann on 19.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Truck_Type.h"

@implementation Truck_Type

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"Truck Types", @"Truck Types");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfTruckTypes";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (Truck_Type *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Truck_Type *truck_Type = nil;
	NSError	   *error	   = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Truck_Type" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"truck_type_id = %@", [serverData valueForKey:@"id"]];
	
	// lastObject returns nil, if no data in db_handle
	truck_Type			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!truck_Type) {
			// INSERT new Object (db_handle returns nil without an error)
			truck_Type = [NSEntityDescription insertNewObjectForEntityForName:@"Truck_Type" inManagedObjectContext:aCtx];
			truck_Type.truck_type_id = [NSNumber numberWithInt:[[serverData valueForKey:@"id"] intValue]];
		}
		// UPDATE properties for existing Object
		truck_Type.truck_type		 = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"truck_type"]];
		truck_Type.description_text  = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"description"]];
        if ([serverData objectForKey:@"is_trailer"]) {
            truck_Type.isTrailer = [NSNumber numberWithBool:[[serverData objectForKey:@"is_trailer"] boolValue]];
        } else {
            truck_Type.isTrailer = nil;
        }
	}
	
	return truck_Type;
}

+ (Truck_Type *)truck_TypeWithTruckData:(NSDictionary *)truckData inCtx:(NSManagedObjectContext *)aCtx {
	Truck_Type *truck_Type = nil;
	NSError	   *error	   = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Truck_Type" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"truck_type_id = %@", [truckData valueForKey:@"truck_type_id"]];
	
	// lastObject returns nil, if no data in db_handle
	truck_Type			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!truck_Type) {
			// INSERT new Object (db_handle returns nil without an error)
			truck_Type = [NSEntityDescription insertNewObjectForEntityForName:@"Truck_Type" inManagedObjectContext:aCtx];
			truck_Type.truck_type_id = [NSNumber numberWithInt:[[truckData valueForKey:@"truck_type_id"] intValue]];
		}
		// UPDATE properties for existing Object
	}
	
	return truck_Type;
}

+ (NSArray  *)truck_TypesWithPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *truck_Types = nil;
	NSError  *error		  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Truck_Type" inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
	
	// lastObject returns nil, if no data in db_handle
	truck_Types			   = [aCtx executeFetchRequest:db_handle error:&error];

	return truck_Types;
}

@dynamic truck_type_id;
@dynamic description_text;
@dynamic truck_type;
@dynamic isTrailer;
@dynamic truck_id;

@end
