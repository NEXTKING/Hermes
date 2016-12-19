//
//  Transport.m
//  dphHermes
//
//  Created by Lutz  Thalmann on 01.07.14.
//  Updated by Lutz  Thalmann on 24.09.14.
//
//

#import "Transport.h"
#import "Transport_Group.h"
#import "Location.h"
#import "Departure.h"
#import "Tour.h"

#import "DSPF_Error.h"

@implementation Cargo

+ (NSManagedObject *) fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
    return [Transport transportWithCargoData:serverData inCtx:aCtx];
}

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"Cargos", @"Cargos");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfTransports";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

@end

@interface Transport()

// from tour
+ (NSInteger)transportsPalletCountFromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                              inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger)transportsRollContainerCountFromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                                     inCtx:(NSManagedObjectContext *)ctx;
+ (NSInteger)transportsUnitCountFromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                            inCtx:(NSManagedObjectContext *)ctx;

@end

@implementation Transport

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"TITLE_079", @"Transports");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfTransports";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

#pragma mark -

+ (Transport *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
    
    if (PFBrandingSupported(BrandingTechnopark, nil) && [[serverData objectForKey:@"quantity"] integerValue] == 0 )
    {
        Transport *transport = nil;
        NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
        db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Transport class]) inManagedObjectContext:aCtx];
        //db_handle.predicate    = [Transport withCodes:@[transportCode]];
        db_handle.predicate      = [NSPredicate predicateWithFormat:@"item_id.itemID = %@", [serverData objectForKey:@"item"]];
        // lastObject returns nil, if no data in db_handle
        transport				   = [[aCtx executeFetchRequest:db_handle error:nil] lastObject];
        if (transport)
        {
            transport.transport_group_id = nil;
            [ctx() saveIfHasChanges];
        }
        return nil;
    }
    
	Transport *transport     = nil;
	NSError   *error         = nil;
    NSString  *transportCode = [serverData valueForKey:@"code"];
    
    NSRange  barCodeTrailerRange = [Transport rangeOfTrailerFromBarcode:transportCode];
	if (barCodeTrailerRange.location != NSNotFound) {
		transportCode = [transportCode substringToIndex:barCodeTrailerRange.location];
	}
    
    Item *transportItem = nil;
    if ([serverData objectForKey:@"item"]) {
        transportItem = [Item itemWithItemID:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"item"]] inCtx:aCtx];
    }
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Transport class]) inManagedObjectContext:aCtx];
	//db_handle.predicate    = [Transport withCodes:@[transportCode]];
    db_handle.predicate      = [NSPredicate predicateWithFormat:@"item_id.itemID = %@", [serverData objectForKey:@"item"]];
	// lastObject returns nil, if no data in db_handle
	transport				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
        if ([serverData objectForKey:@"CRUD"] &&
            [[serverData objectForKey:@"CRUD"] isEqualToString:@"*DLT"]) {
            if (transport && !transport.trace_type_id) {
                [aCtx deleteObject:transport];
            }
            return nil;
        }
		if (!transport) {
			// INSERT new Object (db_handle returns nil without an error)
			transport = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Transport class]) inManagedObjectContext:aCtx];
            transport.transport_id = [NSUserDefaults nextTransportId];
		}
		// UPDATE properties for existing Object
		transport.code                    = [NSString stringWithFormat:@",%@,", transportCode];
		transport.tour_id                 = [Tour		  currentTourWithTransportData:serverData        inCtx:aCtx];
		transport.to_location_id          = [Location   locationWithTransportDestination:serverData      inCtx:aCtx];
		if ([serverData objectForKey:@"isPallet"]) {
			transport.isPallet            = [serverData objectForKey:@"isPallet"];
		}
        if ([serverData objectForKey:@"price"]) {
			transport.price               = [NSDecimalNumber decimalNumberWithDecimal:[[serverData valueForKey:@"price"] decimalValue]];
		}
        transport.paymentOnPickUp = [serverData decimalForKey:@"payment_on_pickup"];
        transport.paymentOnDelivery = [serverData decimalForKey:@"payment_on_delivery"];
        transport.weight = [serverData decimalForKey:@"weight"];
        transport.netWeight = [serverData decimalForKey:@"net_weight"];
        transport.occurrences         = [serverData objectForKey:@"occurrences"];
		if ([serverData objectForKey:@"from_location"]) {
			transport.from_location_id    = [Location  locationWithTransportOrigin:serverData            inCtx:aCtx];
		}
        if ([serverData objectForKey:@"from_tour_stop"]) {
			transport.from_departure_id   = [Departure departureWithDepartureID:[NSNumber numberWithLongLong:
                                                                                 [[serverData valueForKey:@"from_tour_stop"] longLongValue]]
                                                         inCtx:aCtx];
		} else {
            if ([serverData objectForKey:@"from_departure"]) {
                transport.from_departure_id = [Departure departureWithTransportData:serverData             inCtx:aCtx];
            } else {
                transport.from_departure_id = nil;
            }
        }
        if ([serverData objectForKey:@"to_tour_stop"]) {
			transport.to_departure_id   = [Departure departureWithDepartureID:[NSNumber numberWithLongLong:
                                                                               [[serverData valueForKey:@"to_tour_stop"] longLongValue]]
                                                       inCtx:aCtx];
		} else {
            transport.to_departure_id   = nil;
        }
        if ([serverData objectForKey:@"task"]) {
			transport.transport_group_id  = [Transport_Group transport_GroupWithTransportData:serverData inCtx:aCtx];
		}
        
        transport.item_id = transportItem;
        
        if ([serverData objectForKey:@"quantity"]) {
			transport.itemQTY = [NSNumber numberWithInt:[[[NSDecimalNumber decimalNumberWithString:
                                                           [NSString stringWithFormat:@"%@", [serverData valueForKey:@"quantity"]]] decimalNumberByRoundingAccordingToBehavior:
                                                          [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundBankers
                                                                                                          scale:0
                                                                                               raiseOnExactness:YES
                                                                                                raiseOnOverflow:YES
                                                                                               raiseOnUnderflow:YES
                                                                                            raiseOnDivideByZero:YES]] intValue]];
		} else {
            transport.itemQTY = nil;
        }
        transport.itemQTYUnit = [serverData stringForKey:@"quantity_unit"];
        transport.isPallet  = [serverData objectForKey:@"is_pallet"];
        transport.infoText = [serverData stringForKey:@"info_text"];
        transport.requestBarcode = [serverData stringForKey:@"bar_code"];
        if ([serverData objectForKey:@"transport_request_type"]) {
            transport.requestType = [NSNumber numberWithInt:[[serverData objectForKey:@"transport_request_type"] intValue]];
        } else {
            transport.requestType = nil;
        }
        transport.temperatureZone = [serverData stringForKey:@"temp_zone"];
        transport.stagingArea = [serverData stringForKey:@"stagingarea"];
        if ([serverData objectForKey:@"staginginfo"]) {
            NSString *tmpStagingInfo = [NSString stringWithFormat:@"%@", [serverData objectForKey:@"staginginfo"]];
            if ([tmpStagingInfo isEqualToString:@"N"])
                transport.stagingInfo      = @"🚩";
            else if ([tmpStagingInfo isEqualToString:@"R"])
                transport.stagingInfo      = @"🍞";
            else if ([tmpStagingInfo isEqualToString:@"S"])
                transport.stagingInfo      = @"🌱";
            else if ([tmpStagingInfo isEqualToString:@"B"])
                transport.stagingInfo      = @"🍌";
            else if ([tmpStagingInfo isEqualToString:@"T"])
                transport.stagingInfo      = @"⛄";
            else
                transport.stagingInfo = nil;
        } else {
            transport.stagingInfo = nil;
        }
        if ([serverData objectForKey:@"transportpackagingisrelevantfortransportation"] || PFBrandingSupported(BrandingBiopartner, nil)) {
            transport.transport_packaging_id = [Transport_Packaging transportPackagingWithServerData:serverData inCtx:aCtx];
        } else {
            transport.transport_packaging_id = nil;
        }
        transport.pickUpDocumentNumber = [serverData stringForKey:@"pickup_doc_number"];
        transport.deliveryDocumentNumber = [serverData stringForKey:@"delivery_doc_number"];
		//		transport.term_id		   = [Term		termWithTransportData:serverData          inCtx:aCtx];
        NSNumber *enforceTraceTypeId = [serverData objectForKey:@"enforce_trace_type_id"];
        if ([enforceTraceTypeId integerValue] > 0) {
            NSDictionary *cargoDataX = [serverData dictionaryByAddingEntriesFromDictionary:@{ @"trace_type_id" : enforceTraceTypeId}];
            transport.trace_type_id	= [Trace_Type trace_TypeWithTransportData:cargoDataX inCtx:aCtx];
        }
	} else {
		NSLog(@"ERROR Transport transportWithServerData:  %@ %@", error, [error userInfo]);
	}
	return transport;
}

