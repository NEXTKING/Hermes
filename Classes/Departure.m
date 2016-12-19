//
//  Departure.h
//  Hermes
//
//  Created by Lutz Thalmann on 19.09.14
//  Updated by Lutz Thalmann on 25.09.14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "Departure.h"

#import "DSPF_Error.h"
#import "NSUserDefaults+Additions.h"

@implementation Schedule

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"MESSAGE_021", @"Departures");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfDepartures";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    for (Transport *tmpTourTransport in [NSArray arrayWithArray:[Transport transportsWithPredicate:
                                                                 [NSPredicate predicateWithFormat:@"(trace_type_id.code = %@ OR trace_type_id.code = %@ OR "
                                                                  "trace_type_id.trace_type_id >= 80) && "
                                                                  "(0 == SUBQUERY(trace_log_id, $l, $l.trace_log_id != 0).@count)", @"UNLOAD", @"UNTOUCHED"]
                                                                                   sortDescriptors:nil inCtx:ctx]]) {
        [ctx deleteObject:tmpTourTransport];
    }
    for (Departure *unchained in [NSArray arrayWithArray:[Departure withPredicate:[NSPredicate predicateWithFormat:@"transport_id.@count = 0 && "
                                                                                             "location_id.transport_origin_id.@count = 0 && location_id.transport_destination_id.@count = 0"]
                                                                            sortDescriptors:nil
                                                                                      inCtx:ctx]]) {
        [ctx deleteObject:unchained];
    }
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (Departure *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
    return [Departure fromServerData:serverData inCtx:aCtx];
}

@end


@implementation Departure

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"MESSAGE_021", @"Departures");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfDepartures";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    if (!option || option.length == 0 || PFBrandingSupported(BrandingCCC_Group, nil)) {
        for (Transport *tmpTourTransport in [NSArray arrayWithArray:[Transport transportsWithPredicate:
                                                                     [NSPredicate predicateWithFormat:
                                                                      @"(trace_type_id.code = %@ OR trace_type_id.code = %@ OR "
                                                                      "trace_type_id.trace_type_id >= 80) && "
                                                                      "(0 == SUBQUERY(trace_log_id, $l, $l.trace_log_id != 0).@count)",
                                                                      @"UNLOAD", @"UNTOUCHED"]
                                                                                       sortDescriptors:nil
                                                                                                 inCtx:ctx]]) {
            [ctx deleteObject:tmpTourTransport];
        }
        for (Departure *unchained in [NSArray arrayWithArray:[Departure withPredicate:
                                                              [NSPredicate predicateWithFormat:
                                                               @"(currentTourBit = NO OR currentTourBit = nil OR tour_id = nil) && "
                                                               "transport_id.@count = 0 && "
                                                               "location_id.transport_origin_id.@count = 0 && "
                                                               "location_id.transport_destination_id.@count = 0"]
                                                                                sortDescriptors:nil
                                                                                          inCtx:ctx]]) {
            [ctx deleteObject:unchained];
        }
    }
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        //Finding all removed tour stops
        if (![NSUserDefaults currentTourId])
            return;
            
        
        NSMutableArray *newDepartures = [NSMutableArray new];
        for (NSDictionary *currentData in serverData) {
            NSString *taskString = [currentData valueForKey:@"task"];
            if (taskString && taskString.length > 0)
                [newDepartures addObject:taskString];
        }
        
        
        NSArray *currentDepartures = [self withPredicate:[NSPredicate predicateWithFormat:@"tour_id.tour_id = %@", [NSUserDefaults currentTourId]] inCtx:ctx];
        for (Departure *departure in currentDepartures) {
            BOOL found = NO;
            
            for (NSString* newDepartureTask in newDepartures) {
                if ([departure.infoText isEqualToString:newDepartureTask])
                {
                    found = YES;
                    break;
                }
            }
            
            if (!found)
            {
                departure.tour_id = nil;
                departure.currentTourBit = [NSNumber numberWithBool:NO];
                departure.infoText = @"";
                [ctx saveIfHasChanges];
            }
            
        }
    }
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    if (PFTourTypeSupported(@"0X1", nil) || (option && option.length > 0)) {
        [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"updateTour" object:self userInfo:nil]
                                                   postingStyle:NSPostASAP];
    }
}


