//
//  Transport_Group.m
//  Hermes
//
//  Created by Lutz  Thalmann on 31.10.11.
//  Updated by Lutz  Thalmann on 03.10.14.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Transport_Group.h"

@implementation Transport_Group

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"Transport Groups", @"Transport Groups");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfTransportGroups";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *)option inCtx:(NSManagedObjectContext *)ctx {
    for (Transport_Group *unchained in [NSArray arrayWithArray:
                                        [Transport_Group withPredicate:[NSPredicate predicateWithFormat:@"transport_id.@count = 0"]
                                                                       sortDescriptors:nil inCtx:ctx]])
    {
        [ctx deleteObject:unchained];
    }
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (Transport_Group *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Transport_Group *transport_Group = nil;
	NSError   *error         = nil; 
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Transport_Group" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"task = %@", [NSString stringWithFormat:@"%@", [serverData valueForKey:@"task"]]];
	
	// lastObject returns nil, if no data in db_handle
	transport_Group        = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!transport_Group) {
			// INSERT new Object (db_handle returns nil without an error)
			transport_Group = [NSEntityDescription insertNewObjectForEntityForName:@"Transport_Group" inManagedObjectContext:aCtx];
            transport_Group.transport_group_id = [NSUserDefaults nextTransportGroupId];
		}
		// UPDATE properties for existing Object
        transport_Group.task                = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"task"]];
        if ([serverData objectForKey:@"code"]) {
            transport_Group.code            = [serverData valueForKey:@"code"];
        }
        if ([serverData objectForKey:@"customer"]) {
            transport_Group.customer        = [serverData valueForKey:@"customer"];
        }
        if ([serverData objectForKey:@"execution_time"]) { 
            NSDateFormatter *timeFMT  = [[NSDateFormatter alloc] init];
            [timeFMT setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
            transport_Group.execution_time  = [timeFMT dateFromString:[serverData valueForKey:@"execution_time"]];
        }
        if ([serverData objectForKey:@"info_text"]) {
            transport_Group.info_text       = [serverData valueForKey:@"info_text"];
        } else {
            transport_Group.info_text       = nil;
        }
        if ([serverData objectForKey:@"contractee_code"]) {
            transport_Group.contractee_code = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"contractee_code"]];
        } else {
            transport_Group.contractee_code = nil;
        }
        if ([serverData objectForKey:@"price"]) {
			transport_Group.price           = [NSDecimalNumber decimalNumberWithDecimal:[[serverData valueForKey:@"price"] decimalValue]];
		}
        if ([serverData objectForKey:@"isPickUp"]) {
            transport_Group.isPickup = [NSNumber numberWithBool:[[serverData objectForKey:@"isPickUp"] boolValue]];
        } else {
            if ([serverData objectForKey:@"scheduletype"]) {
                transport_Group.isPickup = [NSNumber numberWithBool:
                                            ([[[NSString stringWithFormat:@"%@", [serverData valueForKey:@"scheduletype"]] uppercaseString] isEqual:@"V"] ||
                                             [[[NSString stringWithFormat:@"%@", [serverData valueForKey:@"scheduletype"]] uppercaseString] isEqual:@"C"])];
            } else {
                transport_Group.isPickup = nil;
            }
        }
        NSDateFormatter *dateFMT  = [[NSDateFormatter alloc] init];
        [dateFMT setDateFormat:@"yyyy-MM-dd"];
        if ([serverData valueForKey:@"pickUpDate"]) {
            transport_Group.pickUpDate = [dateFMT dateFromString:[[serverData valueForKey:@"pickUpDate"]
                                                                  substringWithRange:NSMakeRange(0, 10)]];
        } else {
            transport_Group.pickUpDate = nil;
        }
        if ([serverData valueForKey:@"pickUpfrom"]) {
            NSDate *date = [DPHDateFormatter dateFromString:[[serverData valueForKey:@"pickUpfrom"] substringWithRange:NSMakeRange(11, 5)]
                                              withDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle locale:de_CH_Locale()];
            transport_Group.pickUpFrom = date;
        } else {
            transport_Group.pickUpFrom = nil;
        }
        if ([serverData valueForKey:@"pickUpUntil"]) {
            NSDate *date = [DPHDateFormatter dateFromString:[[serverData valueForKey:@"pickUpUntil"] substringWithRange:NSMakeRange(11, 5)]
                                              withDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle locale:de_CH_Locale()];
            transport_Group.pickUpUntil = date;
        } else {
            transport_Group.pickUpUntil = nil;
        }
        if ([serverData objectForKey:@"pickUpAgainstReceipt"]) {
			transport_Group.pickUpAgainstReceipt = [NSNumber numberWithBool:[[serverData objectForKey:@"pickUpAgainstReceipt"] boolValue]];
		} else {
            transport_Group.pickUpAgainstReceipt = nil;
        }
        if ([serverData objectForKey:@"pickUpAction"]) {
            transport_Group.pickUpAction = [serverData valueForKey:@"pickUpAction"];
        } else {
            transport_Group.pickUpAction = nil;
        }
        if ([serverData objectForKey:@"pickUpDateFixed"]) {
            transport_Group.pickUpDateFixed = [NSNumber numberWithBool:[[serverData objectForKey:@"pickUpDateFixed"] boolValue]];
        } else {
            transport_Group.pickUpDateFixed = nil;
        }
        if ([serverData objectForKey:@"pickUpInfoText"]) {
            transport_Group.pickUpInfoText = [serverData valueForKey:@"pickUpInfoText"];
        } else {
            transport_Group.pickUpInfoText = nil;
        }
        if ([serverData objectForKey:@"payment_on_pickup"]) {
			transport_Group.paymentOnPickup = [NSDecimalNumber decimalNumberWithDecimal:[[serverData valueForKey:@"payment_on_pickup"] decimalValue]];
		} else {
            transport_Group.paymentOnPickup = nil;
        }
        if ([serverData valueForKey:@"deliveryDate"]) {
            transport_Group.deliveryDate = [dateFMT dateFromString:[[serverData valueForKey:@"deliveryDate"]
                                                                    substringWithRange:NSMakeRange(0, 10)]];
        } else {
            transport_Group.deliveryDate = nil;
        }
        if ([serverData valueForKey:@"deliveryFrom"]) {
            NSDate *date = [DPHDateFormatter dateFromString:[[serverData valueForKey:@"deliveryFrom"] substringWithRange:NSMakeRange(11, 5)]
                                              withDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle locale:de_CH_Locale()];
            transport_Group.deliveryFrom = date;
        } else {
            transport_Group.deliveryFrom = nil;
        }
        if ([serverData valueForKey:@"deliveryUntil"]) {
            NSDate *date = [DPHDateFormatter dateFromString:[[serverData valueForKey:@"deliveryUntil"] substringWithRange:NSMakeRange(11, 5)]
                                              withDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle locale:de_CH_Locale()];
            transport_Group.deliveryUntil = date;
        } else {
            transport_Group.deliveryUntil = nil;
        }
        if ([serverData objectForKey:@"deliveryAgainstReceipt"]) {
			transport_Group.handOutAgainstReceipt = [NSNumber numberWithBool:[[serverData objectForKey:@"deliveryAgainstReceipt"] boolValue]];
		} else {
            if ([serverData objectForKey:@"handoutagainstreceipt"]) {
                transport_Group.handOutAgainstReceipt = [NSNumber numberWithBool:[[serverData objectForKey:@"handoutagainstreceipt"] boolValue]];
            } else {
                transport_Group.handOutAgainstReceipt = nil;
            }
        }
        if ([serverData objectForKey:@"deliveryAction"]) {
            transport_Group.deliveryAction = [serverData valueForKey:@"deliveryAction"];
        } else {
            transport_Group.deliveryAction = nil;
        }
        if ([serverData objectForKey:@"deliveryDateFixed"]) {
            transport_Group.deliveryDateFixed = [NSNumber numberWithBool:[[serverData objectForKey:@"deliveryDateFixed"] boolValue]];
        } else {
            transport_Group.deliveryDateFixed = nil;
        }
        if ([serverData objectForKey:@"deliveryInfoText"]) {
            transport_Group.deliveryInfoText = [serverData valueForKey:@"deliveryInfoText"];
        } else {
            transport_Group.deliveryInfoText = nil;
        }
        if ([serverData objectForKey:@"payment_on_delivery"]) {
			transport_Group.paymentOnDelivery = [NSDecimalNumber decimalNumberWithDecimal:[[serverData valueForKey:@"payment_on_delivery"] decimalValue]];
		} else {
            transport_Group.paymentOnDelivery = nil;
        }
        if ([serverData valueForKey:@"freightPayer"]) {
            transport_Group.freightpayer_id = [Location withID:[NSNumber numberWithInt:[[serverData valueForKey:@"freightPayer"] intValue]] inCtx:aCtx];
        } else {
            transport_Group.freightpayer_id = nil;
        }
        if ([serverData valueForKey:@"sender"]) {
            transport_Group.sender_id = [Location withID:[NSNumber numberWithInt:[[serverData valueForKey:@"sender"] intValue]] inCtx:aCtx];
        } else {
            transport_Group.sender_id = nil;
        }
        if ([serverData valueForKey:@"addressee"]) {
            transport_Group.addressee_id = [Location withID:[NSNumber numberWithInt:[[serverData valueForKey:@"addressee"] intValue]] inCtx:aCtx];
        } else {
            transport_Group.addressee_id = nil;
        }
	} else {
		NSLog(@"ERROR Transport_Group transport_GroupWithServerData:  %@ %@", error, [error userInfo]); 
	}
	return transport_Group;
}