+ (Transport *)transportWithDictionaryData:(NSDictionary *)dictionaryData inCtx:(NSManagedObjectContext *)aCtx {
	Transport *transport     = nil;
	NSError   *error	     = nil;
    NSString  *transportCode = [dictionaryData valueForKey:@"code"];
    
    NSRange  barCodeTrailerRange = [Transport rangeOfTrailerFromBarcode:transportCode];
	if (barCodeTrailerRange.location != NSNotFound) {
		transportCode = [transportCode substringToIndex:barCodeTrailerRange.location];
	}
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Transport class]) inManagedObjectContext:aCtx];
    
    NSPredicate *traceTypePredicate = nil;
    if (PFBrandingSupported(BrandingTechnopark, nil) && [dictionaryData valueForKey:@"loading_operation"] != nil)
    {
        NSString *traceType;
        
        if ([[dictionaryData valueForKey:@"loading_operation"]  isEqual: @YES])
            traceType = TraceTypeStringUnload;
        else
            traceType = TraceTypeStringLoad;
        
        traceTypePredicate = [NSPredicate predicateWithFormat:@"trace_type_id.code = %@", traceType];
    }
    
	db_handle.predicate    = AndPredicates([Transport withCodes:@[transportCode]],[Transport withTransportGroupId:[dictionaryData valueForKey:@"transport_group_id"]],traceTypePredicate, nil);
	
	// lastObject returns nil, if no data in db_handle
    NSArray *trArray = [aCtx executeFetchRequest:db_handle error:&error];
    transport				   = [trArray lastObject];
    
    if (!transport && PFBrandingSupported(BrandingTechnopark, nil))
    {
        db_handle.predicate = AndPredicates([Transport withMaskedCode],[Transport withTransportGroupId:[dictionaryData valueForKey:@"transport_group_id"]],traceTypePredicate, nil);
        trArray = [aCtx executeFetchRequest:db_handle error:&error];
                
        if (trArray.count > 0)
        {
            unichar buffer[transportCode.length];
            [transportCode getCharacters:buffer range:NSMakeRange(0, transportCode.length)];
            
            for (Transport* currTransport in trArray) {
                
                NSRange currCodeRange = {.location = 2, .length = currTransport.code.length-4};
                NSString *currTransportCode = [currTransport.code substringWithRange:currCodeRange];
                
                if (currTransportCode.length != transportCode.length) continue;
                
                BOOL mismatchFound = NO;
                
                unichar currentMaskBuffer[currTransportCode.length];
                [currTransportCode getCharacters:currentMaskBuffer range:NSMakeRange(0, currTransportCode.length)];
                
                for (int i = 0; i < currTransportCode.length; ++i) {
                    unichar currentChar     = currentMaskBuffer[i];
                    if (currentChar == '*')
                        continue;
                    unichar currentCodeChar = buffer[i];
                    mismatchFound = (currentChar != currentCodeChar);
                    
                    if (mismatchFound)
                        break;
                }
                
                if (!mismatchFound)
                {
                    transport = currTransport;
                    break;
                }

            }
        }
    }
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"www" message:[NSString stringWithFormat:@"%d", trArray.count] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    //[alert show];
	
	if (!error) {
		if (!transport) {
			// INSERT new Object (db_handle returns nil without an error)
			transport = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Transport class]) inManagedObjectContext:aCtx];
            transport.transport_id = [NSUserDefaults nextTransportId];
		}
		// UPDATE properties for existing Object
		transport.code					= [NSString stringWithFormat:@",%@,", transportCode];
		transport.tour_id				= [Tour		 tourWithTransportData:dictionaryData             inCtx:aCtx];
        Trace_Type *prv_Trace_Type      = nil;
        if (transport.trace_type_id) {
            prv_Trace_Type              = transport.trace_type_id;
        }
        if ([dictionaryData valueForKey:@"trace_type_id"] && [[dictionaryData valueForKey:@"trace_type_id"] isEqual:[NSNumber numberWithInt:TraceTypeValueMissing]]) {
            transport.trace_type_id		= nil;
            [dictionaryData setValue:[NSNumber numberWithInt:TraceTypeValueUnload] forKey:@"trace_type_id"];
        } else {
            transport.trace_type_id		= [Trace_Type trace_TypeWithTransportData:dictionaryData      inCtx:aCtx];
        }
		if ([dictionaryData objectForKey:@"isPallet"]) {
			transport.isPallet	        = [dictionaryData objectForKey:@"isPallet"];
		}
        if ([dictionaryData objectForKey:@"price"]) {
			transport.price             = [NSDecimalNumber decimalNumberWithString:[dictionaryData valueForKey:@"price"]];
		}
        if ([transport.occurrences intValue] == 0) {
            transport.to_location_id	= [Location   locationWithTransportDestination:dictionaryData inCtx:aCtx];
        }
        if ([dictionaryData objectForKey:@"occurrences"]) {
            transport.occurrences       = [NSNumber numberWithInt:([transport.occurrences intValue] + [[dictionaryData objectForKey:@"occurrences"] intValue])];
            if ([transport.occurrences intValue] == 0) {
                transport.occurrences   = nil;
            }
		} else {
            transport.occurrences       = nil;
        }
		if (!transport.from_location_id && [dictionaryData objectForKey:@"from_location"]) {
			transport.from_location_id  = [Location  locationWithTransportOrigin:dictionaryData       inCtx:aCtx];
		}
		if ([dictionaryData objectForKey:@"from_departure"]) {
			transport.from_departure_id	= [Departure departureWithTransportData:dictionaryData        inCtx:aCtx];
		}
        if ([dictionaryData objectForKey:@"task"]) {
			transport.transport_group_id = [Transport_Group transport_GroupWithTransportData:dictionaryData inCtx:aCtx];
		}
        if ([dictionaryData objectForKey:@"itemID"]) {
			transport.item_id            = [Item itemWithItemID:[dictionaryData objectForKey:@"itemID"] inCtx:aCtx];
            if ([dictionaryData objectForKey:@"quantity"]) {
                transport.itemQTY        = [NSNumber numberWithInt:[[dictionaryData objectForKey:@"quantity"] intValue]];
            } else {
                transport.itemQTY        = [NSNumber numberWithInt:1];
            }
            transport.itemQTYUnit        = transport.item_id.salesUnitCode;
		}
        NSString *transportBoxCode = [dictionaryData objectForKey:@"transportBox"];
        if (transportBoxCode) {
            transport.transport_box_id   = [Transport_Box transport_boxWithBarCode:transportBoxCode inCtx:aCtx];
		}
        transport.final_destination_id = [Location withID:[dictionaryData valueForKey:@"final_destination_id"] inCtx:aCtx];
		//		transport.term_id		   = [Term		termWithTransportData:dictionaryData          inCtx:aCtx];
		
		NSMutableDictionary *traceData = [NSMutableDictionary dictionaryWithDictionary:dictionaryData];
		[traceData setValue:transport.transport_id     forKey:@"transport_id"];
		[traceData setValue:transport.isPallet         forKey:@"isPallet"];
		[traceData setValue:transport.from_location_id forKey:@"from_location"];
        [traceData setValue:[dictionaryData valueForKey:@"userInfo"]          forKey:@"userInfo"];
		[Trace_Log traceLogWithTraceData:traceData inCtx:aCtx];
        if (prv_Trace_Type && [transport.occurrences intValue] != 0) {
            transport.trace_type_id    = prv_Trace_Type;
        }
        if ([dictionaryData objectForKey:@"itemID"] &&
            transport.item_id && [transport.item_id.itemCategoryCode isEqualToString:@"1"] && PFBrandingSupported(BrandingCCC_Group, nil)) {
            transport.trace_type_id    = nil;
        }
	} else {
		NSLog(@"ERROR Transport transportWithDictionaryData:  %@ %@", error, [error userInfo]);
	}
	return transport;
}

+ (Transport *)transportWithTraceData:(NSDictionary *)traceData inCtx:(NSManagedObjectContext *)aCtx {
	Transport *transport  = nil;
	NSError   *error	  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Transport class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"transport_id = %i", [[traceData valueForKey:@"transport_id"]intValue]];
	
	// lastObject returns nil, if no data in db_handle
	transport				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!transport) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_072", @"Trace-Informationen speichern")
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_035", @"ACHTUNG: Es wurden keine Daten für Transport-ID %@ gefunden. "
                                                                                  "Die T&T-Daten werden unvollständig gespeichert und an die Zentrale übermittelt!"),
									  [traceData valueForKey:@"transport_id"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	} else {
		NSLog(@"ERROR Transport transportWithTraceData:  %@ %@", error, [error userInfo]);
	}
	return transport;
}