+ (Departure *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Departure *departure = nil;
	NSError   *error	 = nil;
	//NSLog(@"DEPARTURE SELECT, serverData");
    
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Departure" inManagedObjectContext:aCtx];
    
    NSPredicate *predicate = nil;
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
        predicate = [NSPredicate predicateWithFormat:@"infoText = %@", [serverData valueForKey:@"task"]];
    else
        predicate = [NSPredicate predicateWithFormat:@"departure_id = %lld", [[serverData valueForKey:@"id"] longLongValue]];
    
    db_handle.predicate    = predicate;
	
	// lastObject returns nil, if no data in db_handle
	departure			   = [[ctx() executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!departure) {
			// INSERT new Object (db_handle returns nil without an error)
			departure = [NSEntityDescription insertNewObjectForEntityForName:@"Departure" inManagedObjectContext:aCtx];
		}
		// UPDATE properties for existing Object
        departure.departure_id = [NSNumber numberWithLongLong:[[serverData valueForKey:@"id"] longLongValue]];
		departure.tour_id         = [Tour tourWithDepartureData:serverData inCtx:aCtx];
		departure.location_id     = [Location locationWithDepartureData:serverData inCtx:aCtx];
        if ([serverData valueForKey:@"dow"]) {
			departure.dayOfWeek   = [NSNumber numberWithInt:[[serverData valueForKey:@"dow"] intValue]];
		} else {
            departure.dayOfWeek   = [DPHDateFormatter dayOfWeekFromDate:[NSDate date]];
        }
        if (!departure.sequence ||
            ([departure.sequence intValue] == 0 && [[serverData valueForKey:@"pos"] intValue] != 0)) {
            departure.sequence    = [NSNumber numberWithInt:[[serverData valueForKey:@"pos"] intValue]];
        }
        departure.predefinedOrder = [NSNumber numberWithInt:[[serverData valueForKey:@"pos"] intValue]];
		
        if ([serverData valueForKey:@"arrival"]) {
            departure.arrival = [DPHDateFormatter dateFromString:[serverData valueForKey:@"arrival"]
                                                   withDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle locale:de_CH_Locale()];
        } else {
            departure.arrival     = nil;
        }
        
        departure.departure       = [DPHDateFormatter dateFromString:[serverData valueForKey:@"departure"]
                                                       withDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle locale:de_CH_Locale()];
        
        departure.onDemand        = [NSNumber numberWithBool:[[serverData objectForKey:@"ondemand"] boolValue]];
        if ([serverData valueForKey:@"task"]) {
            departure.transport_group_id = [Transport_Group transport_GroupWithTask:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"task"]] inCtx:aCtx];
            departure.infoText = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"task"]];
        } else {
            departure.transport_group_id = nil;
        }
        if ([departure.currentTourBit boolValue] == NO && (PFTourTypeSupported(@"1XX", @"1X1", nil) && [NSUserDefaults currentTourId] &&
              [[NSUserDefaults currentTourId] isEqualToNumber:departure.tour_id.tour_id]) &&
            [departure.dayOfWeek intValue] == [[NSUserDefaults currentStintDayOfWeek] intValue])
        {
            departure.currentTourBit     = [NSNumber numberWithBool:YES];
            departure.currentTourStatus  = [NSNumber numberWithInt:00];
            if (!PFBrandingSupported(BrandingTechnopark, nil))
                departure.canceled = [NSNumber numberWithBool:NO];
        }
        departure.confirmed           = [NSNumber numberWithBool:[[serverData objectForKey:@"go"] boolValue]];
        
        if (!PFBrandingSupported(BrandingTechnopark, nil))
            departure.canceled            = [NSNumber numberWithBool:[[serverData objectForKey:@"nogo"] boolValue]];
        
        if ([serverData valueForKey:@"infotext"] &&
            ![[NSString stringWithFormat:@"%@", [serverData valueForKey:@"infotext"]] isEqualToString:@""]) {
            departure.infoText        = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"infotext"]];
        } else {
            departure.infoText        = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"task"]];
        }
        if ([serverData valueForKey:@"infomessage"] &&
            ![[NSString stringWithFormat:@"%@", [serverData valueForKey:@"infomessage"]] isEqualToString:@""]) {
            departure.infoMessage     = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"infomessage"]];
        } else {
            departure.infoMessage     = nil;
        }
        if ([serverData valueForKey:@"infomessagedate"]) {
            departure.infoMessageDate = [DPHDateFormatter dateFromString:[serverData valueForKey:@"infomessagedate"]
                                                           withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
        } else {
            departure.infoMessageDate = nil;
        }
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            if ([[serverData valueForKey:@"pos"] intValue] == -2)
            {
                departure.currentTourStatus = nil;
                departure.canceled = [NSNumber numberWithBool:YES];
            }
            else if ([[serverData valueForKey:@"pos"] intValue] == -3)
            {
                departure.currentTourStatus = [NSNumber numberWithInt:70];
            }
        }
            
	}
	
	return departure;
}

