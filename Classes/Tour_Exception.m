//
//  Tour_Exception.m
//  Hermes
//
//  Created by iLutz on 15.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tour_Exception.h"
#import "Location.h"


@implementation Tour_Exception

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"Tour_Exception", @"Tour_Exception");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfTourExceptions";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (Tour_Exception *)fromServerData:(NSDictionary *)serverData       inCtx:(NSManagedObjectContext *)aCtx {
	Tour_Exception	  *tour_exception	  = nil;
	NSError           *error              = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Tour_Exception" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"tour_exception_id = %i", [[serverData valueForKey:@"id"]intValue]];
	
	// lastObject returns nil, if no data in db_handle
	tour_exception				= [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!tour_exception) {
			// INSERT new Object (db_handle returns nil without an error)
			tour_exception                   = [NSEntityDescription insertNewObjectForEntityForName:@"Tour_Exception" inManagedObjectContext:aCtx];
            tour_exception.tour_exception_id = [NSNumber numberWithInt:[[serverData valueForKey:@"id"]intValue]];
		}
		// UPDATE properties for existing Object
        id fromDateServerValue = [serverData valueForKey:@"fromdate"];
        if (fromDateServerValue) {
            if ([fromDateServerValue isKindOfClass:[NSDate class]]) {
                tour_exception.from_date = fromDateServerValue;
            } else {
                tour_exception.from_date = [DPHDateFormatter dateFromString:fromDateServerValue
                                                              withDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle locale:de_CH_Locale()];
            }
        } else {
            tour_exception.from_date = nil;
        }
        id toDateServerValue = [serverData valueForKey:@"todate"];
        if (toDateServerValue) {
            if ([toDateServerValue isKindOfClass:[NSDate class]]) {
                tour_exception.to_date = toDateServerValue;
            } else {
                tour_exception.to_date = [DPHDateFormatter dateFromString:toDateServerValue
                                                            withDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle locale:de_CH_Locale()];
            }
        } else {
            tour_exception.to_date = nil;
        }
        if ([serverData valueForKey:@"text"]) {     
            tour_exception.tour_exception_reason = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]];
        } else {
            tour_exception.tour_exception_reason = nil;
        }  
        tour_exception.location_id		        = [Location      locationWithTour_Exception:serverData inCtx:aCtx];
	}
	
	return tour_exception;
}

+ (Tour_Exception *)todaysTourExceptionForLocation:(Location *)aLocation { 
    return [[self tour_ExceptionWithPredicate:[NSPredicate predicateWithFormat:
                                               @"location_id.location_id = %i AND (%K <= %@) AND (%K >= %@)",
                                               [aLocation.location_id intValue], @"from_date", [NSDate date], @"to_date", [NSDate date]]
                              sortDescriptors:nil  inCtx:aLocation.managedObjectContext] lastObject];
}

+ (NSArray  *)tour_ExceptionWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *tour_exception = nil;
	NSError  *error	= nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Tour_Exception" inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	tour_exception				   = [aCtx executeFetchRequest:db_handle error:&error];
	
	return tour_exception;
}

@dynamic to_date;
@dynamic tour_exception_id;
@dynamic from_date;
@dynamic tour_exception_reason;
@dynamic location_id;

@end