+ (Transport *)transportWithCargoData:(NSDictionary *)cargoData inCtx:(NSManagedObjectContext *)aCtx {
	Transport *transport     = nil;
	NSError   *error	     = nil;
    NSString  *transportCode = [cargoData valueForKey:@"code"];
    
    NSRange  barCodeTrailerRange = [Transport rangeOfTrailerFromBarcode:transportCode];
	if (barCodeTrailerRange.location != NSNotFound) {
		transportCode = [transportCode substringToIndex:barCodeTrailerRange.location];
	}
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Transport class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [Transport withCodes:@[transportCode]];
	
	// lastObject returns nil, if no data in db_handle
	transport				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!transport) {
			// INSERT new Object (db_handle returns nil without an error)
			transport = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Transport class]) inManagedObjectContext:aCtx];
            transport.transport_id = [NSUserDefaults nextTransportId];
		}
		// UPDATE properties for existing Object
		transport.code					= [NSString stringWithFormat:@"%@", transportCode];
        if ([cargoData objectForKey:@"is_pallet"]) {
			transport.isPallet	        = [cargoData objectForKey:@"is_pallet"];
		}
        transport.occurrences       = [cargoData objectForKey:@"occurrences"];
        //	transport.term_id		    = [Term		termWithTransportData:dictionaryData       inCtx:aCtx];
        transport.tour_id				= [Tour		tourWithCargoData:cargoData                inCtx:aCtx];
        transport.to_location_id		= [Location locationWithTransportDestination:cargoData inCtx:aCtx];
        NSMutableDictionary *cargoDataX = [NSMutableDictionary dictionaryWithDictionary:cargoData];
		[cargoDataX setObject:[NSNumber numberWithInt:TraceTypeValueLoad]               forKey:@"trace_type_id"];
		transport.trace_type_id			= [Trace_Type trace_TypeWithTransportData:cargoDataX     inCtx:aCtx];
	} else {
		NSLog(@"ERROR Transport transportWithCargoData:  %@ %@", error, [error userInfo]);
	}
	return transport;
}

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
    return [Transport transportsWithPredicate:aPredicate sortDescriptors:nil inCtx:aCtx];
}

+ (NSArray  *)transportsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *transports = nil;
	NSError  *error  = nil;
	//NSLog(@"Transport SELECT for %@", [aPredicate predicateFormat]);
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([Transport class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
	// db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	transports				   = [aCtx executeFetchRequest:db_handle error:&error];
	return transports;
}

+ (Location *)destinationForTransportCode:(NSString *)aTransportCode inCtx:(NSManagedObjectContext *)aCtx {
	Location *location                = nil;
	NSString *equivalentTransportCode = @"?";
    NSRange   barCodeTrailerRange = [Transport rangeOfTrailerFromBarcode:aTransportCode];
	if (barCodeTrailerRange.location != NSNotFound) {
		equivalentTransportCode = [aTransportCode substringToIndex:barCodeTrailerRange.location];
	}
	location = [[[self transportsWithPredicate:[NSPredicate predicateWithFormat:@"(code = %@ OR code = %@) && trace_type_id.code = %@",
												aTransportCode, equivalentTransportCode, TraceTypeStringLoad]
							   sortDescriptors:nil inCtx:aCtx] valueForKeyPath:@"to_location_id"] lastObject];
	return location;
}

+ (Location *) destinationFromBarcode:(NSString *) barcode inCtx:(NSManagedObjectContext *) aCtx {
    NSString *correctedBarcode = [Transport replaceAliasFromTransportCode:barcode ctx:aCtx];
    
    NSRange  barCodeTrailerRange;
    Location *tourLocation = nil;
    
    barCodeTrailerRange = [Transport rangeOfTrailerPattern:@"(\\$C\\$|\\$c\\$)" fromBarcode:correctedBarcode];
    if (barCodeTrailerRange.location != NSNotFound) {
        NSString *code = [correctedBarcode substringFromIndex:(barCodeTrailerRange.location + barCodeTrailerRange.length)];
        tourLocation = [Location withCode:code inCtx:aCtx];
    } else {
        barCodeTrailerRange = [Transport rangeOfTrailerPattern:@"(\\$I\\$|\\$i\\$)" fromBarcode:correctedBarcode];
        if (barCodeTrailerRange.location != NSNotFound) {
            NSString *code = [correctedBarcode substringFromIndex:(barCodeTrailerRange.location + barCodeTrailerRange.length)];
            tourLocation = [Location withID:@([code intValue]) inCtx:aCtx];
        }
    }
    
    return tourLocation;
}

+ (NSDecimalNumber *)transportsOpenPriceForTourLocation:(NSNumber *)aLocationID
                                         transportGroup:(NSNumber *)aTransportGroup
                                 inCtx:(NSManagedObjectContext *)aCtx {
    NSDecimalNumber *price = [NSDecimalNumber zero];
    NSArray  *records;
    // price per delivery
    records = [NSArray arrayWithArray:[[NSSet setWithArray:[
                [self transportsWithPredicate:[NSPredicate predicateWithFormat:
                        @"transport_group_id != nil && "
                         "to_location_id.location_id = %lld && "
                         "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && trace_type_id.code != %@ && "
                         "!(trace_type_id.trace_type_id >= 80))",
                         [aLocationID longLongValue],               TraceTypeStringLoad,                  @"UNLOAD",               TraceTypeStringUntouched]
                              sortDescriptors:nil inCtx:aCtx]
                                                            valueForKeyPath:@"transport_group_id"]] allObjects]];
    for (Transport_Group *collectOnDelivery in records) {
        if (!aTransportGroup || [collectOnDelivery.transport_group_id isEqualToNumber:aTransportGroup]) {
            price = [price decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[collectOnDelivery.price decimalValue]]];
        }
	}
    // price per item
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        records = [self transportsWithPredicate:[NSPredicate predicateWithFormat:
                        @"(transport_group_id != nil AND (transport_group_id.price = nil OR transport_group_id.price = 0.00)) && "
                         "price != nil && price != 0.00 && "
                         "item_id.itemCategoryCode = \"3\" && "
                         "to_location_id.location_id = %lld", [aLocationID longLongValue]]
                                sortDescriptors:nil inCtx:aCtx];
    } else {
        records = [self transportsWithPredicate:[NSPredicate predicateWithFormat:
                        @"(transport_group_id = nil OR transport_group_id.price = nil OR transport_group_id.price = 0.00) && "
                         "price != nil && price != 0.00 && "
                         "to_location_id.location_id = %lld && "
                         "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && trace_type_id.code != %@ && "
                         "!(trace_type_id.trace_type_id >= 80))",
                         [aLocationID longLongValue],               TraceTypeStringLoad,                  @"UNLOAD",               TraceTypeStringUntouched]
                                sortDescriptors:nil inCtx:aCtx];
    }
    for (Transport *cashFlow in records) {
        if (!aTransportGroup || [cashFlow.transport_group_id.transport_group_id isEqualToNumber:aTransportGroup]) {
            price = [price decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[cashFlow.price decimalValue]]];
        }
	}
    // price for TEST ONLY !!!
    // price = [price decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:@"566.07"]];
    records = [self transportsWithPredicate:[NSPredicate predicateWithFormat:
                                             @"from_location_id.location_id = %lld && trace_type_id.code = %@",
                                             [aLocationID longLongValue],                 @"PAYMENTONDELIVERY"]
                            sortDescriptors:nil inCtx:aCtx];
    for (Transport *cashFlow in records) {
        if (!aTransportGroup || [cashFlow.transport_group_id.transport_group_id isEqualToNumber:aTransportGroup]) {
            price = [price decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[cashFlow.price decimalValue]]];
        }
	}
    return price;
}

+ (NSInteger )transportsCount:(NSArray *)transports {
    if (transports) {
        NSInteger sum = 0;
        for (Transport *tmp in transports) {
            if (tmp.item_id && tmp.itemQTY && [tmp.itemQTY intValue] != 0) {
                sum += [tmp.itemQTY intValue];
            } else if (!tmp.occurrences) {
                sum += 1;
            } else {
                sum += [tmp.occurrences intValue];
            }
        }
		return sum;
	}
	return 0;
}

+ (NSInteger) countOf:(TransportTypes)types forTourDeparture:(Departure *)departure ctx:(NSManagedObjectContext *)ctx {
    return [Transport countOf:types forTourLocation:departure.location_id.location_id transportGroup:departure.transport_group_id.transport_group_id ctx:ctx];
}