+ (Departure *)departureWithTransportData:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx {
	Departure *departure = nil;
	NSError   *error	 = nil;
	//NSLog(@"DEPARTURE SELECT, transportData");
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Departure" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"departure_id = %@", [transportData valueForKey:@"from_departure"]];
	
	// lastObject returns nil, if no data in db_handle
	departure			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!departure) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_074", @"Transport-Herkunft speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_033", @"ACHTUNG: Es wurden keine Daten für Departure-ID %@ gefunden. Der Transport-Code %@ muss wieder abgeladen werden!"),
									  [transportData valueForKey:@"from_departure"], [transportData valueForKey:@"code"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return departure;
}

+ (Departure *)departureWithDepartureID:(NSNumber *)departureID inCtx:(NSManagedObjectContext *)aCtx {
    return [[self withPredicate:[NSPredicate predicateWithFormat:@"departure_id = %lld", [departureID longLongValue]] inCtx:aCtx] lastObject];
}

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
    return [self withPredicate:aPredicate sortDescriptors:nil inCtx:aCtx];
}

+ (NSArray  *)withPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *departures = nil;
	NSError  *error		 = nil;
	
    //NSLog(@"DEPARTURE SELECT for %@", [aPredicate predicateFormat]);
    
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Departure" inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	departures			   = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return departures;
}

+ (NSArray  *)distinctLocationsFromDeparturesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
    NSArray *departures = [self withPredicate:aPredicate inCtx:aCtx];
    NSArray *departureLocations = [departures valueForKeyPath:@"location_id"];
	return [[NSArray arrayWithArray:[[NSSet setWithArray:departureLocations] allObjects]] sortedArrayUsingDescriptors:sortDescriptors];
}

+ (NSInteger)currentDepartureSequenceInCtx:(NSManagedObjectContext *)aCtx {
    return [[[[self withPredicate:[NSPredicate predicateWithFormat:@"currentTourStatus = 50"] inCtx:aCtx] valueForKeyPath:@"sequence"] lastObject] intValue];
}

+ (NSArray *) departuresOfCurrentlyDrivenTourInCtx:(NSManagedObjectContext *) ctx {
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES]];
    return [Departure withPredicate:[NSPredicate predicateWithFormat:@"currentTourBit == YES"] sortDescriptors:sortDescriptors inCtx:ctx];
}

+ (NSArray *) tourDeparturesInCtx:(NSManagedObjectContext *)ctx sortedAscending:(BOOL) ascending {
    //onDemand = NO is a must stop (green)
    return [NSArray arrayWithArray:[Departure withPredicate:[NSPredicate predicateWithFormat:@"currentTourBit = YES && onDemand = NO"]
                                            sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:ascending]] inCtx:ctx]];
}

+ (Departure *)firstTourDepartureInCtx:(NSManagedObjectContext *) ctx {
    return (Departure *)[[Departure tourDeparturesInCtx:ctx sortedAscending:YES] firstObject];
}

+ (Departure *)lastTourDepartureInCtx:(NSManagedObjectContext *) ctx {
    return (Departure *)[[Departure tourDeparturesInCtx:ctx sortedAscending:YES] lastObject];
}

