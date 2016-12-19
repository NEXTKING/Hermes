//
//  ItemProductInformation.m
//  StoreOnline
//
//  Created by iLutz on 14.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemProductInformation.h"
#import "Item.h"
#import "Keyword.h"


@implementation ItemProductInformation

+ (ItemProductInformation *)itemProductInformationWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	ItemProductInformation *itemProductInformation = nil;
	NSError                *error = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"itemID = %@ && localeCode = %@", 
                              [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]],
                              [NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]];
    db_handle.fetchBatchSize = 1;
    db_handle.includesSubentities = NO;
	
	// lastObject returns nil, if no data in db_handle
	itemProductInformation = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!itemProductInformation) {
			// INSERT new Object (db_handle returns nil without an error)
			itemProductInformation = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            itemProductInformation.itemID     = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
            itemProductInformation.localeCode = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]];
		}
		// UPDATE properties for existing Object
        if ([serverData valueForKey:@"text"]) {
            itemProductInformation.text       = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]];
        } else {
            itemProductInformation.text       = nil;
        }
        if (!itemProductInformation.item) {
            itemProductInformation.item       = [Item managedObjectWithItemID:itemProductInformation.itemID inCtx:aCtx];
        }
	}
	
	return itemProductInformation;
}

+ (NSArray *)itemProductInformationsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *itemProductInformations = nil;
	NSError  *error                   = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	itemProductInformations = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return itemProductInformations;
}

@dynamic itemID;
@dynamic localeCode;
@dynamic text;
@dynamic item;
@dynamic productInformationKeywords;

@end