+ (NSInteger) countOf:(TransportTypes)types forTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup ctx:(NSManagedObjectContext *)ctx {
    NSInteger total = 0;
    if ((types & Unit) > 0) {
        total += [Transport transportsUnitCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & OpenUnit) > 0) {
        total += [Transport transportsOpenUnitCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & TransportationUnit) > 0) {
        total += [Transport transportsTransportationUnitCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & Pallet) > 0) {
        total += [Transport transportsPalletCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & OpenPallet) > 0) {
        total += [Transport transportsOpenPalletCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & TransportationPallet) > 0) {
        total += [Transport transportsTransportationPalletCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & RollContainer) > 0) {
        total += [Transport transportsRollContainerCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & OpenRollContainer) > 0) {
        total += [Transport transportsOpenRollContainerCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & TransportationRollContainer) > 0) {
        total += [Transport transportsTransportationRollContainerCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & Pick) > 0) {
        total += [Transport transportsPickCountForTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }

    return total;
}

+ (NSInteger) countOf:(TransportTypes)types fromTourDeparture:(Departure *)departure ctx:(NSManagedObjectContext *)ctx {
    return [Transport countOf:types fromTourLocation:departure.location_id.location_id transportGroup:departure.transport_group_id.transport_group_id ctx:ctx];
}

+ (NSInteger) countOf:(TransportTypes)types fromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup ctx:(NSManagedObjectContext *)ctx {
    NSInteger total = 0;
    if ((types & Unit) > 0) {
        total += [Transport transportsUnitCountFromTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & Pallet) > 0) {
        total += [Transport transportsPalletCountFromTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }
    if ((types & RollContainer) > 0) {
        total += [Transport transportsRollContainerCountFromTourLocation:aLocationID transportGroup:aTransportGroup inCtx:ctx];
    }    
    return total;
}

+ (NSInteger )transportsOpenPalletCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"to_location_id.location_id = %lld && "
                              "(item_id = nil && isPallet = YES OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"PAL\") && "
                              "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80))",
                              [aLocationID longLongValue], TraceTypeStringLoad, TraceTypeStringUntouched];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (NSInteger )transportsOpenRollContainerCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"to_location_id.location_id = %lld && "
                              "(isPallet = nil OR isPallet = NO) && "
                              "(item_id != nil AND item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"RCT\") && "
                              "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80))",
                              [aLocationID longLongValue], TraceTypeStringLoad, TraceTypeStringUntouched];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (NSInteger )transportsOpenUnitCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"to_location_id.location_id = %lld && "
                              "(isPallet = nil OR isPallet = NO) && "
                              "(item_id = nil OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode != \"PAL\" AND item_id.salesUnitCode != \"RCT\") && "
                              "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80))",
                              [aLocationID longLongValue], TraceTypeStringLoad, TraceTypeStringUntouched];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (NSInteger )transportsTransportationPalletCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"to_location_id.location_id = %lld && "
                              "(item_id = nil && isPallet = YES OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"PAL\") && "
                              "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80)) && "
                              "transport_packaging_id.isRelevantForTransportation = YES",
                              [aLocationID longLongValue], TraceTypeStringLoad, TraceTypeStringUntouched];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (NSInteger )transportsTransportationRollContainerCountForTourLocation:(NSNumber *)aLocationID
                                                         transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"to_location_id.location_id = %lld && "
                              "isPallet = NO && "
                              "(item_id != nil AND item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"RCT\") && "
                              "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80)) && "
                              "transport_packaging_id.isRelevantForTransportation = YES",
                              [aLocationID longLongValue], TraceTypeStringLoad, TraceTypeStringUntouched];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (NSInteger )transportsTransportationUnitCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"to_location_id.location_id = %lld && "
                              "isPallet = NO && "
                              "(item_id = nil OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode != \"PAL\" AND item_id.salesUnitCode != \"RCT\") && "
                              "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80)) && "
                              "transport_packaging_id.isRelevantForTransportation = YES",
                              [aLocationID longLongValue], TraceTypeStringLoad, TraceTypeStringUntouched];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (NSDecimalNumber *)transportsPriceForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSDecimalNumber *price = [NSDecimalNumber zero];
    NSArray  *records;
    // price per delivery
    records = [NSArray arrayWithArray:[[NSSet setWithArray:[
                [self transportsWithPredicate:[NSPredicate predicateWithFormat:
                        @"transport_group_id != nil && "
                         "to_location_id.location_id = %lld && (trace_type_id.code = %@ OR trace_type_id.code = %@)",
                         [aLocationID longLongValue],                            TraceTypeStringLoad,                @"UNLOAD"]
                              sortDescriptors:nil inCtx:aCtx]
                                                            valueForKeyPath:@"transport_group_id"]] allObjects]];
    for (Transport_Group *collectOnDelivery in records) {
        if (!aTransportGroup || [collectOnDelivery.transport_group_id isEqualToNumber:aTransportGroup]) {
            price = [price decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[collectOnDelivery.price decimalValue]]];
        }
	}
    // price per item
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        records = [self transportsWithPredicate:[NSPredicate predicateWithFormat:
                            @"(transport_group_id != nil AND (transport_group_id.price = nil OR transport_group_id.price = 0.00)) && "
                             "price != nil && price != 0.00 && "
                             "item_id.itemCategoryCode = \"3\" && "
                             "to_location_id.location_id = %lld", [aLocationID longLongValue]]
                                sortDescriptors:nil inCtx:aCtx];
    } else {
        records = [self transportsWithPredicate:[NSPredicate predicateWithFormat:
                            @"(transport_group_id = nil OR transport_group_id.price = nil OR transport_group_id.price = 0.00) && "
                             "price != nil && price != 0.00 && "
                             "to_location_id.location_id = %lld && (trace_type_id.code = %@ OR trace_type_id.code = %@)",
                             [aLocationID longLongValue],                             TraceTypeStringLoad,                @"UNLOAD"]
                                sortDescriptors:nil inCtx:aCtx];
    }
    for (Transport *collectPerItem in records) {
        if (!aTransportGroup || [collectPerItem.transport_group_id.transport_group_id isEqualToNumber:aTransportGroup]) {
            price = [price decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[collectPerItem.price decimalValue]]];
        }
	}
    // collected amount of money
    records = [self transportsWithPredicate:[NSPredicate predicateWithFormat:
                                             @"from_location_id.location_id = %lld && trace_type_id.code = %@",
                                             [aLocationID longLongValue],                 @"PAYMENTONDELIVERY"]
                            sortDescriptors:nil inCtx:aCtx];
    for (Transport *cashFlow in records) {
        if (!aTransportGroup || [cashFlow.transport_group_id.transport_group_id isEqualToNumber:aTransportGroup]) {
            price = [price decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[cashFlow.price decimalValue]]];
        }
	}
    return price;
}

+ (NSInteger )transportsPalletCountForTourLocation:(NSNumber *)aLocationID
                                    transportGroup:(NSNumber *)aTransportGroup
                            inCtx:(NSManagedObjectContext *)aCtx {
    if (!aTransportGroup) {
        NSInteger count = 0;
        NSArray *pickupOnly = [self withPredicate:[NSPredicate predicateWithFormat:
                                                   @"transport_group_id != nil && "
                                                   "transport_group_id.addressee_id != nil && "
                                                   "transport_group_id.addressee_id.location_id != %lld && "
                                                   "transport_group_id.pickUpAction != nil && "
                                                   "transport_group_id.deliveryAction = nil && "
                                                   "to_location_id.location_id = transport_group_id.addressee_id.location_id && "
                                                   "(item_id = nil && isPallet = YES OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"PAL\") && "
                                                   "trace_type_id.code = %@", [aLocationID longLongValue], TraceTypeStringLoad]
                                            inCtx:aCtx];
        if ([((Departure *)[[[[[pickupOnly lastObject] valueForKeyPath:@"tour_id.departure_id"] allObjects] sortedArrayUsingDescriptors:
                             [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES]]]
                            lastObject]).location_id.location_id isEqualToNumber:aLocationID]) {
            count = [self transportsCount:pickupOnly];
            PFDebugLog(@"transportsPalletCountForTourLocation pickupOnly *LAST %i", count);
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"to_location_id.location_id = %lld && "
                                  "(item_id = nil && isPallet = YES OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"PAL\") && "
                                  "trace_type_id.code = %@",
                                  [aLocationID longLongValue], TraceTypeStringLoad];
        return count + [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
    } else {
        Transport_Group *tmpTransportGroup = [[Transport_Group withPredicate:[NSPredicate predicateWithFormat:
                                                                                              @"transport_group_id = %lld", [aTransportGroup longLongValue]]
                                                                             sortDescriptors:nil
                                                                      inCtx:aCtx] lastObject];
        NSNumber *lastLocation = ((Departure *)[[[((Transport *)[tmpTransportGroup.transport_id anyObject]).tour_id.departure_id allObjects]
                                                 sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                                              [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES]]]
                                                lastObject]).location_id.location_id;
        if (tmpTransportGroup.addressee_id && ![aLocationID isEqualToNumber:tmpTransportGroup.addressee_id.location_id] &&
            tmpTransportGroup.pickUpAction && !tmpTransportGroup.deliveryAction && [aLocationID isEqualToNumber:lastLocation]) {
            aLocationID = tmpTransportGroup.addressee_id.location_id;
        }
        NSPredicate *p = [NSPredicate predicateWithFormat:
                          @"to_location_id.location_id = %lld && "
                          "(item_id = nil && isPallet = YES OR  item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"PAL\") && "
                          "trace_type_id.code = %@",
                          [aLocationID longLongValue], TraceTypeStringLoad];
        return [self transportsCount:[[tmpTransportGroup.transport_id allObjects] filteredArrayUsingPredicate:p]];
    }
}

