//
//  Store.m
//  Hermes
//
//  Created by Lutz  Thalmann on 05.01.12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Store.h"


@implementation Store

+ (Store *)storeWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Store       *store = nil;
	NSError     *error = nil;
    NSString    *tmpID = [serverData valueForKey:@"storeid"];
	
    if (tmpID) {
        if ([tmpID hasPrefix:@"-"] && [tmpID hasSuffix:@"-"]) {
            tmpID = [tmpID substringToIndex:(tmpID.length - 1)];
        }
        
        NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
        // db_handle.entity    = SQL-TABLE-Name
        db_handle.entity       = [NSEntityDescription entityForName:@"Store" inManagedObjectContext:aCtx];
        // db_handle.predicate = SQL-WHERE-Condition
        db_handle.predicate    = [NSPredicate predicateWithFormat:@"store_id = %i", [tmpID intValue]];
        
        // lastObject returns nil, if no data in db_handle
        store                  = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
        
        if (!error) {
            if (!store) {
                // INSERT new Object (db_handle returns nil without an error)
                store = [NSEntityDescription insertNewObjectForEntityForName:@"Store" inManagedObjectContext:aCtx];
                store.store_id    = [NSNumber numberWithInt:[tmpID intValue]];
            }
            // UPDATE properties for existing Object
            if ([serverData valueForKey:@"name"]) {
                store.storeName   = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"name"]];
            } else {
                store.storeName   = nil;
            }
            if ([serverData valueForKey:@"country_code"]) {
                store.countryCode = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"country_code"]];
            } else {
                store.countryCode = nil;
            }
            if ([serverData valueForKey:@"city"]) {
                store.city        = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"city"]];
            } else {
                store.city        = nil;
            }
            if ([serverData valueForKey:@"street"]) {
                store.street      = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"street"]];
            } else {
                store.street      = nil;
            }
            if ([serverData valueForKey:@"state"]) {
                store.state       = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"state"]];
            } else {
                store.state       = nil;
            }
            if ([serverData valueForKey:@"lang"]) {
                store.localeCode  = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]];
            } else {
                store.localeCode  = nil;
            }
            if ([serverData valueForKey:@"associatedlocation"]) {
                store.associatedLocation = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"associatedlocation"]];
            } else {
                store.associatedLocation = nil;
            }
        }
    }
	
	return store;
}

+ (Store   *)storeID:(NSNumber *)storeID inCtx:(NSManagedObjectContext *)aCtx {
	Store       *store = nil;
	NSError     *error = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Store" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"store_id = %i", [storeID intValue]];
	
	// lastObject returns nil, if no data in db_handle
	store                  = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
    
    return store;
}

+ (NSArray *)storesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *stores = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Store" inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	stores                 = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return stores;
}

@dynamic city;
@dynamic countryCode;
@dynamic localeCode;
@dynamic state;
@dynamic store_id;
@dynamic storeName;
@dynamic street;
@dynamic accountsReceivableNumber;
@dynamic accountsPayableNumber;
@dynamic associatedLocation;

@end