+ (Transport_Group *)transport_GroupWithTask:(NSString *)aTask inCtx:(NSManagedObjectContext *)aCtx {
	Transport_Group *transport_Group = nil;
	NSError   *error         = nil; 
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Transport_Group" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"task = %@", aTask];
	
	// lastObject returns nil, if no data in db_handle
	transport_Group        = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!transport_Group) {
			// INSERT new Object (db_handle returns nil without an error)
			transport_Group = [NSEntityDescription insertNewObjectForEntityForName:@"Transport_Group" inManagedObjectContext:aCtx];
            transport_Group.transport_group_id = [NSUserDefaults nextTransportGroupId];
		}
		// UPDATE properties for existing Object
        transport_Group.task               = aTask;
	} else {
		NSLog(@"ERROR Transport_Group transport_GroupWithTask:  %@ %@", error, [error userInfo]); 
	}
	return transport_Group;
}

+ (Transport_Group *)transport_GroupWithTransportData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Transport_Group *transport_Group = nil;
	NSError   *error         = nil; 
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Transport_Group" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"task = %@", [NSString stringWithFormat:@"%@", [serverData valueForKey:@"task"]]];
	
	// lastObject returns nil, if no data in db_handle
	transport_Group        = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!transport_Group) {
			// INSERT new Object (db_handle returns nil without an error)
			transport_Group = [NSEntityDescription insertNewObjectForEntityForName:@"Transport_Group" inManagedObjectContext:aCtx];
            transport_Group.transport_group_id = [NSUserDefaults nextTransportGroupId];
		}
		// UPDATE properties for existing Object
        transport_Group.task            = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"task"]];
	} else {
		NSLog(@"ERROR Transport_Group transport_GroupWithTransportData:  %@ %@", error, [error userInfo]); 
	}
	return transport_Group;
}

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
    return [self withPredicate:aPredicate sortDescriptors:nil inCtx:aCtx];
}

