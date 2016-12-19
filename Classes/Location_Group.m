// 
//  Location_Group.m
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Updated by Lutz  Thalmann on 19.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Location_Group.h"

@implementation Location_Group

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"Location Groups", @"Location Groups");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfLocationGroups";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (Location_Group *)fromServerData:(NSDictionary *)serverData   inCtx:(NSManagedObjectContext *)aCtx {
	Location_Group *locationGroup = nil;
	NSError  *error				  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location_Group" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"location_group_id = %@", [serverData valueForKey:@"id"]];
	
	// lastObject returns nil, if no data in db_handle
	locationGroup          = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!locationGroup) {
			// INSERT new Object (db_handle returns nil without an error)
			locationGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Location_Group" inManagedObjectContext:aCtx];
			locationGroup.location_group_id = [NSNumber numberWithInt:[[serverData valueForKey:@"id"] intValue]];
		}
		// UPDATE properties for existing Object
		locationGroup.code                = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]];
		locationGroup.description_text    = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"description"]];
	}
	
	return locationGroup;
}

+ (Location_Group *)locationGroupWithLocationData:(NSDictionary *)locationData inCtx:(NSManagedObjectContext *)aCtx {
	Location_Group *locationGroup = nil;
	NSError  *error				  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location_Group" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"location_group_id = %@", [locationData valueForKey:@"location_group_id"]];
	
	// lastObject returns nil, if no data in db_handle
	locationGroup          = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!locationGroup) {
			// INSERT new Object (db_handle returns nil without an error)
			locationGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Location_Group" inManagedObjectContext:aCtx];
			locationGroup.location_group_id = [NSNumber numberWithInt:[[locationData valueForKey:@"location_group_id"]intValue]];
		}
		// UPDATE properties for existing Object
	}
	
	return locationGroup;
}

+ (NSArray  *)withPredicate:(NSPredicate *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
    return [Location_Group withPredicate:aPredicate sortDescriptors:nil inCtx:aCtx];
}

+ (NSArray  *)withPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray *locationGroups = nil;
	NSError  *error         = nil;
	
    //NSLog(@"Location SELECT FOR %@", [aPredicate predicateFormat]);
    
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	// db_handle.entity			= SQL-TABLE-Name
	db_handle.entity			= [NSEntityDescription entityForName:@"Location_Group" inManagedObjectContext:aCtx];
	// db_handle.predicate		= SQL-WHERE-Condition
	db_handle.predicate			= aPredicate;
	// db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	locationGroups              = [aCtx executeFetchRequest:db_handle error:&error];
	if (aPredicate) {
		if (!locationGroups || locationGroups.count == 0) {
			NSLog(@"Location_Group has no records for %@", [aPredicate predicateFormat]);
		}
	}
    
	return locationGroups;
}

@dynamic code;
@dynamic description_text;
@dynamic location_group_id;
@dynamic isLogisticsCenter;
@dynamic isExternalPartner;
@dynamic isLogicalStructureElement;
@dynamic location_id;

@end
