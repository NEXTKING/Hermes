//
//  Hitlist.m
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Hitlist.h"
#import "Item.h"


@implementation Hitlist

+ (Hitlist *)hitlistWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Hitlist *hitlist = nil;
	NSError *error   = nil;
	
    // If-Abfrage, ob die Schnittstelle a) die Spalte überhaupt hat und b) in der Spalte überhaupt einen Inhalt 
    NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
    // db_handle.entity    = SQL-TABLE-Name
    db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
    // db_handle.predicate = SQL-WHERE-Condition
    db_handle.predicate    = [NSPredicate predicateWithFormat:@"item.itemID = %@", 
                              [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]]];
    
    // lastObject returns nil, if no data in db_handle
    hitlist        = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
    
    if (!error) {
        if (!hitlist) {
            // INSERT new Object (db_handle returns nil without an error)
            hitlist = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) 
                                                    inManagedObjectContext:aCtx];
            hitlist.item = [Item managedObjectWithItemID:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]] inCtx:aCtx];
        }
        if (![serverData valueForKey:@"hitlistpositionno"] || 
            [[serverData valueForKey:@"hitlistpositionno"] intValue] == 0) {
            [aCtx deleteObject:hitlist];
        } else {
            // UPDATE properties for existing Object
            hitlist.positionNumber = [NSNumber numberWithInt:
                                      [[serverData valueForKey:@"hitlistpositionno"] intValue] ];
            hitlist.productGroup   = [NSString stringWithString:[serverData valueForKey:@"productgroup"]];
        }
    }
    
	return hitlist;
}

+ (NSArray *)hitlistWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *hitlist = nil;
	NSError  *error   = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	hitlist        = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return hitlist;
}

@dynamic productGroup;
@dynamic positionNumber;
@dynamic item;

@end