+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors
                     inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *transport_Groups = nil;
	NSError  *error            = nil;
    
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Transport_Group" inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	transport_Groups       = [aCtx executeFetchRequest:db_handle error:&error];

	return transport_Groups;
}

@dynamic code;
@dynamic contractee_code;
@dynamic customer;
@dynamic deliveryAction;
@dynamic deliveryDate;
@dynamic deliveryDateFixed;
@dynamic deliveryFrom;
@dynamic deliveryInfoText;
@dynamic deliveryUntil;
@dynamic execution_time;
@dynamic handOutAgainstReceipt;
@dynamic info_text;
@dynamic isPickup;
@dynamic paymentOnDelivery;
@dynamic paymentOnPickup;
@dynamic pickUpAction;
@dynamic pickUpAgainstReceipt;
@dynamic pickUpDate;
@dynamic pickUpDateFixed;
@dynamic pickUpFrom;
@dynamic pickUpInfoText;
@dynamic pickUpUntil;
@dynamic price;
@dynamic task;
@dynamic transport_group_id;
@dynamic addressee_id;
@dynamic departure_id;
@dynamic freightpayer_id;
@dynamic sender_id;
@dynamic transport_id;

@end


@implementation Transport_Group (Hermes)


- (NSArray *)transportSummaryWithSortDescriptors:(NSArray *)sortDescriptors {
    NSMutableArray  *transportSummary   = [NSMutableArray array];
    NSString        *tmpTemperatureZone = nil;
    NSString        *tmpSalesUnitCode   = nil;
    NSString        *tmpItemID          = nil;
    NSDecimalNumber *tmpWeight          = [NSDecimalNumber zero];
    NSDecimalNumber *tmpNetWeight       = [NSDecimalNumber zero];
    NSNumber        *tmpQTY             = [NSNumber numberWithInt:0];
    NSUInteger       tmpCounter         = 0;
    Transport       *tmpTransport       = nil;
    for (tmpTransport in [[[self.transport_id allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                                      @"item_id != nil && item_id.itemID != nil && item_id.itemCategoryCode = \"2\""]]
                          sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                                       [NSSortDescriptor sortDescriptorWithKey:@"temperatureZone" ascending:YES],
                                                       [NSSortDescriptor sortDescriptorWithKey:@"item_id.salesUnitCode" ascending:YES],
                                                       [NSSortDescriptor sortDescriptorWithKey:@"item_id.itemID" ascending:YES], nil]]) {
        if (!([tmpTransport.temperatureZone isEqual:tmpTemperatureZone] &&
              [tmpTransport.item_id.salesUnitCode isEqual:tmpSalesUnitCode] &&
              [tmpTransport.item_id.itemID isEqual:tmpItemID])) {
            if (tmpCounter > 0) {
                // End of "old" GroupLevel
                NSDecimalNumberHandler *roundUp = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundUp
                                                                                                  scale:0
                                                                                       raiseOnExactness:YES
                                                                                        raiseOnOverflow:YES
                                                                                       raiseOnUnderflow:YES
                                                                                    raiseOnDivideByZero:YES];
                [transportSummary addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                                 tmpTemperatureZone ? tmpTemperatureZone : [NSNull null],
                                                                                 tmpSalesUnitCode ? tmpSalesUnitCode : [NSNull null],
                                                                                 tmpItemID,
                                                                                 [tmpWeight decimalNumberByRoundingAccordingToBehavior:roundUp],
                                                                                 [tmpNetWeight decimalNumberByRoundingAccordingToBehavior:roundUp],
                                                                                 tmpQTY,
                                                                                 [NSNumber numberWithUnsignedInteger:tmpCounter], nil]
                                                                        forKeys:[NSArray arrayWithObjects:
                                                                                 @"temperatureZone",
                                                                                 @"salesUnitCode",
                                                                                 @"itemID",
                                                                                 @"totalWeight",
                                                                                 @"totalNetWeigh",
                                                                                 @"totalQTY",
                                                                                 @"totalCount", nil]]];
            }
            // Start of "new" GroupLevel
            tmpTemperatureZone  = tmpTransport.temperatureZone;
            tmpSalesUnitCode    = tmpTransport.item_id.salesUnitCode;
            tmpItemID           = tmpTransport.item_id.itemID;
            tmpWeight           = [NSDecimalNumber zero];
            tmpNetWeight        = [NSDecimalNumber zero];
            tmpQTY              = [NSNumber numberWithInt:0];
            tmpCounter          = 0;
        }
        if (tmpTransport.weight && [tmpTransport.weight compare:[NSDecimalNumber zero]] != NSOrderedSame) {
            tmpWeight          = [tmpWeight decimalNumberByAdding:tmpTransport.weight];
        } else {
            if (tmpTransport.netWeight)
                tmpWeight      = [tmpWeight decimalNumberByAdding:tmpTransport.netWeight];
        }
                                  
        if (tmpTransport.netWeight)
            tmpNetWeight       = [tmpNetWeight decimalNumberByAdding:tmpTransport.netWeight];
        tmpQTY                 = [NSNumber numberWithInt:([tmpQTY integerValue] + [tmpTransport.itemQTY integerValue])];
        tmpCounter   ++;
    }
    if (tmpCounter > 0) {
        // End of "unsaved" GroupLevel
        NSDecimalNumberHandler *roundUp = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundUp
                                                                                          scale:0
                                                                               raiseOnExactness:YES
                                                                                raiseOnOverflow:YES
                                                                               raiseOnUnderflow:YES
                                                                            raiseOnDivideByZero:YES];
        [transportSummary addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                         tmpTemperatureZone ? tmpTemperatureZone : [NSNull null],
                                                                         tmpSalesUnitCode ? tmpSalesUnitCode : [NSNull null],
                                                                         tmpItemID,
                                                                         [tmpWeight decimalNumberByRoundingAccordingToBehavior:roundUp],
                                                                         [tmpNetWeight decimalNumberByRoundingAccordingToBehavior:roundUp],
                                                                         tmpQTY,
                                                                         [NSNumber numberWithUnsignedInteger:tmpCounter], nil]
                                                                forKeys:[NSArray arrayWithObjects:
                                                                         @"temperatureZone",
                                                                         @"salesUnitCode",
                                                                         @"itemID",
                                                                         @"totalWeight",
                                                                         @"totalNetWeigh",
                                                                         @"totalQTY",
                                                                         @"totalCount", nil]]];
    }
    if (sortDescriptors) {
        return [transportSummary sortedArrayUsingDescriptors:sortDescriptors];
    }
    return [NSArray arrayWithArray:transportSummary];
}

