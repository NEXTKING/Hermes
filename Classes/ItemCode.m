//
//  ItemCode.m
//  StoreOnline
//
//  Created by iLutz on 02.08.12.
//
//

#import "ItemCode.h"
#import "Item.h"


@implementation ItemCode

+ (ItemCode *)itemCodeWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	ItemCode *itemCode = nil;
	NSError  *error    = nil;
	 
    if ([serverData valueForKey:@"distinction"]) {
        // lastObject returns nil, if no data is found.
        itemCode = [[aCtx executeFetchRequest:
                     [aCtx.persistentStoreCoordinator.managedObjectModel
                      fetchRequestFromTemplateWithName:@"FetchItemCodeForDataImportWithDistinction"
                      substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]],
                                             @"FRQcode",
                                             [NSString stringWithFormat:@"%@", [serverData valueForKey:@"distinction"]],
                                             @"FRQdistinction", nil]]
                                                         error:&error] lastObject];
    } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_Branding"] isEqualToString:@"Heinemann"]) {
        // lastObject returns nil, if no data is found.
        itemCode = [[aCtx executeFetchRequest:
                     [aCtx.persistentStoreCoordinator.managedObjectModel
                      fetchRequestFromTemplateWithName:@"FetchItemCodeForDataImportWithDistinction"
                      substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]],
                                             @"FRQcode",
                                             [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]],
                                             @"FRQdistinction", nil]]
                                                         error:&error] lastObject];
    } else {
        // lastObject returns nil, if no data is found.
        itemCode = [[aCtx executeFetchRequest:
                     [aCtx.persistentStoreCoordinator.managedObjectModel
                      fetchRequestFromTemplateWithName:@"FetchItemCodeForDataImport"
                      substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]],
                                             @"FRQcode", nil]]
                                                         error:&error] lastObject];
    }

	if (!error) {
		if (!itemCode) {
			// INSERT new Object (db_handle returns nil without an error)
			itemCode      = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            itemCode.code = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]];
            if ([serverData valueForKey:@"distinction"]) {
                itemCode.distinction = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"distinction"]];
            } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_Branding"] isEqualToString:@"Heinemann"]) {
                itemCode.distinction = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
            } else {
                itemCode.distinction = nil;
            }
		}
		// UPDATE properties for existing Object
        if ([serverData valueForKey:@"itemid"]) {
            NSString *tmpItemID = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
            if (itemCode.itemID && ![itemCode.itemID isEqualToString:tmpItemID]) {
                itemCode.item = nil;
            }
            itemCode.itemID = tmpItemID;
        } else {
            itemCode.itemID = @"???";
        }
        if ([serverData valueForKey:@"itemqty"]) {
            itemCode.itemQTY = [NSNumber numberWithInt:[[serverData valueForKey:@"itemqty"] intValue]];
        } else {
            itemCode.itemQTY = [NSNumber numberWithInt:01];
        }
        if (!itemCode.item) {
            itemCode.item = [Item managedObjectWithItemID:itemCode.itemID inCtx:aCtx];
        }
	}
    
	return itemCode;
}

+ (Item *)itemForCode:(NSString *)code inCtx:(NSManagedObjectContext *)aCtx {
    if (code) {
        return ((ItemCode *)[[self itemCodesWithPredicate:[NSPredicate predicateWithFormat:@"code = %@", code] sortDescriptors:nil inCtx:aCtx] lastObject]).item;
    }
    return nil;
}

+ (NSInteger )itemCountForCode:(NSString *)code inCtx:(NSManagedObjectContext *)aCtx {
    if (code) {
        return [aCtx countForFetchRequest:
                [aCtx.persistentStoreCoordinator.managedObjectModel
                 fetchRequestFromTemplateWithName:@"FetchItemCodeForDataImport"
                            substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [NSString stringWithFormat:@"%@", code],
                                                   @"FRQcode", nil]] error:nil];
    }
    return 0;
}

+ (NSString *)salesUnitItemCodeForItemID:(NSString *)itemID inCtx:(NSManagedObjectContext *)aCtx {
    if (itemID) {
        return ((ItemCode *)[[self itemCodesWithPredicate:[NSPredicate predicateWithFormat:@"itemID = %@ && itemQTY = 1", itemID]
                                          sortDescriptors:nil inCtx:aCtx] lastObject]).code;
    }
    return nil;
}

+ (NSArray *)itemCodesWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *itemCodes = nil;
	NSError  *error     = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	itemCodes              = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return itemCodes;
}

@dynamic code;
@dynamic distinction;
@dynamic itemID;
@dynamic itemQTY;
@dynamic item;

@end