+ (NSInteger )transportsRollContainerCountForTourLocation:(NSNumber *)aLocationID
                                           transportGroup:(NSNumber *)aTransportGroup
                                   inCtx:(NSManagedObjectContext *)aCtx {
    if (!aTransportGroup) {
        NSInteger count = 0;
        NSArray *pickupOnly = [self withPredicate:[NSPredicate predicateWithFormat:
                                                             @"transport_group_id != nil && "
                                                             "transport_group_id.addressee_id != nil && "
                                                             "transport_group_id.addressee_id.location_id != %lld && "
                                                             "transport_group_id.pickUpAction != nil && "
                                                             "transport_group_id.deliveryAction = nil && "
                                                             "to_location_id.location_id = transport_group_id.addressee_id.location_id && "
                                                             "isPallet = NO && "
                                                             "(item_id != nil AND item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"RCT\") && "
                                                             "trace_type_id.code = %@", [aLocationID longLongValue], TraceTypeStringLoad]
                                            inCtx:aCtx];
        if ([((Departure *)[[[[[pickupOnly lastObject] valueForKeyPath:@"tour_id.departure_id"] allObjects] sortedArrayUsingDescriptors:
                             [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES]]]
                            lastObject]).location_id.location_id isEqualToNumber:aLocationID]) {
            count = [self transportsCount:pickupOnly];
            PFDebugLog(@"transportsRollContainerCountForTourLocation pickupOnly *LAST %i", count);
        }
        return count + [self transportsCount:[self withPredicate:[NSPredicate predicateWithFormat:
                                                                   @"to_location_id.location_id = %lld && "
                                                                   "isPallet = NO && "
                                                                   "(item_id != nil AND item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"RCT\") && "
                                                                   "trace_type_id.code = %@",
                                                                   [aLocationID longLongValue], TraceTypeStringLoad]
                                                           inCtx:aCtx]];
    } else {
        Transport_Group *tmpTransportGroup = [[Transport_Group withPredicate:[NSPredicate predicateWithFormat:
                                                                                              @"transport_group_id = %lld", [aTransportGroup longLongValue]]
                                                                             sortDescriptors:nil inCtx:aCtx] lastObject];
        NSNumber *lastLocation = ((Departure *)[[[((Transport *)[tmpTransportGroup.transport_id anyObject]).tour_id.departure_id allObjects]
                                                 sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                                              [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES]]]
                                                lastObject]).location_id.location_id;
        if (tmpTransportGroup.addressee_id && ![aLocationID isEqualToNumber:tmpTransportGroup.addressee_id.location_id] &&
            tmpTransportGroup.pickUpAction && !tmpTransportGroup.deliveryAction && [aLocationID isEqualToNumber:lastLocation]) {
            aLocationID = tmpTransportGroup.addressee_id.location_id;
        }
        return [self transportsCount:[[tmpTransportGroup.transport_id allObjects]
                                      filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                                                   @"to_location_id.location_id = %lld && "
                                                                   "isPallet = NO && "
                                                                   "(item_id != nil AND item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"RCT\") && "
                                                                   "trace_type_id.code = %@",
                                                                   [aLocationID longLongValue], TraceTypeStringLoad]]];
    }
}

+ (NSInteger )transportsUnitCountForTourLocation:(NSNumber *)aLocationID
                                  transportGroup:(NSNumber *)aTransportGroup
                          inCtx:(NSManagedObjectContext *)aCtx {
    if (!aTransportGroup) {
        NSInteger count = 0;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"transport_group_id != nil && "
                                  "transport_group_id.addressee_id != nil && "
                                  "transport_group_id.addressee_id.location_id != %lld && "
                                  "transport_group_id.pickUpAction != nil && "
                                  "transport_group_id.deliveryAction = nil && "
                                  "to_location_id.location_id = transport_group_id.addressee_id.location_id && "
                                  "isPallet = NO && "
                                  "(item_id = nil OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode != \"PAL\" AND item_id.salesUnitCode != \"RCT\") && "
                                  "trace_type_id.code = %@", [aLocationID longLongValue], TraceTypeStringLoad];
        NSArray *pickupOnly = [self withPredicate:predicate inCtx:aCtx];
        if ([((Departure *)[[[[[pickupOnly lastObject] valueForKeyPath:@"tour_id.departure_id"] allObjects] sortedArrayUsingDescriptors:
                             [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES]]]
                            lastObject]).location_id.location_id isEqualToNumber:aLocationID]) {
            count = [self transportsCount:pickupOnly];
            PFDebugLog(@"transportsUnitCountForTourLocation pickupOnly *LAST %i", count);
        }
        NSPredicate *p = [NSPredicate predicateWithFormat:
                          @"to_location_id.location_id = %lld && "
                          "isPallet = NO && "
                          "(item_id = nil OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode != \"PAL\" AND item_id.salesUnitCode != \"RCT\") && "
                          "trace_type_id.code = %@",
                          [aLocationID longLongValue], TraceTypeStringLoad];
        return count + [self transportsCount:[self withPredicate:p inCtx:aCtx]];
    } else {
        Transport_Group *tmpTransportGroup = [[Transport_Group withPredicate:[NSPredicate predicateWithFormat:
                                                                                              @"transport_group_id = %lld", [aTransportGroup longLongValue]]
                                                                             sortDescriptors:nil
                                                                      inCtx:aCtx] lastObject];
        NSNumber *lastLocation = ((Departure *)[[[((Transport *)[tmpTransportGroup.transport_id anyObject]).tour_id.departure_id allObjects]
                                                 sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                                              [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES]]]
                                                lastObject]).location_id.location_id;
        if (tmpTransportGroup.addressee_id && ![aLocationID isEqualToNumber:tmpTransportGroup.addressee_id.location_id] &&
            tmpTransportGroup.pickUpAction && !tmpTransportGroup.deliveryAction && [aLocationID isEqualToNumber:lastLocation]) {
            aLocationID = tmpTransportGroup.addressee_id.location_id;
        }
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
            return [self transportsCount:[[tmpTransportGroup.transport_id allObjects]
                                      filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                                                   @"to_location_id.location_id = %lld && "
                                                                   //"isPallet = NO && "
                                                                   //"(item_id = nil OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode != \"PAL\" AND item_id.salesUnitCode != \"RCT\") && "
                                                                   "trace_type_id.code = %@ &&"
                                                                   "code != ',,'",
                                                                   [aLocationID longLongValue],
                                                                   TraceTypeStringLoad]]];
        else
            return [self transportsCount:[[tmpTransportGroup.transport_id allObjects]
                                          filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                                                       @"to_location_id.location_id = %lld && "
                                                                       "isPallet = NO && "
                                                                       "(item_id = nil OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode != \"PAL\" AND item_id.salesUnitCode != \"RCT\") && "
                                                                       "trace_type_id.code = %@",
                                                                       [aLocationID longLongValue], TraceTypeStringLoad]]];
    }
}

+ (NSInteger )transportsPickCountForTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"from_location_id.location_id = %lld && "
                              "(to_location_id = nil OR to_location_id.location_id != from_location_id.location_id) && "
                              "(item_id = nil OR item_id.itemCategoryCode = \"2\") && "
                              "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80))",
                              [aLocationID longLongValue], @"UNLOAD", TraceTypeStringLoad, TraceTypeStringUntouched];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (NSDecimalNumber *)transportsPriceFromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    return [NSDecimalNumber decimalNumberWithString:@"0.00"];
}

+ (NSInteger )transportsPalletCountFromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"from_location_id.location_id = %lld && "
                              "(item_id = nil && isPallet = YES OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"PAL\") && "
                              "trace_type_id.code = %@",
                              [aLocationID longLongValue], TraceTypeStringLoad];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (NSInteger )transportsRollContainerCountFromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"from_location_id.location_id = %lld && "
                              "isPallet = NO && "
                              "(item_id != nil AND item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode = \"RCT\") && "
                              "trace_type_id.code = %@",
                              [aLocationID longLongValue], TraceTypeStringLoad];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (NSInteger )transportsUnitCountFromTourLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"from_location_id.location_id = %lld && "
                              "isPallet = NO && "
                              "(item_id = nil OR item_id.itemCategoryCode = \"2\" AND item_id.salesUnitCode != \"PAL\" AND item_id.salesUnitCode != \"RCT\") && "
                              "trace_type_id.code = %@",
                              [aLocationID longLongValue], TraceTypeStringLoad];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    return [self transportsCount:[self withPredicate:predicate inCtx:aCtx]];
}

