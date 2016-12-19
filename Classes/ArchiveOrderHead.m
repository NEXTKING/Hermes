//
//  ArchiveOrderHead.m
//  StoreOnline
//
//  Created by iLutz on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArchiveOrderHead.h"
#import "ArchiveOrderLine.h"
#import "User.h"
#import "Location.h"


@implementation ArchiveOrderHead

+ (ArchiveOrderHead *)orderHeadWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	ArchiveOrderHead *orderHead = nil;
	NSError          *error     = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"remoteOrderID = %@", [NSString stringWithFormat:@"%@", [serverData valueForKey:@"id"]]];
	
	// lastObject returns nil, if no data in db_handle
	orderHead			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!orderHead) {
			// INSERT new Object (db_handle returns nil without an error)
			orderHead = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            orderHead.order_id = [NSUserDefaults nextOrderHeadId];
            orderHead.remoteOrderID = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"id"]];
            orderHead.user          = nil;
		}
		// UPDATE properties for existing Object
        orderHead.orderDate       = [DPHDateFormatter dateFromString:[serverData valueForKey:@"orderdate"]
                                                       withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
        if ([serverData valueForKey:@"orderstate"]) {
            orderHead.orderState  = [NSNumber numberWithInt:[[serverData valueForKey:@"orderstate"] intValue]];
        } else {
            orderHead.orderState  = [NSNumber numberWithInt:00];
        }
        if ([orderHead.orderState intValue] == 50 && 
            [serverData valueForKey:@"transmissiondate"]) {
            orderHead.transmissionDate = [DPHDateFormatter dateFromString:[serverData valueForKey:@"transmissiondate"]
                                                            withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
        } else if ([orderHead.orderState intValue] == 50) { 
            orderHead.transmissionDate = orderHead.orderDate;
        } else {
            orderHead.transmissionDate = nil;
        }
	}
	
	return orderHead;
}

+ (ArchiveOrderHead *)orderHeadWithClientData:(NSNumber *)userID inCtx:(NSManagedObjectContext *)aCtx {
	ArchiveOrderHead *orderHead = nil;
	NSError          *error     = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"orderState = 00"];
	
	// lastObject returns nil, if no data in db_handle
	orderHead			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!orderHead) {
			// INSERT new Object (db_handle returns nil without an error)
			orderHead = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            orderHead.order_id = [NSUserDefaults nextOrderHeadId];
            orderHead.orderDate        = [NSDate date];
            orderHead.orderState       = [NSNumber numberWithInt:00];
            orderHead.remoteOrderID    = nil;
            orderHead.transmissionDate = nil;
		}
		// UPDATE properties for existing Object
        orderHead.user       = [User userID:userID forOrderHead:orderHead inCtx:aCtx];
	}
	
	return orderHead;
}

+ (ArchiveOrderHead *)orderHeadWithClientData:(NSNumber *)userID forStore:(NSNumber *)storeID inCtx:(NSManagedObjectContext *)aCtx {
	ArchiveOrderHead *orderHead = nil;
	NSError          *error     = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"orderState = 00"];
	
	// lastObject returns nil, if no data in db_handle
	orderHead			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!orderHead) {
			// INSERT new Object (db_handle returns nil without an error)
			orderHead = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            orderHead.order_id = [NSUserDefaults nextOrderHeadId];
            orderHead.orderDate        = [NSDate date];
            orderHead.orderState       = [NSNumber numberWithInt:00];
            orderHead.remoteOrderID    = nil;
            orderHead.transmissionDate = nil;
            orderHead.store_id         = storeID;
		}
		// UPDATE properties for existing Object
        orderHead.user       = [User userID:userID forOrderHead:orderHead inCtx:aCtx];
	}
	
	return orderHead;
}

+ (ArchiveOrderHead *)orderHeadWithClientData:(NSNumber *)userID forLocation:(Location *)location inCtx:(NSManagedObjectContext *)aCtx {
	ArchiveOrderHead *orderHead = nil;
	NSError          *error     = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"orderState = 00"];
	
	// lastObject returns nil, if no data in db_handle
	orderHead			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!orderHead) {
			// INSERT new Object (db_handle returns nil without an error)
			orderHead = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            orderHead.order_id = [NSUserDefaults nextOrderHeadId];
            orderHead.orderDate        = [NSDate date];
            orderHead.orderState       = [NSNumber numberWithInt:00];
            orderHead.remoteOrderID    = nil;
            orderHead.transmissionDate = nil;
            orderHead.store_id         = [NSNumber numberWithInt:(0 - [location.location_id intValue])];
		}
		// UPDATE properties for existing Object
        orderHead.user       = [User userID:userID forOrderHead:orderHead inCtx:aCtx];
	}
	
	return orderHead;
}

+ (ArchiveOrderHead *)subsetOrderHeadForOrderHead:(ArchiveOrderHead *)orderHead withOrderLines:(NSArray *)orderLines {
    ArchiveOrderHead *subsetOrderHead = nil;
    if (orderHead && orderLines && orderLines.count != 0 && [[orderLines objectAtIndex:0] isKindOfClass:[ArchiveOrderLine class]]) { 
        // INSERT new Object (db_handle returns nil without an error)
        subsetOrderHead = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:orderHead.managedObjectContext];
        subsetOrderHead.order_id = [NSUserDefaults nextOrderHeadId];
        subsetOrderHead.orderDate        = orderHead.orderDate;
        subsetOrderHead.orderState       = [NSNumber numberWithInt:05];
        subsetOrderHead.remoteOrderID    = orderHead.remoteOrderID;
        subsetOrderHead.transmissionDate = nil;
        subsetOrderHead.user             = orderHead.user;
        for (ArchiveOrderLine *tmporderLine in orderLines) {
            tmporderLine.archiveOrderHead = subsetOrderHead;
        }
    }
    
    return subsetOrderHead;
}

+ (NSArray  *)orderHeadsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *orderHeads = nil;
	NSError  *error		 = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	orderHeads			   = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return orderHeads;
}

+ (ArchiveOrderHead *)currentOrderHeadInCtx:(NSManagedObjectContext *)aCtx { 
    return [[self orderHeadsWithPredicate:[NSPredicate predicateWithFormat:@"orderState = 00"] sortDescriptors:nil inCtx:aCtx] lastObject];
}

+ (NSArray *)pendingOrderHeadsToSyncInCtx:(NSManagedObjectContext *)aCtx {
    return [self orderHeadsWithPredicate:[NSPredicate predicateWithFormat:@"orderState = 40"]
                         sortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order_id" ascending:YES], nil] inCtx:aCtx];
}

@dynamic deliveryDate;
@dynamic order_id;
@dynamic orderDate;
@dynamic orderState;
@dynamic remoteOrderID;
@dynamic transmissionDate;
@dynamic store_id;
@dynamic archiveOrderLine;
@dynamic user;

@end
