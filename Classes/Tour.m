// 
//  Tour.m
//  Hermes
//
//  Created by Lutz  Thalmann on 07.02.11.
//  Updated by Lutz  Thalmann on 24.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Tour.h"

#import "Departure.h"
#import "Transport.h"

#import "DSPF_Error.h"

NSString * const TourTaskLoadingOnly = @"loading only";
NSString * const TourTaskNormalDrive = @"normal drive";
NSString * const TourTaskAdjustingOnly = @"adjusting only";
NSString * const TourTaskTourAbbruch = @"Tourabbruch";

@implementation Tour

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"MESSAGE_024", @"Tours");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfTours";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    for (Transport *tmpTourTransport in [NSArray arrayWithArray:[Transport withPredicate:
                                                                 [NSPredicate predicateWithFormat:
                                                                  @"(trace_type_id.code = %@ OR trace_type_id.code = %@ OR trace_type_id.trace_type_id >= 80) && "
                                                                  "(0 == SUBQUERY(trace_log_id, $l, $l.trace_log_id != 0).@count)",
                                                                  @"UNLOAD", @"UNTOUCHED"] inCtx:ctx]])
    {
        [ctx deleteObject:tmpTourTransport];
    }
    NSString *obsolete_code_L1 = @"";
    for (Tour *obsolete in [NSArray arrayWithArray:[Tour withPredicate:[NSPredicate predicateWithFormat:@"transport_id.@count = 0"]
                                                       sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"code"    ascending:YES],
                                                                         [NSSortDescriptor sortDescriptorWithKey:@"tour_id" ascending:NO]]
                                                                      inCtx:ctx]])
    {
        if (!(PFTourTypeSupported(@"1X1", @"1XX", nil) && ![NSUserDefaults isRunningWithTourAdjustment]) &&
            !PFBrandingSupported(BrandingCCC_Group, BrandingBiopartner, nil) &&
            ![obsolete.code isEqualToString:obsolete_code_L1]) {
            obsolete_code_L1 = [NSString stringWithString:obsolete.code];
        } else {
            [ctx deleteObject:obsolete];
        }
    }
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        for (Transport_Group *unchained in [NSArray arrayWithArray:[Transport_Group withPredicate:
                                                                    [NSPredicate predicateWithFormat:@"transport_id.@count = 0"] inCtx:ctx]])
        {
            [ctx deleteObject:unchained];
        }
    }
}

+ (Tour *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Tour	  *tour	  = nil;
	NSError	  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Tour class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [Tour withCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]]];
	
	// lastObject returns nil, if no data in db_handle
	tour				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!tour) {
			// INSERT new Object (db_handle returns nil without an error)
			tour      = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Tour class]) inManagedObjectContext:aCtx];
            tour.code = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]];
		}
		// UPDATE properties for existing Object
        tour.tour_id          = [NSNumber numberWithInt:[[serverData valueForKey:@"id"] intValue]];
		tour.description_text = [serverData stringForKey:@"description"];
		tour.device_udid	  = [serverData stringForKey:@"sn"];
        NSDateFormatter *dateFMT  = [[NSDateFormatter alloc] init];
        [dateFMT setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
        if ([serverData valueForKey:@"valid_from"]) {
            tour.validFrom = [dateFMT dateFromString:[serverData valueForKey:@"valid_from"]];
        } else {
            tour.validFrom = nil;
        }
        if ([serverData valueForKey:@"valid_until"]) {
            tour.validUntil = [dateFMT dateFromString:[serverData valueForKey:@"valid_until"]];
        } else {
            tour.validUntil = nil;
        }
        if ([serverData objectForKey:@"driver_edit"]) {
            tour.isDriverEditable = [NSNumber numberWithBool:[[serverData objectForKey:@"driver_edit"] boolValue]];
        } else {
            tour.isDriverEditable = nil;
        }
        if ([serverData objectForKey:@"is_shuttle_tour"]) {
            tour.isShuttleTour = [NSNumber numberWithBool:[[serverData objectForKey:@"is_shuttle_tour"] boolValue]];
        } else {
            tour.isShuttleTour = nil;
        }
        if ([serverData objectForKey:@"use_multi_user_mode_to_load"]) {
            tour.useMultiUserModeToLoad = [NSNumber numberWithBool:[[serverData objectForKey:@"use_multi_user_mode_to_load"] boolValue]];
        } else {
            tour.useMultiUserModeToLoad = nil;
        }
        if ([serverData objectForKey:@"use_multi_user_mode_to_unload"]) {
            tour.useMultiUserModeToUnload = [NSNumber numberWithBool:[[serverData objectForKey:@"use_multi_user_mode_to_unload"] boolValue]];
        } else {
            tour.useMultiUserModeToUnload = nil;
        }
        if ([serverData valueForKey:@"shuttle_include_zip_codes"]) {
            tour.shuttleIncludeZipCodes = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"shuttle_include_zip_codes"]];
        } else {
            tour.shuttleIncludeZipCodes = nil;
        }
        tour.shuttleOmitZipCodes = [serverData stringForKey:@"shuttle_omit_zip_codes"];
        if ([serverData valueForKey:@"truck_id"]) {
            tour.truck_id = [Truck truckWithTruckID:[NSNumber numberWithInt:[[serverData valueForKey:@"truck_id"] intValue]] inCtx:aCtx];
        } else {
            tour.truck_id = nil;
        }
        if ([serverData valueForKey:@"trailer_id"]) {
            tour.trailer_id = [Truck truckWithTruckID:[NSNumber numberWithInt:[[serverData valueForKey:@"trailer_id"] intValue]] inCtx:aCtx];
        } else {
            tour.trailer_id = nil;
        }
        if ([serverData valueForKey:@"driver_id"]) {
            tour.driver_id = [User userWithUserID:[NSNumber numberWithInt:[[serverData valueForKey:@"driver_id"] intValue]] inCtx:aCtx];
        } else {
            tour.driver_id = nil;
        }
        if ([serverData valueForKey:@"group_tour_id"]) {
            tour.grouptour_id = [Tour tourWithTourID:[NSNumber numberWithInt:[[serverData valueForKey:@"group_tour_id"] intValue]] inCtx:aCtx];
        } else {
            tour.grouptour_id = nil;
        }
	}
	
	return tour;
}