+ (BOOL )shouldUnloadTransportCode:(NSString *)aTransportCode atLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
                             inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = AndPredicates([Transport withCodes:@[aTransportCode]],
                                           [Transport withTraceLogCodes:@[TraceTypeStringLoad]],
                                           [Transport withToLocationId:aLocationID], nil);
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    NSArray *records = [self withPredicate:predicate inCtx:aCtx];
    
    if ((!records || records.count == 0) && PFBrandingSupported(BrandingTechnopark, nil))
    {
        NSPredicate* maskPredicate = AndPredicates([Transport withMaskedCode],
                                                   [Transport withTraceLogCodes:@[TraceTypeStringLoad]],
                                                   [Transport withToLocationId:aLocationID],
                                                   [Transport withTransportGroupId:aTransportGroup],nil);
        NSArray* trArray = [self withPredicate:maskPredicate inCtx:aCtx];
        
        if (trArray.count > 0)
        {
            unichar buffer[aTransportCode.length];
            [aTransportCode getCharacters:buffer range:NSMakeRange(0, aTransportCode.length)];
            
            for (Transport* currTransport in trArray) {
                
                NSRange currCodeRange = {.location = 2, .length = currTransport.code.length-4};
                NSString *currTransportCode = [currTransport.code substringWithRange:currCodeRange];
                
                if (currTransportCode.length != aTransportCode.length) continue;
                
                BOOL mismatchFound = NO;
                
                unichar currentMaskBuffer[currTransportCode.length];
                [currTransportCode getCharacters:currentMaskBuffer range:NSMakeRange(0, currTransportCode.length)];
                
                for (int i = 0; i < currTransportCode.length; ++i) {
                    unichar currentChar     = currentMaskBuffer[i];
                    if (currentChar == '*')
                        continue;
                    unichar currentCodeChar = buffer[i];
                    mismatchFound = (currentChar != currentCodeChar);
                    
                    if (mismatchFound)
                        break;
                }
                
                if (!mismatchFound)
                {
                    records = [NSArray arrayWithObject:currTransport];
                    break;
                }
            }
        }

    }
    
	if (records && [records count] != 0) {
		return YES;
	}
	return NO;
}

+ (BOOL )shouldUnloadTransportItems:(NSString *)aTransportCode atLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup
            inCtx:(NSManagedObjectContext *)aCtx
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"code >= %@ AND code <= %@ && trace_type_id.code = %@ && to_location_id.location_id  = %lld",
                              [NSExpression expressionForConstantValue:[aTransportCode stringByAppendingString:@"-"]],
                              [NSExpression expressionForConstantValue:[[aTransportCode stringByAppendingString:@"-"]
                                                                        stringByAppendingString:[NSString stringWithUTF8String:"\uffff"]]],
                              TraceTypeStringLoad, [aLocationID longLongValue]];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    NSArray *records = [self withPredicate:predicate inCtx:aCtx];
	if (records && [records count] != 0) {
		return YES;
	}
	return NO;
}

+ (BOOL )shouldLoadTransportCode:(NSString *)aTransportCode transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
	NSString *equivalentTransportCode = @"?";
    NSRange   barCodeTrailerRange = [Transport rangeOfTrailerFromBarcode:aTransportCode];
	if (barCodeTrailerRange.location != NSNotFound) {
		equivalentTransportCode = [aTransportCode substringToIndex:barCodeTrailerRange.location];
	}
    NSArray *records = [self withPredicate:AndPredicates([Transport withCodes:@[aTransportCode, equivalentTransportCode]],
                                                                   [Transport withTraceLogCodes:@[TraceTypeStringLoad]],
                                                                    [Transport withTransportGroupId:aTransportGroup],nil)
                                               inCtx:aCtx];
    
    BOOL allOccurenciesLoaded = YES;
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        NSArray *allOccurencies = [self withPredicate:AndPredicates([Transport withCodes:@[aTransportCode, equivalentTransportCode]],
                                                                    [Transport withTransportGroupId:aTransportGroup],nil)
                                                inCtx:aCtx];
        allOccurenciesLoaded = (allOccurencies.count == records.count);
    }
    
    if (!allOccurenciesLoaded)
        return YES;
    
	if (records && [records count] != 0) {
		return NO;
	}
	return YES;
}

+ (BOOL )shouldLoadTransportItems:(NSString *)aTransportCode transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
	NSString *equivalentTransportCode = @"?";
    NSRange   barCodeTrailerRange = [Transport rangeOfTrailerFromBarcode:aTransportCode];
	if (barCodeTrailerRange.location != NSNotFound) {
		equivalentTransportCode = [aTransportCode substringToIndex:barCodeTrailerRange.location];
	}
	NSArray *records = [self transportsWithPredicate:[NSPredicate predicateWithFormat:@"((code >= %@ AND code <= %@) OR (code >= %@ AND code <= %@)) &&"
                                                                                        " trace_type_id.code = %@",
                                                      [NSExpression expressionForConstantValue:[aTransportCode stringByAppendingString:@"-"]],
                                                      [NSExpression expressionForConstantValue:[[aTransportCode stringByAppendingString:@"-"]
                                                                                                stringByAppendingString:[NSString stringWithUTF8String:"\uffff"]]],
                                                      [NSExpression expressionForConstantValue:[equivalentTransportCode stringByAppendingString:@"-"]],
                                                      [NSExpression expressionForConstantValue:[[equivalentTransportCode stringByAppendingString:@"-"]
                                                                                                stringByAppendingString:[NSString stringWithUTF8String:"\uffff"]]],
                                                      TraceTypeStringLoad]
									 sortDescriptors:nil inCtx:aCtx];
	if (records && [records count] != 0) {
		return NO;
	}
	return YES;
}

+ (BOOL )hasTransportCodesFromDeparture:(NSNumber *)aDepartureID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [Transport withFromDepartureId:aDepartureID];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    NSArray *records = [self withPredicate:predicate inCtx:aCtx];
	if (records && [records count] != 0) {
		return YES;
	}
	return NO;
}

+ (BOOL )hasTransportUloadCodesFromLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [Transport withFromDepartureLocationId:aLocationID];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    NSArray *records = [self withPredicate:predicate inCtx:aCtx];
	if (records && [records count] != 0) {
		return YES;
	}
	return NO;
}

+ (BOOL )hasReasonCodesFromDeparture:(NSNumber *)aDepartureID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = AndPredicates([NSPredicate predicateWithFormat:@"trace_type_id.trace_type_id > 90"], [Transport withFromDepartureId:aDepartureID], nil);
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    NSArray *records = [self withPredicate:predicate inCtx:aCtx];
	if (records && [records count] != 0) {
		return YES;
	}
	return NO;
}

+ (NSArray *) allInfoSigns {
    return @[@"🚩", @"🍞", @"🌱", @"🍌", @"⛄"];
}

+ (BOOL)hasStagingInfo:(NSString *) food forLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"to_location_id.location_id = %lld && "
                              "stagingInfo = %@ && "
                              "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80))",
                              [aLocationID longLongValue], food, TraceTypeStringLoad, @"UNLOAD"];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    NSArray *records = [self withPredicate:predicate inCtx:aCtx];
    return (records.count > 0);
}

+ (BOOL)hasStagingInfo:(NSString *) food toLocation:(NSNumber *)aLocationID transportGroup:(NSNumber *)aTransportGroup inCtx:(NSManagedObjectContext *)aCtx {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"to_location_id.location_id = %lld && "
                              "stagingInfo = %@ && "
                              "trace_type_id.code = %@",
                              [aLocationID longLongValue], food, TraceTypeStringLoad];
    if (aTransportGroup) {
        predicate = AndPredicates(predicate, [Transport withTransportGroupId:aTransportGroup], nil);
    }
    NSArray *records = [self withPredicate:predicate inCtx:aCtx];
    return (records.count > 0);
}

//FIXME: is it needed?
+ (NSArray   *)coordinateForTransportCode:(NSString *)aTransportCode inCtx:(NSManagedObjectContext *)aCtx {
    NSArray  *coordinate  = nil;
    Location *tmpLocation = ((Transport *)[[self withPredicate:[Transport withCode:aTransportCode] inCtx:aCtx] lastObject]).to_location_id;
    if (tmpLocation) {
        coordinate = @[tmpLocation.longitude, tmpLocation.latitude];
    }
    return coordinate;
}

