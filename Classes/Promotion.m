//
//  Promotion.m
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Promotion.h"
#import "Item.h"


@implementation Promotion

+ (Promotion *)promotionWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Promotion *promotion = nil;
	NSError         *error = nil;
    
    NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
    // db_handle.entity    = SQL-TABLE-Name
    db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
    // db_handle.predicate = SQL-WHERE-Condition
    db_handle.predicate    =  [NSPredicate predicateWithFormat:@"itemID = %@", [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]]];
    
    // lastObject returns nil, if no data in db_handle
    promotion        = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
    
    if (!error) {
        if (!promotion) {
            // INSERT new Object (db_handle returns nil without an error)
            promotion = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            promotion.itemID = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
        }
        // UPDATE properties for existing Object        faq.localeCode = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]];
        if (!promotion.item) {
            promotion.item = [Item managedObjectWithItemID:promotion.itemID inCtx:aCtx];
        }
    }
	
	return promotion;
}

+ (NSArray *)promotionWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *promotion    = nil;
	NSError  *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	promotion        = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return promotion;
}

@dynamic itemID;
@dynamic item;

@end
