//
//  ItemDescription.m
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemDescription.h"
#import "Item.h"
#import "Keyword.h"


@implementation ItemDescription

+ (ItemDescription *)itemDescriptionWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	ItemDescription *itemDescription = nil;
	NSError         *error = nil;
    
	// lastObject returns nil, if no data is found.
	itemDescription = [[aCtx executeFetchRequest:
                        [aCtx.persistentStoreCoordinator.managedObjectModel 
                         fetchRequestFromTemplateWithName:@"FetchItemDescriptionForDataImport" 
                         substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]], 
                                                 @"FRQitemID", 
                                                [[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]] uppercaseString],
                                                 @"FRQlocaleCode", nil]] 
                                                            error:&error] lastObject];    
	if (!error) {
		if (!itemDescription) {
			// INSERT new Object (db_handle returns nil without an error)
			itemDescription = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            itemDescription.itemID     = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
            itemDescription.localeCode = [[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]] uppercaseString];
		}
		// UPDATE properties for existing Object
        if ([serverData valueForKey:@"text"]) { 
            itemDescription.text       = [serverData valueForKey:@"text"];
        } else {
            itemDescription.text       = nil;
        }
        if (!itemDescription.item) {
            itemDescription.item       = [Item managedObjectWithItemID:itemDescription.itemID inCtx:aCtx];
        }
	}
	
	return itemDescription;
}

+ (NSArray *)itemDescriptionsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *itemDescriptions = nil;
	NSError  *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	itemDescriptions        = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return itemDescriptions;
}

@dynamic itemID;
@dynamic localeCode;
@dynamic text;
@dynamic item;
@dynamic descriptionKeywords;

@end