@dynamic code;
@dynamic currency;
@dynamic isPallet;
@dynamic occurrences;
@dynamic price;
@dynamic stagingArea;
@dynamic stagingInfo;
@dynamic transport_id;
@dynamic weight;
@dynamic isCodeNotScannable;
@dynamic isPickUpOnly;
@dynamic requestType;
@dynamic paymentOnPickUp;
@dynamic paymentOnDelivery;
@dynamic netWeight;
@dynamic pickUpDocumentNumber;
@dynamic deliveryDocumentNumber;
@dynamic infoMessage;
@dynamic infoText;
@dynamic temperatureLimit;
@dynamic temperatureZone;
@dynamic itemQTY;
@dynamic itemQTYUnit;
@dynamic requestBarcode;
@dynamic executionFrom;
@dynamic executionUntil;
@dynamic from_departure_id;
@dynamic from_location_id;
@dynamic item_id;
@dynamic payment_type_id;
@dynamic term_id;
@dynamic to_location_id;
@dynamic tour_id;
@dynamic trace_log_id;
@dynamic trace_type_id;
@dynamic transport_box_id;
@dynamic transport_group_id;
@dynamic transport_packaging_id;
@dynamic grouptransport_id;
@dynamic subtransport_id;
@dynamic to_departure_id;
@dynamic final_destination_id;

@end

@implementation Transport (Predicates)

+ (NSPredicate *) withToLocationId:(NSNumber *) toLocationId {
    return [NSPredicate predicateWithFormat:@"to_location_id.location_id = %lld", [toLocationId longLongValue]];
}

+ (NSPredicate *) withToLocation:(Location *) toLocation {
    return [Transport withToLocationId:toLocation.location_id];
}

+ (NSPredicate *) withFromLocation:(Location *) fromLocation {
    return [Transport withFromLocationId:fromLocation.location_id];
}

+ (NSPredicate *) withFromLocationId:(NSNumber *) fromLocationId {
    return [NSPredicate predicateWithFormat:@"from_location_id.location_id = %lld", [fromLocationId longLongValue]];
}

+ (NSPredicate *) withFromDepartureLocationId:(NSNumber *) fromDepartureLocationId {
    return [NSPredicate predicateWithFormat:@"from_departure_id.location_id.location_id = %lld", [fromDepartureLocationId longLongValue]];
}

+ (NSPredicate *) withFromDepartureLocation:(Location *) fromDepartureLocation {
    return [Transport withFromDepartureLocationId:fromDepartureLocation.location_id];
}

+ (NSPredicate *) withTransportGroupId:(NSNumber *) transportGroupId {
    return [NSPredicate predicateWithFormat:@"transport_group_id.transport_group_id = %lld" , [transportGroupId longLongValue]];
}

+ (NSPredicate *) withTransportGroup:(Transport_Group *) transportGroup {
    return [Transport withTransportGroupId:transportGroup.transport_group_id];
}

+ (NSPredicate *) withFromDepartureId:(NSNumber *) fromDepartureId {
    return [NSPredicate predicateWithFormat:@"from_departure_id.departure_id = %lld", [fromDepartureId longLongValue]];
}

+ (NSPredicate *) withFromDeparture:(Departure *) fromDeparture {
    return [Transport withFromDepartureId:fromDeparture.departure_id];
}

+ (NSPredicate *) withoutItem {
    return [NSPredicate predicateWithFormat:@"item_id = nil"];
}

+ (NSPredicate *) withItemsCategoryCodes:(NSArray *) categoryCodesOrNil {
    return [NSPredicate predicateWithFormat:@"item_id.itemCategoryCode IN %@", categoryCodesOrNil];
}

+ (NSPredicate *) withoutTracelogEntries {
    return [NSPredicate predicateWithFormat:@"(SUBQUERY(trace_log_id, $l, $l.trace_log_id != 0).@count == 0)"];
}

+ (NSPredicate *) havingTraceLogEntriesOlderThan:(NSDate *) minDate {
    return [NSPredicate predicateWithFormat:@"(0 != SUBQUERY(trace_log_id, $l, $l.trace_time > %@).@count)", minDate];
}

+ (NSPredicate *) ofTourWithId:(NSNumber *)tourIdOrNil {
    return [NSPredicate predicateWithFormat:@"tour_id.tour_id = %@", tourIdOrNil];
}

+ (NSPredicate *) withCodes:(NSArray *)codes {
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        NSString* plainBarcode = [codes firstObject];
        NSString* borderedCode = [NSString stringWithFormat:@",%@,", plainBarcode];
        return [NSPredicate predicateWithFormat:@"code CONTAINS %@", borderedCode];
    }
    
    return [NSPredicate predicateWithFormat:@"code IN %@", codes];
}

+ (NSPredicate *) withCode:(NSString *)code {
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        NSString* borderedCode = [NSString stringWithFormat:@",%@,", code];
        return [NSPredicate predicateWithFormat:@"code CONTAINS %@", borderedCode];
    }
    
    return [NSPredicate predicateWithFormat:@"code = %@", code];
}

+ (NSPredicate *) withMaskedCode
{
    //Used for Technopark only at the moment.
    
    NSString* regEx = @"^,\\$.*\\$,$";
    return [NSPredicate predicateWithFormat:@"code MATCHES %@", regEx];
}

+ (NSPredicate *) withBoxCode:(NSString *)boxCode {
    return [NSPredicate predicateWithFormat:@"transport_box_id.code = %@", boxCode];
}

+ (NSPredicate *) withTraceLogCodes:(NSArray *)traceLogCodesOrNil {
    return [NSPredicate predicateWithFormat:@"trace_type_id.code IN %@", traceLogCodesOrNil];
}

+ (NSPredicate *) withTraceLogCodeOver80 {
    return [NSPredicate predicateWithFormat:@"trace_type_id.trace_type_id >= 80"];
}

+ (NSPredicate *) havingTraceLog:(BOOL) havingTraceLogEntries withCategoryCodes:(NSArray *) categoryCodes ofTour:(NSNumber *) tourIdOrNil {
    NSPredicate *itemCode1or3 = [Transport withItemsCategoryCodes:categoryCodes];
    NSPredicate *currentTourTransports = [Transport ofTourWithId:tourIdOrNil];
    NSPredicate *traceLogEntries = [Transport withoutTracelogEntries];
    if (havingTraceLogEntries) {
        traceLogEntries = [NSCompoundPredicate notPredicateWithSubpredicate:traceLogEntries];
    }
    return [NSCompoundPredicate andPredicateWithSubpredicates:@[itemCode1or3, currentTourTransports, traceLogEntries]];
}

+ (NSPredicate *) deletableOnEndOfTour {
    // transports
    NSArray *traceTypesToDelete = @[TraceTypeStringUnload, TraceTypeStringUntouched, TraceTypeStringReuseTransportBox];
    NSPredicate *traceTypesPredicate = OrPredicates([Transport withTraceLogCodes:traceTypesToDelete], [Transport withTraceLogCodeOver80], nil);
    NSPredicate *transportsPredicate = AndPredicates(traceTypesPredicate, [Transport withoutTracelogEntries], nil);
    // packaging + services
    NSPredicate *packagingAndServices = [Transport havingTraceLog:NO withCategoryCodes:@[ItemCategoryReturnablePackages, ItemCategoryTransportServices]
                                                           ofTour:[NSUserDefaults currentTourId]];
    return OrPredicates(transportsPredicate, packagingAndServices, nil);
}

@end

@implementation Transport (Validation)

+ (NSString *) trailerFromBarcode:(NSString *) barcode {
    NSString *result = barcode;
    
    NSRange trailerRange = [Transport rangeOfTrailerFromBarcode:barcode];
    if (trailerRange.location != NSNotFound) {
        result = [barcode substringFromIndex:(trailerRange.location + trailerRange.length)];
    }
    return result;
}

+ (NSString *) transportCodeFromBarcode:(NSString *) barcode {
    NSString *result = barcode;
    
    NSRange trailerRange = [Transport rangeOfTrailerFromBarcode:barcode];
    if (trailerRange.location != NSNotFound) {
        result = [barcode substringToIndex:trailerRange.location];
    }
    return result;
}

+ (NSString *) transportDestinationFromBarcode:(NSString *) barcode {
    NSString *result = barcode;
    
    NSRange trailerRange = [Transport rangeOfTrailerFromBarcode:barcode];
    if (trailerRange.location != NSNotFound) {
        result = [barcode substringFromIndex:trailerRange.location + trailerRange.length];
    }
    return result;
}

