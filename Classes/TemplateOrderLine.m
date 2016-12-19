//
//  TemplateOrderLine.m
//  StoreOnline
//
//  Created by iLutz on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TemplateOrderLine.h"
#import "TemplateOrderHead.h"
#import "Item.h"
#import "User.h"


@implementation TemplateOrderLine

+ (TemplateOrderLine *)templateLineWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	TemplateOrderLine *templateLine = nil;
	NSError           *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"itemID = %@", [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]]];
	
	// lastObject returns nil, if no data in db_handle
	templateLine           = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!templateLine) {
			// INSERT new Object (db_handle returns nil without an error)
			templateLine = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            templateLine.itemID       = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
            templateLine.user         = nil;
            templateLine.itemInserted = [NSDate date];
		}
		// UPDATE properties for existing Object
        templateLine.itemQTY     = [NSNumber numberWithLong:[[serverData valueForKey:@"qty"] longValue]];
        templateLine.itemUpdated = [NSDate date];
        if (!templateLine.item) {
            templateLine.item    = [Item managedObjectWithItemID:templateLine.itemID inCtx:aCtx];
        }
	}
	
	return templateLine;
}

+ (TemplateOrderLine *)templateLineForTemplateHead:(TemplateOrderHead *)templateHead 
                                        withItemID:(NSString *)itemID 
                                           itemQTY:(NSNumber *)itemQTY 
                                            userID:(NSNumber *)userID  
                            inCtx:(NSManagedObjectContext *)aCtx {
	TemplateOrderLine *templateLine = nil;
	NSError           *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"templateOrderHead.template_id = %lld && itemID = %@", 
                              [templateHead.template_id longLongValue], itemID];
    db_handle.fetchBatchSize = 1;
    db_handle.includesSubentities = NO;
	
	// lastObject returns nil, if no data in db_handle
	templateLine           = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!templateLine) {
			// INSERT new Object (db_handle returns nil without an error)
			templateLine = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            templateLine.itemID            = itemID;
            templateLine.templateOrderHead = templateHead;
            templateLine.itemInserted      = [NSDate date];
		}
		// UPDATE properties for existing Object
        templateLine.itemQTY     = itemQTY;
        templateLine.itemUpdated = [NSDate date];
        if (!templateLine.item) {
            templateLine.item    = [Item managedObjectWithItemID:templateLine.itemID inCtx:aCtx];
        }
        templateLine.user        = [User userID:userID forTemplateLine:templateLine inCtx:aCtx];
	}
	
	return templateLine;
}

+ (TemplateOrderLine *)templateLineForItemID:(NSString *)itemID inTemplate:(TemplateOrderHead *)templateHead {
    TemplateOrderLine *templateLine = nil;
	NSError           *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:templateHead.managedObjectContext];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"templateOrderHead.template_id = %lld && itemID = %@", 
                              [templateHead.template_id longLongValue], itemID];
    db_handle.fetchBatchSize = 1;
    db_handle.includesSubentities = NO;
	
	// lastObject returns nil, if no data in db_handle
	templateLine           = [[templateHead.managedObjectContext executeFetchRequest:db_handle error:&error] lastObject];
		
	return templateLine;
}

+ (NSUInteger )currentTemplateQTYForItem:(NSString *)itemID templateHead:(TemplateOrderHead*)templateHead inCtx:(NSManagedObjectContext *)aCtx {
    return  [((TemplateOrderLine *)[[self templateLinesWithPredicate:
                                     [NSPredicate predicateWithFormat:@"templateOrderHead.template_id = %lld && itemID = %@", 
                                                                      [templateHead.template_id longLongValue], itemID] 
                                                     sortDescriptors:nil inCtx:aCtx] lastObject]).itemQTY unsignedIntegerValue];
}

+ (NSArray  *)templateLinesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *templateLines = nil;
	NSError  *error         = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	templateLines          = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return templateLines;
}

@dynamic infoText;
@dynamic itemID;
@dynamic itemInserted;
@dynamic itemQTY;
@dynamic itemUpdated;
@dynamic sortValue;
@dynamic item;
@dynamic templateOrderHead;
@dynamic user;

@end
