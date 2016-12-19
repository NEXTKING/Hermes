//
//  ArchiveOrderLine.m
//  StoreOnline
//
//  Created by Lutz  Thalmann on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArchiveOrderLine.h"
#import "ArchiveOrderHead.h"
#import "Item.h"
#import "User.h"


@implementation ArchiveOrderLine

+ (ArchiveOrderLine *)orderLineWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	ArchiveOrderLine *orderLine = nil;
	NSError          *error     = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"itemID = %@", [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]]];
	
	// lastObject returns nil, if no data in db_handle
	orderLine			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!orderLine) {
			// INSERT new Object (db_handle returns nil without an error)
			orderLine = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            orderLine.itemID       = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
            orderLine.user         = nil;
            orderLine.itemInserted = [NSDate date];
		}
		// UPDATE properties for existing Object
        orderLine.itemQTY     = [NSNumber numberWithLong:[[serverData valueForKey:@"qty"] longValue]];
        orderLine.itemUpdated = [NSDate date];
        if (!orderLine.item) {
            orderLine.item    = [Item managedObjectWithItemID:orderLine.itemID inCtx:aCtx];
        }
	}
	
	return orderLine;
}

+ (ArchiveOrderLine *)orderLineForOrderHead:(ArchiveOrderHead *)orderHead 
                                 withItemID:(NSString *)itemID 
                                    itemQTY:(NSNumber *)itemQTY 
                                     userID:(NSNumber *)userID 
                               templateName:(NSString *)templateName 
                     inCtx:(NSManagedObjectContext *)aCtx {
	ArchiveOrderLine *orderLine = nil;
	NSError          *error     = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"archiveOrderHead.order_id = %lld && itemID = %@", 
                              [orderHead.order_id longLongValue], itemID];
	
	// lastObject returns nil, if no data in db_handle
	orderLine			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!orderLine) {
			// INSERT new Object (db_handle returns nil without an error)
			orderLine = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            orderLine.itemID           = itemID;
            orderLine.archiveOrderHead = orderHead;
            orderLine.itemInserted     = [NSDate date];
            orderLine.templateName     = @"*NONE-©";
		}
		// UPDATE properties for existing Object
        orderLine.itemQTY     = itemQTY;
        orderLine.itemUpdated = [NSDate date];
        if (!orderLine.item) {
            orderLine.item    = [Item managedObjectWithItemID:orderLine.itemID inCtx:aCtx];
        }
        orderLine.user        = [User userID:userID forOrderLine:orderLine inCtx:aCtx];
        if (templateName && templateName.length > 0 && 
            (!orderLine.templateName || [orderLine.templateName isEqualToString:@"*NONE-©"])) {
            orderLine.templateName = templateName;
        }
	}
	
	return orderLine;
}

+ (NSUInteger )currentOrderQTYForItem:(NSString *)itemID inCtx:(NSManagedObjectContext *)aCtx {
    return  [((ArchiveOrderLine *)[[self orderLinesWithPredicate:
                                    [NSPredicate predicateWithFormat:@"archiveOrderHead.orderState = 00 && itemID = %@", itemID]
                                                 sortDescriptors:nil  inCtx:aCtx] lastObject]).itemQTY unsignedIntegerValue];
}

+ (NSArray  *)orderLinesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *orderLines = nil;
	NSError  *error		 = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	orderLines			   = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return orderLines;
}

+ (ArchiveOrderLine *)currentOrderLineInCtx:(NSManagedObjectContext *)aCtx { 
    return [[self orderLinesWithPredicate:[NSPredicate predicateWithFormat:@"archiveOrderHead.orderState = 00"] sortDescriptors:nil inCtx:aCtx] lastObject];
}

+ (ArchiveOrderLine *)previousOrderLineForItemID:(NSString *)itemID inCtx:(NSManagedObjectContext *)aCtx { 
    return [[self orderLinesWithPredicate:[NSPredicate predicateWithFormat:@"itemID = %@ && archiveOrderHead.orderState = 50", itemID]
                          sortDescriptors:[NSArray arrayWithObjects:
                                           [NSSortDescriptor sortDescriptorWithKey:@"archiveOrderHead.transmissionDate" ascending:YES],
                                           [NSSortDescriptor sortDescriptorWithKey:@"archiveOrderHead.orderDate"        ascending:YES], nil] 
                   inCtx:aCtx] lastObject];
}

+ (NSArray  *)currentOrderLinesInCtx:(NSManagedObjectContext *)aCtx { 
    return [self orderLinesWithPredicate:[NSPredicate predicateWithFormat:@"archiveOrderHead.orderState = 00"] sortDescriptors:nil inCtx:aCtx];
}

@dynamic itemID;
@dynamic itemInserted;
@dynamic itemQTY;
@dynamic itemUpdated;
@dynamic templateName;
@dynamic archiveOrderHead;
@dynamic item;
@dynamic user;

@end