+ (Transport_Group *) transportGroupForItem:(id) item ctx:(NSManagedObjectContext *)ctx createWhenNotExisting:(BOOL)createWhenNotExisting {
    Transport_Group *result = nil;
    if ([item isKindOfClass:[Transport_Group class]]) return result;
    if ([item isKindOfClass:[Departure class]] && ((Departure *)item).transport_group_id != nil) return result;
    
    if ([item isKindOfClass:[Departure class]]) {
        // temporary proof of delivery created on the mobile
        NSString *code = [NSString stringWithFormat:@"tmp-local-%@", ((Departure *)item).departure_id];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        fetch.entity       = [NSEntityDescription entityForName:NSStringFromClass([Transport_Group class]) inManagedObjectContext:ctx];
        fetch.predicate    = AndPredicates([Transport_Group withoutReferences], [Transport_Group withCode:code], nil);
        
        NSError *error = nil;
        NSArray *transportGroups = [ctx executeFetchRequest:fetch error:&error];
        if (error) {
            NSLog(@"Could not execute fetch: %@, reason: %@", fetch, error);
        } else {
            result = [transportGroups lastObject];
            if (result == nil && createWhenNotExisting) {
                result = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Transport_Group class])
                                                       inManagedObjectContext:ctx];
                result.transport_group_id = [NSUserDefaults nextTransportGroupId];
                result.code = code;
            }
        }
    }
    return result;
}

@end

@implementation Transport_Group (Predicates)

+ (NSPredicate *) deletableOnEndOfTour {
    return [Transport_Group withoutReferences];
}

+ (NSPredicate *) withCode:(NSString *) code {
    return [NSPredicate predicateWithFormat:@"code = %@", code];
}

+ (NSPredicate *) withoutReferences {
    return [NSPredicate predicateWithFormat:@"sender_id = nil AND addressee_id = nil AND freightpayer_id = nil AND (SUBQUERY(departure_id, $d, $d.departure_id != 0).@count == 0)"];
}

+ (NSPredicate *) withLocation:(Location *)location {
    return [NSPredicate predicateWithFormat:@"location_id.location_id = %@", location.location_id];
}

+ (NSPredicate *) withTourId:(int) tourId {
    return [NSPredicate predicateWithFormat:@"tour_id.tour_id  = %i", tourId];
}

+ (NSPredicate *) withDayOfWeek:(int) dayOfWeek {
    return [NSPredicate predicateWithFormat:@"dayOfWeek = %i", dayOfWeek];
}

@end
