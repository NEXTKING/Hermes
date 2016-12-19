//
//  Location.m
//  Hermes
//
//  Created by Attila Teglas on 4/15/12.
//  Updated by Lutz Thalmann on 22.09.14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#import "Location_Group.h"

#import "DSPF_Error.h"

static NSString * const LocationAttributeForceLocation = @"force_signature";

@implementation Location

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"MESSAGE_023", @"Locations");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfLocations";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (Location *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Location *location = nil;
	NSError  *error    = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"location_id = %i", [[serverData valueForKey:@"id"] intValue]];
	
	// lastObject returns nil, if no data in db_handle
	location               = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!location) {
			// INSERT new Object (db_handle returns nil without an error)
			location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:aCtx];
			location.location_id   = [NSNumber numberWithInt:[[serverData valueForKey:@"id"] intValue]];
            
		}
		// UPDATE properties for existing Object
		location.location_group_id = [Location_Group locationGroupWithLocationData:serverData inCtx:aCtx];
		location.location_name     = [[[NSString stringWithFormat:@"%@", [serverData valueForKey:@"name"]]
                                      stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"]
                                      stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
        if ([serverData valueForKey:@"location_code"]) {
            location.location_code = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"location_code"]];
        } else if ([serverData valueForKey:@"notice"]) {
            location.location_code = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"notice"]];
        } else {
            location.location_code = nil;
        }
		location.city              = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"city"]];
		location.street            = [[[[NSString stringWithFormat:@"%@", [serverData valueForKey:@"street"]]
                                      stringByReplacingOccurrencesOfString:@"&#9993;" withString:@"📮"]
                                      stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"]
                                      stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
        location.state = [serverData stringForKey:@"state"];
		location.country_code      = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"country_code"]];
		location.zip               = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"zip"]];
		location.latitude          = [NSNumber numberWithDouble:[[serverData valueForKey:@"latitude"]doubleValue]];
		location.longitude         = [NSNumber numberWithDouble:[[serverData valueForKey:@"longitude"]doubleValue]];
        
        if ([serverData objectForKey:@"code"]) {
			location.code = [serverData objectForKey:@"code"];
		}
        if ([serverData valueForKey:@"erase_flag"] &&
            ((NSString *)[serverData valueForKey:@"erase_flag"]).length > 0 &&
            ![(NSString *)[serverData valueForKey:@"erase_flag"] isEqualToString:@" "]) {
            location.erase_flag = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"erase_flag"]];
        } else {
            location.erase_flag = nil;
        }
        location.contact_name = [serverData stringForKey:@"contact_name"];
        location.contact_email = [serverData stringForKey:@"contact_email"];
        location.contact_phone = [serverData stringForKey:@"contact_phone"];
        location.contact_mobilePhone = [serverData stringForKey:@"contact_mobilephone"];
        if ([serverData valueForKey:@"contact_survey"] && [[NSString stringWithFormat:@"%@", [serverData valueForKey:@"contact_survey"]] length] > 0) {
            if (location.contact_name && location.contact_name.length > 0) {
                location.contact_name  = [NSString stringWithFormat:@"📝 %@ 👤 %@", [serverData valueForKey:@"contact_survey"], location.contact_name];
            } else {
                location.contact_name  = [NSString stringWithFormat:@"📝 %@", [serverData valueForKey:@"contact_survey"]];
            }
        }
        NSDateFormatter *dateFMT  = [[NSDateFormatter alloc] init];
        [dateFMT setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
        if ([serverData valueForKey:@"last_customer_survey"]) {
            location.lastCustomerSurvey = [dateFMT dateFromString:[serverData valueForKey:@"last_customer_survey"]];
        } else {
            location.lastCustomerSurvey = nil;
        }
        if ([serverData valueForKey:@"preferred_supplier_id"]) {
            location.preferredSupplier_id = [Location withID:[NSNumber numberWithInt:[[serverData valueForKey:@"preferred_supplier_id"] intValue]] inCtx:aCtx];
        } else {
            location.preferredSupplier_id = nil;
        }
        if ([serverData valueForKey:@"preferred_disposer_id"]) {
            location.preferredDisposer_id = [Location withID:[NSNumber numberWithInt:[[serverData valueForKey:@"preferred_disposer_id"] intValue]] inCtx:aCtx];
        } else {
            location.preferredDisposer_id = nil;
        }
        
        location.force_signature = [serverData boolFromNumberForKey:LocationAttributeForceLocation];
	}
	
	return location;
}

+ (Location *)locationWithDepartureData:(NSDictionary *)departureData inCtx:(NSManagedObjectContext *)aCtx {
	Location *location = nil;
	NSError  *error    = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"location_id = %i", [[departureData valueForKey:@"location_id"]intValue]];
	
	// lastObject returns nil, if no data in db_handle
	location               = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!location) {
			// INSERT new Object (db_handle returns nil without an error)
			location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:aCtx];
			location.location_id = [NSNumber numberWithInt:[[departureData valueForKey:@"location_id"]intValue]];
		}
		// UPDATE properties for existing Object
	}
	
	return location;
}

+ (Location *)locationWithTour_Exception:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Location *location = nil;
	NSError  *error    = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"location_id = %i", [[serverData valueForKey:@"location_id"]intValue]];
	
	// lastObject returns nil, if no data in db_handle
	location               = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!location) {
			// INSERT new Object (db_handle returns nil without an error)
			location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:aCtx];
			location.location_id = [NSNumber numberWithInt:[[serverData valueForKey:@"location_id"]intValue]];
		}
		// UPDATE properties for existing Object
	}
	
	return location;
}

