//
//  BasketAnalysis.m
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BasketAnalysis.h"
#import "Item.h"


@implementation BasketAnalysis


+ (BasketAnalysis *)basketanalysisWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	BasketAnalysis *basketanalysis = nil;
	NSError         *error = nil;
    // If-Abfrage, ob die Schnittstelle a) die Spalte überhaupt hat und b) in der Spalte überhaupt einen Inhalt
    if ([serverData valueForKey:@"itemid"]  && [serverData valueForKey:@"bundleitemid"]   &&
        [[NSString stringWithString:[serverData valueForKey:@"itemid"]]       length] > 0 &&
        [[NSString stringWithString:[serverData valueForKey:@"bundleitemid"]] length] > 0) { 
        NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
        // db_handle.entity    = SQL-TABLE-Name
        db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
        // db_handle.predicate = SQL-WHERE-Condition
        db_handle.predicate    =  [NSPredicate predicateWithFormat:@"itemID = %@ && analyzedItemID = %@", 
                                   [NSString stringWithString:[serverData valueForKey:@"itemid"]], 
                                   [NSString stringWithString:[serverData valueForKey:@"bundleitemid"]]];
        
        // lastObject returns nil, if no data in db_handle
        basketanalysis        = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
        
        if (!error) {
            if (!basketanalysis) {
                // INSERT new Object (db_handle returns nil without an error)
                basketanalysis = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
                basketanalysis.itemID         = [NSString stringWithString:[serverData valueForKey:@"itemid"]];
                basketanalysis.analyzedItemID = [NSString stringWithString:[serverData valueForKey:@"bundleitemid"]];
            }
            // UPDATE properties for existing Object
            if (!basketanalysis.item) { 
                basketanalysis.item = [Item managedObjectWithItemID:basketanalysis.itemID inCtx:aCtx];
            }
            if (!basketanalysis.analyzedItem) {
                basketanalysis.analyzedItem = [Item managedObjectWithItemID:basketanalysis.analyzedItemID 
                                                     inCtx:aCtx];
            }
                
        }
    }
	
	return basketanalysis;
}

+ (NSArray *)basketanalysisWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *basketanalysis = nil;
	NSError  *error          = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	basketanalysis        = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return basketanalysis;
}

@dynamic itemID;
@dynamic analyzedItemID;
@dynamic item;
@dynamic analyzedItem;

@end
