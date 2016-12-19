//
//  InventoryHead.m
//  StoreOnline
//
//  Created by iLutz on 02.08.12.
//
//

#import "InventoryHead.h"
#import "InventoryLine.h"


@implementation InventoryHead

+ (InventoryHead *)inventoryHeadWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	InventoryHead *inventoryHead = nil;
	NSError           *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"remoteInventoryID = %@",
                              [NSString stringWithFormat:@"%@", [serverData valueForKey:@"inventory_number"]]];
    db_handle.fetchBatchSize = 1;
    db_handle.includesSubentities = NO;
	
	// lastObject returns nil, if no data in db_handle
	inventoryHead           = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!inventoryHead) {
			// INSERT new Object (db_handle returns nil without an error)
			inventoryHead = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            inventoryHead.inventoryID = [NSUserDefaults nextInventoryId];
            inventoryHead.remoteInventoryID    = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"inventory_number"]];
		}
		// UPDATE properties for existing Object
        if (![serverData valueForKey:@"inventory_date"]) {
            inventoryHead.inventoryDate  = [NSDate date];
        } else {
            NSDate *date = [DPHDateFormatter dateFromString:[serverData valueForKey:@"inventory_date"]
                                              withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
            inventoryHead.inventoryDate = date;
        }
        inventoryHead.inventorySector  = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"inventory_sector"]];
        inventoryHead.inventoryState   = [NSNumber numberWithInt:[[serverData valueForKey:@"status"] intValue]];
        inventoryHead.transmissionDate = nil;
	}
	
	return inventoryHead;
}

+ (InventoryHead *)inventoryHeadWithRemoteInventoryID:(NSString *)remoteInventoryID inCtx:(NSManagedObjectContext *)aCtx {
	InventoryHead *inventoryHead = nil;
	NSError          *error     = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"remoteInventoryID = %@", remoteInventoryID];
	
	// lastObject returns nil, if no data in db_handle
	inventoryHead			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!inventoryHead) {
			// INSERT new Object (db_handle returns nil without an error)
			inventoryHead = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            inventoryHead.inventoryID = [NSUserDefaults nextInventoryId];
            inventoryHead.remoteInventoryID    = remoteInventoryID;
		}
		// UPDATE properties for existing Object
        inventoryHead.inventoryDate    = [NSDate date];
        inventoryHead.inventorySector  = @"123";
        inventoryHead.inventoryState   = [NSNumber numberWithInt:00];
        inventoryHead.transmissionDate = nil;
	}
	
	return inventoryHead;
}

+ (InventoryHead *)currentInventoryHeadInCtx:(NSManagedObjectContext *)aCtx {
    return [[self inventoryHeadsWithPredicate:[NSPredicate predicateWithFormat:@"inventoryState = 00"] sortDescriptors:nil inCtx:aCtx] lastObject];
}

+ (NSArray  *)inventoryHeadsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *inventoryHeads = nil;
	NSError  *error		 = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	inventoryHeads			   = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return inventoryHeads;
}

@dynamic inventoryDate;
@dynamic inventoryID;
@dynamic inventorySector;
@dynamic inventoryState;
@dynamic remoteInventoryID;
@dynamic transmissionDate;
@dynamic inventoryLine;

@end