+ (Location *)locationWithTransportOrigin:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx {
	Location *location = nil;
	NSError  *error    = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"location_id = %i", [[transportData valueForKey:@"from_location"]intValue]];
	
	// lastObject returns nil, if no data in db_handle
	location               = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!location) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_074", @"Transport-Herkunft speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_031", @"ACHTUNG: Es wurden keine Daten f√ºr Location-ID %@ gefunden. Der Transport-Code %@ muss wieder abgeladen werden!"),
									  [transportData valueForKey:@"from_location"], [transportData valueForKey:@"code"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return location;
}

+ (Location *)locationWithTransportDestination:(NSDictionary *)transportData inCtx:(NSManagedObjectContext *)aCtx {
	Location *location = nil;
	NSError  *error    = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"location_id = %i", [[transportData valueForKey:@"to_location"]intValue]];
    NSDictionary *userInfo = [transportData objectForKey:@"userInfo"];
    BOOL coordinatesProvided = [userInfo valueForKey:@"longitude"] != nil && [userInfo valueForKey:@"latitude"] != nil;
	
	// lastObject returns nil, if no data in db_handle
	location               = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!location && !coordinatesProvided) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_075", @"Transport-Ziel speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_031", @"ACHTUNG: Es wurden keine Daten für Location-ID %@ gefunden. Der Transport-Code %@ muss wieder abgeladen werden!"),
									  [transportData valueForKey:@"to_location"], [transportData valueForKey:@"code"]]
							delegate:nil];
            NSLog(@"%@", transportData);
            abort();
		}
		// UPDATE properties for existing Object
	}
	
	return location;
}


+ (Location *)locationWithRecipientData:(NSDictionary *)recipientData inCtx:(NSManagedObjectContext *)aCtx {
	Location *location = nil;
	NSError  *error    = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"location_id = %i", [[recipientData valueForKey:@"location_id"]intValue]];
	
	// lastObject returns nil, if no data in db_handle
	location               = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!location) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_076", @"Empfänger speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_032", @"ACHTUNG: Es wurden keine Daten für Location-ID %@ gefunden. Der Empfänger %@ kann hier nicht gespeichert werden!"),
									  [recipientData valueForKey:@"location_id"], [recipientData valueForKey:@"recipient_name"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
    
    return location;
}

+ (Location *)withID:(NSNumber *)locationID inCtx:(NSManagedObjectContext *)aCtx {
	Location *location = nil;
	NSError  *error    = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Location class]) inManagedObjectContext:aCtx];
    db_handle.predicate    = [Location withLocationID:locationID];
	
	// lastObject returns nil, if no data in db_handle
	location               = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];

    return location;
}

+ (NSArray  *)locationsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray *locations = nil;
	NSError  *error    = nil;
    
    NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity			= [NSEntityDescription entityForName:@"Location" inManagedObjectContext:aCtx];
	db_handle.predicate			= aPredicate;
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
    
	// lastObject returns nil, if no data in db_handle
	locations              = [aCtx executeFetchRequest:db_handle error:&error];
	if (aPredicate) {
		if (!locations || locations.count == 0) {
			NSLog(@"Location has no records for %@", [aPredicate predicateFormat]);
		}
	}
    
	return locations;
}

+ (Location *)withCode:(NSString *)aCode inCtx:(NSManagedObjectContext *)aCtx {
    return [[self locationsWithPredicate:[NSPredicate predicateWithFormat:@"code = %@", aCode] sortDescriptors:nil inCtx:aCtx] lastObject];
}

- (NSString *) formattedString {
    NSMutableString *result = [[NSMutableString alloc] init];
    if ([self.location_name length] > 0) {
        [result appendFormat:@"%@\n", self.location_name];
    }
    if ([self.street length] > 0) {
        [result appendFormat:@"%@\n", self.street];
    }
    if ([self.zip length] > 0) {
        [result appendFormat:@"%@ ", self.zip];
    }
    if ([self.city length] > 0) {
        [result appendString:self.city];
    }
    return [result copy];
}


@dynamic city;
@dynamic code;
@dynamic contact_email;
@dynamic contact_mobilePhone;
@dynamic contact_name;
@dynamic contact_phone;
@dynamic country_code;
@dynamic erase_flag;
@dynamic force_signature;
@dynamic lastCustomerSurvey;
@dynamic latitude;
@dynamic location_code;
@dynamic location_id;
@dynamic location_name;
@dynamic longitude;
@dynamic notice;
@dynamic state;
@dynamic street;
@dynamic zip;
@dynamic departure_id;
@dynamic groupLocation_id;
@dynamic location_alias_id;
@dynamic location_group_id;
@dynamic memberLocation_id;
@dynamic preferredDisposer_id;
@dynamic preferredDisposerOf_id;
@dynamic preferredSupplier_id;
@dynamic preferredSupplierOf_id;
@dynamic recipient_id;
@dynamic tour_exception_id;
@dynamic transport_destination_id;
@dynamic transport_origin_id;
@dynamic transport_group_sender_id;
@dynamic transport_group_addressee_id;
@dynamic transport_group_freightpayer_id;
@dynamic transport_final_destination_id;

@end

@implementation Location (Predicates)

+ (NSPredicate *) withLocationID:(NSNumber *) locationId {
    return [NSPredicate predicateWithFormat:@"location_id = %@", locationId];
}

@end
