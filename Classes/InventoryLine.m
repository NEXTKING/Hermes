//
//  InventoryLine.m
//  StoreOnline
//
//  Created by iLutz on 02.08.12.
//
//

#import "InventoryLine.h"
#import "InventoryHead.h"
#import "Item.h"
#import "User.h"


@implementation InventoryLine

+ (InventoryLine *)inventoryLineForInventoryHead:(InventoryHead *)inventoryHead
                                      withItemID:(NSString *)itemID
                                         barCode:(NSString *)barCode
                                         itemQTY:(NSNumber *)itemQTY
                                atPositionNumber:(NSNumber *)positionNumber
                                            task:(NSString *)task
                                          userID:(NSNumber *)userID
                          inCtx:(NSManagedObjectContext *)aCtx {
	InventoryLine *inventoryLine = nil;
	NSError           *error     = nil;
	
	if (positionNumber) {
        NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
        // db_handle.entity    = SQL-TABLE-Name
        db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
        // db_handle.predicate = SQL-WHERE-Condition
        db_handle.predicate    = [NSPredicate predicateWithFormat:@"inventoryHead.inventoryID = %lld && positionNumber = %lld",
                                  [inventoryHead.inventoryID longLongValue], [positionNumber longLongValue]];
        db_handle.fetchBatchSize = 1;
        db_handle.includesSubentities = NO;
        
        // lastObject returns nil, if no data in db_handle
        inventoryLine           = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
    }
	
	if (!error) {
        if (!inventoryLine) {
			// INSERT new Object (db_handle returns nil without an error)
			inventoryLine = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            inventoryLine.positionNumber = [NSUserDefaults nextInventoryPositionNumber];
            inventoryLine.itemID              = itemID;
            inventoryLine.itemBarCode         = barCode;
            inventoryLine.positionStatus      = [NSNumber numberWithInt:00];
            inventoryLine.positionInserted    = [NSDate date];
            inventoryLine.inventoryHead       = inventoryHead;
            inventoryLine.user                = [User userID:userID forInventoryLine:inventoryLine inCtx:aCtx];
        }
		// UPDATE properties for existing Object
        if (!inventoryLine.item) {
            inventoryLine.item    = [Item managedObjectWithItemID:inventoryLine.itemID inCtx:aCtx];
        }
        if (![task isEqualToString:@"UPDATE"] &&
            [inventoryLine.positionNumber longValue] == [[[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentInventoryPositionNumberKey] longValue]) {
            // new inventory line or same "old" inventory line i.e. after the next scan
            inventoryLine.itemQTY = itemQTY;
        } else {
            // old inventory line with updates
            if (![inventoryLine.itemQTY isEqualToNumber:itemQTY]) {
                // save the old itemQTY
                inventoryLine.itemQTYFixed = inventoryLine.itemQTY;
                if (!inventoryLine.itemQTYOriginal) {
                    // save the original itemQTY
                    inventoryLine.itemQTYOriginal = inventoryLine.itemQTYFixed;
                }
                // store the new itemQTY
                inventoryLine.itemQTY             = itemQTY;
                inventoryLine.positionUpdated     = [NSDate date];
                inventoryLine.correctionUser      = [User userID:userID forInventoryLine:inventoryLine inCtx:aCtx];
                inventoryLine.positionStatus      = [NSNumber numberWithInt:00];  // reset the status    because the line could already be transmitted
                inventoryLine.positionTransmitted = nil;                          // reset the timestamp because the line could already be transmitted
            }
        }
	}
	return inventoryLine;
}

+ (InventoryLine *)currentInventoryLineInCtx:(NSManagedObjectContext *)aCtx {
    return [[self inventoryLinesWithPredicate:[NSPredicate predicateWithFormat:@"inventoryHead.inventoryID = %lld",
                                              [[InventoryHead currentInventoryHeadInCtx:aCtx].inventoryID longLongValue]]
                              sortDescriptors:[NSArray arrayWithObject:
                                               [NSSortDescriptor sortDescriptorWithKey:@"positionNumber" ascending:YES]]
                      inCtx:aCtx] lastObject];
}

+ (NSUInteger )currentInventoryQTYForPositionNumber:(NSNumber *)positionNumber
                                      inventoryHead:(InventoryHead *)inventoryHead
                             inCtx:(NSManagedObjectContext *)aCtx {
    return [((InventoryLine *)[[self inventoryLinesWithPredicate:[NSPredicate predicateWithFormat:@"inventoryHead.inventoryID = %lld && positionNumber = %lld",
                                               [inventoryHead.inventoryID longLongValue], [positionNumber longLongValue]] sortDescriptors:nil
                       inCtx:aCtx] lastObject]).itemQTY unsignedIntegerValue];
}

+ (NSArray  *)inventoryLinesToSyncInCtx:(NSManagedObjectContext *)aCtx {
    return [self inventoryLinesWithPredicate:[NSPredicate predicateWithFormat:@"inventoryHead.inventoryID = %lld && positionStatus = 00",
                                              [[InventoryHead currentInventoryHeadInCtx:aCtx].inventoryID longLongValue]]
                             sortDescriptors:[NSArray arrayWithObjects:
                                              [NSSortDescriptor sortDescriptorWithKey:@"positionUpdated" ascending:NO],
                                              [NSSortDescriptor sortDescriptorWithKey:@"positionNumber" ascending:YES],
                                              nil]
                      inCtx:aCtx];
}

+ (NSArray  *)inventoryLinesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *inventoryLines = nil;
	NSError  *error          = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	// lastObject returns nil, if no data in db_handle
	inventoryLines          = [aCtx executeFetchRequest:db_handle error:&error];

	return inventoryLines;
}

@dynamic itemBarCode;
@dynamic itemID;
@dynamic itemQTY;
@dynamic itemQTYFixed;
@dynamic itemQTYOriginal;
@dynamic positionInserted;
@dynamic positionNumber;
@dynamic positionStatus;
@dynamic positionTransmitted;
@dynamic positionUpdated;
@dynamic correctionUser;
@dynamic inventoryHead;
@dynamic item;
@dynamic user;

@end