+ (NSRange) rangeOfTrailerPattern:(NSString *) pattern fromBarcode:(NSString *) barcode {
    if (barcode.length == 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSError *error = nil;
    NSRegularExpression *separatorExpr = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSAssert(separatorExpr, @"Could not compile regex expression. Reason: %@", error);
    
    NSRange searchingRange = NSMakeRange(0, barcode.length);
    NSRange trailerRange = [separatorExpr rangeOfFirstMatchInString:barcode options:0 range:searchingRange];
    
    return trailerRange;
}

+ (NSRange) rangeOfTrailerFromBarcode:(NSString *) barcode {
    if (barcode.length == 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSError *error = nil;
    NSRegularExpression *separatorExpr = [NSRegularExpression regularExpressionWithPattern:@"(\\$;\\$|\\$C\\$|\\$c\\$|\\$I\\$|\\$i\\$)" options:0 error:&error];
    NSAssert(separatorExpr, @"Could not compile regex expression. Reason: %@", error);
    
    NSRange searchingRange = NSMakeRange(0, barcode.length);
    NSRange trailerRange = [separatorExpr rangeOfFirstMatchInString:barcode options:0 range:searchingRange];
    
    return trailerRange;
}

+ (BOOL) validateTransportWithCode:(NSString *) transportCode {
    NSRegularExpression *codeExpr = [Transport transportCodeExpression];
    
    NSRange searchingRange = NSMakeRange(0, transportCode.length);
    NSRange codeRange = [codeExpr rangeOfFirstMatchInString:transportCode options:0 range:searchingRange];
    
    return NSEqualRanges(codeRange, searchingRange);
}

+ (NSRegularExpression *) transportCodeExpression {
    NSError *error = nil;
    NSRegularExpression *transportExpression = [NSRegularExpression regularExpressionWithPattern:@".*" options:0 error:&error];
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        transportExpression = [NSRegularExpression regularExpressionWithPattern:@"S:[A-Z][0-9]{1,7}" options:0 error:&error];
    } else if (PFBrandingSupported(BrandingETA, nil)) {
        transportExpression = [NSRegularExpression regularExpressionWithPattern:@"(H[0-9]{3}.{3}(\\$.{1}\\$.*)?|([^H]|HU).*)" options:0 error:&error];
    }
    NSAssert(transportExpression, @"Could not compile regex expression. Reason: %@", error);
    return transportExpression;
}

+ (BOOL) canPlaceTransportWithCode:(NSString *)sourceTransportCode toTransportWithCode:(NSString *)targetTransportCode {
    BOOL result = YES;
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        result = NO;
        BOOL targetIsValidShippingBagCode = [targetTransportCode hasPrefix:@"T:"] && [Transport_Box validateTransportBoxCode:targetTransportCode];
        BOOL sourceIsValidBagCode = [sourceTransportCode hasPrefix:@"S:"] && [Transport validateTransportWithCode:sourceTransportCode];
        if (sourceIsValidBagCode && targetIsValidShippingBagCode) {
            NSString *bagColorCode = [sourceTransportCode substringWithRange:NSMakeRange(2, 1)];
            NSString *transportBagCode = [targetTransportCode substringFromIndex:1];
            BOOL specimenColorInTransportBag = [transportBagCode rangeOfString:bagColorCode].location != NSNotFound;
            BOOL transportBagWithX = [transportBagCode rangeOfString:@"X"].location != NSNotFound;
            result = transportBagWithX || specimenColorInTransportBag;
        }
    }
    return result;
}

+ (BOOL) validateTextInput:(NSString *) code {
    BOOL validated = YES;
    BOOL insufficientLength = code.length < 4;
    BOOL notCorrectForCustomer = YES;
    if (PFBrandingSupported(BrandingETA, nil)) {
        notCorrectForCustomer = (code.length < 6 || [@"ABCDEFGHIJKLMNOPQRSTUVWXYZ" rangeOfString:[code substringToIndex:1]].location == NSNotFound);
    } else if(PFBrandingSupported(BrandingOerlikon, nil)) {
        notCorrectForCustomer = (code.length < 6 ||
                                      ([[code substringToIndex:2]rangeOfString: @"LS"].location != 0 &&
                                       [[code substringToIndex:4]rangeOfString: @"XXLP"].location != 0 &&
                                       [[code substringToIndex:5]rangeOfString: @"HOBDE"].location != 0) ||
                                      ([[code substringToIndex:2]rangeOfString: @"LS"].location == 0 && code.length != 9) ||
                                      ([[code substringToIndex:2]rangeOfString: @"LS"].location == 0 &&
                                       [[code substringFromIndex:2] rangeOfString:@"[^0-9]" options:NSRegularExpressionSearch].location != NSNotFound) ||
                                      ([[code substringToIndex:4]rangeOfString: @"XXLP"].location == 0 &&
                                       [[code substringFromIndex:6] rangeOfString:@"[^0-9]" options:NSRegularExpressionSearch].location != NSNotFound));
    } else {
        notCorrectForCustomer = NO;
    }

    if (insufficientLength || notCorrectForCustomer) {
        validated = NO;
    }
    return validated;
}

@end


@implementation Transport(BarcodeSupport)

+ (NSString *) replaceAliasFromTransportCode:(NSString *) transportCode ctx:(NSManagedObjectContext *) ctx {
    NSString *result = transportCode;
    NSRange barCodeTrailerRange = [transportCode rangeOfString:@"$;$"];
    if (barCodeTrailerRange.location != NSNotFound) {
        NSString *alias = [transportCode substringFromIndex:(barCodeTrailerRange.location + barCodeTrailerRange.length)];
        NSString *tmpLocationCode = [Location_Alias locationCodeFromAlias:alias inCtx:ctx];
        NSString *currentTransportCode = [transportCode substringToIndex:barCodeTrailerRange.location];
        if (tmpLocationCode) {
            currentTransportCode = [NSString stringWithFormat:@"%@%@%@", currentTransportCode, @"$C$", tmpLocationCode];
        }
        result = currentTransportCode;
    }
    return result;
}

@end


@implementation Transport (TraceLogGeneration)

+ (NSMutableDictionary *) dictionaryWithCode:(NSString *)transportCode traceType:(TraceTypeValue)traceType
                               fromDeparture:(Departure *) departure toLocation:(Location *) toLocation
{
    return [Transport dictionaryWithCode:transportCode traceType:traceType fromDeparture:departure toLocation:toLocation finalDestination:nil isPallet:nil];
}

+ (NSMutableDictionary *) dictionaryWithCode:(NSString *)transportCode traceType:(TraceTypeValue)traceType
                                   fromDeparture:(Departure *) departure toLocation:(Location *) toLocation finalDestination:(Location *) finalDestination
                                    isPallet:(NSNumber *) isPallet
{
    NSMutableDictionary *currentTransport = [NSMutableDictionary dictionaryWithCapacity:7];
    [currentTransport setObject:[NSNumber numberWithInt:traceType]                                       forKey:@"trace_type_id"];
    [currentTransport setValue:transportCode                                                             forKey:@"code"];
    [currentTransport setObject:[NSNumber numberWithInt:3]												 forKey:@"term_id"];
    [currentTransport setValue:[NSUserDefaults currentTourId]                                            forKey:@"tour_id"];
    [currentTransport setValue:[NSUserDefaults currentTruckId]                                           forKey:@"truck_id"];
    [currentTransport setValue:[NSUserDefaults currentUserID]                                            forKey:@"user_id"];
    [currentTransport setValue:departure.departure_id                                                    forKey:@"from_departure"];
    [currentTransport setValue:departure.transport_group_id.transport_group_id                                                    forKey:@"transport_group_id"];
    [currentTransport setValue:departure.location_id.location_id                                         forKey:@"from_location"];
    [currentTransport setValue:toLocation.location_id                                                   forKey:@"to_location"];
    [currentTransport setValue:departure.transport_group_id.task                                       forKey:@"task"];
    
    // extras
    [currentTransport setValueOrSkip:finalDestination.location_id                                        forKey:@"final_destination_id"];
    [currentTransport setValueOrSkip:isPallet                                                            forKey:@"isPallet"];
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        NSString *jsonString = departure.tour_id.description_text;
        if (jsonString.length > 1)
        {
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSMutableDictionary* mutableJSON = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
            [mutableJSON setValue:departure.tour_id.code forKey:@"tourIdTch"];
            NSDictionary *userInfoDict = [currentTransport objectForKey:@"userInfo"];
            userInfoDict = [@{@"tour_info_tch": mutableJSON} dictionaryByAddingEntriesFromDictionary:userInfoDict];
            [currentTransport setValue:userInfoDict                                           forKey:@"userInfo"];
        }
    }
    
    return currentTransport;
}

+ (void) addLocation:(CLLocation *) location toTraceLogDict:(NSMutableDictionary *)transport {
    NSDictionary *userInfoDict = [transport objectForKey:@"userInfo"];
    NSDictionary *locationDictionary = @{ @"latitude" : [NSString stringWithFormat:@"%f", location.coordinate.latitude],
                                          @"longitude" : [NSString stringWithFormat:@"%f", location.coordinate.longitude] };
    userInfoDict = [locationDictionary dictionaryByAddingEntriesFromDictionary:userInfoDict];
    [transport setValue:userInfoDict forKey:@"userInfo"];
}

+ (void) addTransportBox:(Transport_Box *) box toTraceLogDict:(NSMutableDictionary *)transport {
    if (box == nil) return;

    NSDictionary *userInfoDict = [transport objectForKey:@"userInfo"];
    NSDictionary *additionalSyncValues = @{ @"transport_box_code" : box.code };
    userInfoDict = [additionalSyncValues dictionaryByAddingEntriesFromDictionary:userInfoDict];
    [transport setValue:userInfoDict forKey:@"userInfo"];
    
    [transport setValue:box.code forKey:@"transportBox"];
}

@end