+ (Tour *)tourWithDepartureData:(NSDictionary *)departureData inCtx:(NSManagedObjectContext *)aCtx {
	Tour	  *tour	  = nil;
	NSError	  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Tour class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [Tour withTourId:[departureData valueForKey:@"tour_id"]];
	
	// lastObject returns nil, if no data in db_handle
	tour				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!tour) {
			// INSERT new Object (db_handle returns nil without an error)
			tour = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Tour class]) inManagedObjectContext:aCtx];
			tour.tour_id = [NSNumber numberWithInt:[[departureData valueForKey:@"tour_id"]intValue]];
		}
		// UPDATE properties for existing Object
	}
	
	return tour;
}

+ (Tour *)tourWithTransportData:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx {
	Tour	  *tour	  = nil;
	NSError	  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Tour class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [Tour withTourId:[transportData valueForKey:@"tour_id"]];
	
	// lastObject returns nil, if no data in db_handle
	tour				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!tour) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_077", @"Transport-Tour speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_034", @"ACHTUNG: Es wurden keine Daten für Tour-ID %@ gefunden. Der Transport-Code %@ muss wieder abgeladen werden!"),
									  [transportData valueForKey:@"tour_id"], [transportData valueForKey:@"code"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return tour;
}


+ (Tour *)currentTourWithTransportData:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx {
	Tour	  *tour	  = nil;
	NSError	  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Tour class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [Tour withTourId:[NSUserDefaults currentTourId]];
	
	// lastObject returns nil, if no data in db_handle
	tour				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!tour) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_077", @"Transport-Tour speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_034", @"ACHTUNG: Es wurden keine Daten für Tour-ID %@ gefunden. Der Transport-Code %@ muss wieder abgeladen werden!"),
									  [transportData valueForKey:@"tour_id"], [transportData valueForKey:@"code"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return tour;
}

+ (Tour *)tourWithCargoData:(NSDictionary *)cargoData inCtx:(NSManagedObjectContext *)aCtx {
	Tour	  *tour	  = nil;
	NSError	  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Tour class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [Tour withTourId:[cargoData valueForKey:@"tour_id"]];
	
	// lastObject returns nil, if no data in db_handle
	tour				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!tour) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_077", @"Transport-Tour speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_034", @"ACHTUNG: Es wurden keine Daten für Tour-ID %@ gefunden. Der Transport-Code %@ muss wieder abgeladen werden!"),
									  [cargoData valueForKey:@"tour_id"], [cargoData valueForKey:@"code"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return tour;
}

+ (Tour *)tourWithTourID:(NSNumber *)tourID inCtx:(NSManagedObjectContext *)aCtx {
    return [[self withPredicate:[Tour withTourId:tourID] inCtx:aCtx] lastObject];
}

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
    return [Tour withPredicate:aPredicate sortDescriptors:nil inCtx:aCtx];
}

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *tours = nil;
	NSError  *error	= nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Tour class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	tours				   = [aCtx executeFetchRequest:db_handle error:&error];
	
	return tours;
}

@dynamic code;
@dynamic description_text;
@dynamic device_udid;
@dynamic isDriverEditable;
@dynamic isShuttleTour;
@dynamic shuttleIncludeZipCodes;
@dynamic shuttleOmitZipCodes;
@dynamic tour_id;
@dynamic useMultiUserModeToLoad;
@dynamic useMultiUserModeToUnload;
@dynamic validFrom;
@dynamic validUntil;
@dynamic departure_id;
@dynamic transport_id;
@dynamic truck_id;
@dynamic trailer_id;
@dynamic grouptour_id;
@dynamic driver_id;
@dynamic subtour_id;

@end


@implementation Tour (Predicates)

+ (NSPredicate *) withDeviceId:(NSString *) deviceId {
    return [NSPredicate predicateWithFormat:@"device_udid = %@", deviceId];
}

+ (NSPredicate *) withTourId:(NSNumber *) tourId {
    return [NSPredicate predicateWithFormat:@"tour_id = %i", [tourId intValue]];
}

+ (NSPredicate *) withCode:(NSString *) code {
    return [NSPredicate predicateWithFormat:@"code = %@", code];
}

@end