@dynamic arrival;
@dynamic arrivalDate;
@dynamic canceled;
@dynamic confirmed;
@dynamic currentTourBit;
@dynamic currentTourStatus;
@dynamic dayOfWeek;
@dynamic departure;
@dynamic departure_id;
@dynamic departureDate;
@dynamic infoMessage;
@dynamic infoMessageDate;
@dynamic infoText;
@dynamic onDemand;
@dynamic predefinedOrder;
@dynamic preferredHandoverStop;
@dynamic sequence;
@dynamic location_id;
@dynamic tour_id;
@dynamic transport_group_id;
@dynamic transport_id;
@dynamic transport_target_id;

@end

@implementation Departure (Predicates)

+ (NSPredicate *) withLocation:(Location *)location {
    return [NSPredicate predicateWithFormat:@"location_id.location_id = %@", location.location_id];
}

+ (NSPredicate *) withLocationType:(NSInteger)locationGroupId {
    return [NSPredicate predicateWithFormat:@"location_id.location_group_id.location_group_id = %ld", locationGroupId];
}

+ (NSPredicate *) withLocationCode:(NSString *)locationCode {
    return [NSPredicate predicateWithFormat:@"location_id.location_group_id.code = %@", locationCode];
}

+ (NSPredicate *) withTour:(NSNumber *)tourId dayOfWeek:(NSNumber *)dow {
    return [NSPredicate predicateWithFormat:@"tour_id.tour_id = %@ && dayOfWeek = %@", tourId, dow];
}

+ (NSPredicate *) withOnDemand:(BOOL) onDemand {
    return [NSPredicate predicateWithFormat:@"onDemand = %@", [NSNumber numberWithBool:onDemand]];
}

+ (NSPredicate *) withStatusLT:(NSInteger)maximumTourStatus {
    return [NSPredicate predicateWithFormat:@"currentTourStatus < %ld", maximumTourStatus];
}

+ (NSPredicate *) withCurrentBitSet:(BOOL)currentTourBitSet {
    NSString *format = @"currentTourBit = NO OR currentTourBit = nil";
    if (currentTourBitSet) {
        format = @"currentTourBit = YES";
    }
    return [NSPredicate predicateWithFormat:format];
}

+ (NSPredicate *) forDestinationList:(NSInteger) destinationList {
    NSPredicate *departurePredicate = nil;
    if (destinationList == 1) {
        if (PFBrandingSupported(BrandingViollier, nil)) {
            departurePredicate = [Departure withLocationCode:@"LOG.S"];
        } else if (PFBrandingSupported(BrandingUnilabs, nil)) {
            departurePredicate = [Departure withLocationCode:@"P"];
        } else {
            departurePredicate = [Departure withLocationType:LocationGroupValueWerk];
        }
    } else {
        if (PFBrandingSupported(BrandingViollier, nil)) {
            departurePredicate = NotPredicate([Departure withLocationCode:@"LOG.S"]);
        } else if (PFBrandingSupported(BrandingUnilabs, nil)) {
            departurePredicate = [Departure withLocationCode:@"L"];
        } else {
            departurePredicate = [Departure withLocationType:LocationGroupValueOrt];
        }
    }
    
    NSInteger currentDepartureSequence = [Departure currentDepartureSequenceInCtx:ctx()];
    NSPredicate *departuresForCurrentTour = [Departure withTour:[NSUserDefaults currentTourId] dayOfWeek:[NSUserDefaults currentStintDayOfWeek]];
    NSPredicate *sequencePredicate = [NSPredicate predicateWithFormat:@"sequence > %i", currentDepartureSequence];
    
    NSPredicate *onDemandWithNoBit = AndPredicates([Departure withOnDemand:YES], [Departure withCurrentBitSet:NO], nil);
    NSArray *andPredicates = @[departurePredicate,
                               departuresForCurrentTour,
                               sequencePredicate,
                               OrPredicates([Departure withStatusLT:60], onDemandWithNoBit, nil)];
    if (![[NSUserDefaults tourFinishCheckValue] isEqualToString:TourFinishCheckErr]) {
        andPredicates = @[departurePredicate, departuresForCurrentTour];
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:andPredicates];
}

@end
