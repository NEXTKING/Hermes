//
//  TemplateOrderHead.m
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TemplateOrderHead.h"
#import "TemplateOrderLine.h"
#import "User.h"


@implementation TemplateOrderHead

+ (TemplateOrderHead *)templateHeadWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	TemplateOrderHead *templateHead = nil;
	NSError           *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"templateName = %@", [NSString stringWithFormat:@"%@", [serverData valueForKey:@"orderlist"]]];
    db_handle.fetchBatchSize = 1;
    db_handle.includesSubentities = NO;
	
	// lastObject returns nil, if no data in db_handle
	templateHead           = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!templateHead) {
			// INSERT new Object (db_handle returns nil without an error)
			templateHead = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            templateHead.template_id = [NSUserDefaults nextTemplateHeadId];
            templateHead.templateName = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"orderlist"]];
            templateHead.user         = nil;
		}
		// UPDATE properties for existing Object
        templateHead.templateDate = [DPHDateFormatter dateFromString:[serverData valueForKey:@"orderlistdate"]
                                                       withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
        if ([serverData valueForKey:@"orderliststate"]) {
            templateHead.templateState  = [NSNumber numberWithInt:[[serverData valueForKey:@"orderliststate"] intValue]];
        } else {
            templateHead.templateState  = [NSNumber numberWithInt:00];
        }
        if ([templateHead.templateState intValue] == 50 && 
            [serverData valueForKey:@"transmissiondate"]) {
            templateHead.transmissionDate = [DPHDateFormatter dateFromString:[serverData valueForKey:@"transmissiondate"]
                                                               withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
        } else if ([templateHead.templateState intValue] == 50) { 
            templateHead.transmissionDate = templateHead.templateDate;
        } else {
            templateHead.transmissionDate = nil;
        }
	}
	
	return templateHead;
}

+ (TemplateOrderHead *)templateHeadWithName:(NSString *)templateName clientData:(NSNumber *)userID inCtx:(NSManagedObjectContext *)aCtx {
	TemplateOrderHead *templateHead = nil;
	NSError           *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"templateName = %@", templateName];
	
	// lastObject returns nil, if no data in db_handle
	templateHead           = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!templateHead) {
			// INSERT new Object (db_handle returns nil without an error)
			templateHead = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            templateHead.template_id = [NSUserDefaults nextTemplateHeadId];
            if ([userID intValue] == -1) { 
                templateHead.isUserDomain = [NSNumber numberWithBool:NO];
            } else { 
                templateHead.isUserDomain = [NSNumber numberWithBool:YES];
            }
            templateHead.templateName          = templateName;
            templateHead.templateDate          = [NSDate date];
            templateHead.templateState         = [NSNumber numberWithInt:00];
            templateHead.templateValidFrom     = nil;
            templateHead.templateValidUntil    = nil;
            templateHead.templateDeliveryFrom  = nil;
            templateHead.templateDeliveryUntil = nil;
            templateHead.transmissionDate      = nil;
		}
		// UPDATE properties for existing Object
        templateHead.user = [User userID:userID forTemplateHead:templateHead inCtx:aCtx];
	}
	
	return templateHead;
}

+ (NSArray  *)templateHeadsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *templateHeads = nil;
	NSError  *error         = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	templateHeads          = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return templateHeads;
}

+ (TemplateOrderHead *)templateHeadFromName:(NSString *)templateName inCtx:(NSManagedObjectContext *)aCtx { 
    return [[self templateHeadsWithPredicate:[NSPredicate predicateWithFormat:@"templateName = %@", templateName] sortDescriptors:nil inCtx:aCtx] lastObject];
}

+ (BOOL )templateHeadWithName:(NSString *)templateName hasCurrentOrderInCtx:(NSManagedObjectContext *)aCtx { 
    if ([[self templateHeadsWithPredicate:[NSPredicate predicateWithFormat:@"templateName = %@ && "
                                           "(0 != SUBQUERY(templateOrderLine, $tl, "
                                           "(0 != SUBQUERY($tl.item.archiveOrderLine, $ol, $ol.archiveOrderHead.orderState == 00).@count)"
                                           ").@count)", templateName]
                          sortDescriptors:nil inCtx:aCtx] lastObject]) {
        return YES;
    }
    return NO;
}

+ (void)removeAllEmptyServerDomainTemplatesInCtx:(NSManagedObjectContext *)aCtx { 
    for (TemplateOrderHead *tmpTemplateHead in [NSArray arrayWithArray:
                                                [self templateHeadsWithPredicate:[NSPredicate predicateWithFormat:
                                                    @"isUserDomain = NO && templateOrderLine.@count = 0"]
                                                                 sortDescriptors:nil inCtx:aCtx]]) {
        [aCtx deleteObject:tmpTemplateHead];
    }
}

@dynamic isUserDomain;
@dynamic template_id;
@dynamic templateDate;
@dynamic templateName;
@dynamic templateState;
@dynamic templateValidFrom;
@dynamic templateValidUntil;
@dynamic transmissionDate;
@dynamic templateDeliveryFrom;
@dynamic templateDeliveryUntil;
@dynamic templateOrderLine;
@dynamic user;

@end
