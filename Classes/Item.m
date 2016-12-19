//
//  Item.m
//  dphHermes
//
//  Created by iLutz on 01.07.14.
//
//

#import "Item.h"
#import "ItemCode.h"
#import "ItemDescription.h"
#import "ItemProductInformation.h"
#import "Promotion.h"
#import "Hitlist.h"
#import "BasketAnalysis.h"
#import "ArchiveOrderLine.h"
#import "TemplateOrderLine.h"
#import "InventoryLine.h"
#import "Transport.h"

NSString * const ItemCategoryReturnablePackages = @"1";
NSString * const ItemCategoryTransportGoods = @"2";
NSString * const ItemCategoryTransportServices = @"3";

@implementation Item

+ (Item *)itemWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Item        *item  = nil;
	NSError     *error = nil;
    
    // lastObject returns nil, if no data is found.
	item = [[aCtx executeFetchRequest:
             [aCtx.persistentStoreCoordinator.managedObjectModel
              fetchRequestFromTemplateWithName:@"FetchItemForDataImport"
              substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]],
                                     @"FRQitemID", nil]]
                                                 error:&error] lastObject];
	if (!error) {
		if (!item) {
			// INSERT new Object (db_handle returns nil without an error)
			item = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            item.itemID = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
		}
		// UPDATE properties for existing Object
        if ([serverData valueForKey:@"bbd"]) {
            item.bestBeforeDays = [NSNumber numberWithInt:[[serverData valueForKey:@"bbd"] intValue]];
        } else {
            item.bestBeforeDays = [NSNumber numberWithInt:00];
        }
        if ([serverData valueForKey:@"oucode"]) {
            item.orderUnitCode  = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"oucode"]];
        } else {
            item.orderUnitCode  = nil;
        }
        if ([serverData valueForKey:@"sucode"]) {
            item.salesUnitCode  = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"sucode"]];
        } else {
            item.salesUnitCode  = nil;
        }
        if ([serverData valueForKey:@"su2ou"]) {
            item.salesUnitsPerOrderUnit  = [NSNumber numberWithInt:[[serverData valueForKey:@"su2ou"] intValue]];
        } else {
            item.salesUnitsPerOrderUnit  = [NSNumber numberWithInt:1];
        }
        if ([serverData valueForKey:@"vat"]) {
            item.valueAddedTax = [NSDecimalNumber decimalNumberWithString:
                                  [NSString stringWithFormat:@"%.2f", [[serverData valueForKey:@"vat"] doubleValue]]
                                  ];
        } else {
            item.valueAddedTax = nil;
        }
        if ([serverData valueForKey:@"itemcategory"]) {
            item.itemCategoryCode = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemcategory"]];
        } else {
            item.itemCategoryCode = nil;
        }
        if ([serverData valueForKey:@"countryoforigin"]) {
            item.countryOfOriginCode = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"countryoforigin"]];
        } else {
            item.countryOfOriginCode = nil;
        }
        if ([serverData valueForKey:@"certification"]) {
            item.itemCertificationCode = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"certification"]];
        } else {
            item.itemCertificationCode = nil;
        }
        if ([serverData valueForKey:@"trademarkholder"]) {
            item.trademarkHolder = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"trademarkholder"]];
        } else {
            item.trademarkHolder = nil;
        }
        if ([serverData valueForKey:@"package"]) {
            item.itemPackageCode = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"package"]];
        } else {
            item.itemPackageCode = nil;
        }
        if ([serverData valueForKey:@"og1"]) {
            item.orderUnitBoxQTY = [NSDecimalNumber decimalNumberWithString:
                                    [NSString stringWithFormat:@"%.3f", [[serverData valueForKey:@"og1"] doubleValue]]
                                    ];
        } else {
            item.orderUnitBoxQTY = nil;
        }
        if ([serverData valueForKey:@"og2"]) {
            item.orderUnitLayerQTY = [NSDecimalNumber decimalNumberWithString:
                                      [NSString stringWithFormat:@"%.3f", [[serverData valueForKey:@"og2"] doubleValue]]
                                      ];
        } else {
            item.orderUnitLayerQTY = nil;
        }
        if ([serverData valueForKey:@"og3"]) {
            item.orderUnitPalletQTY = [NSDecimalNumber decimalNumberWithString:
                                       [NSString stringWithFormat:@"%.3f", [[serverData valueForKey:@"og3"] doubleValue]]
                                       ];
        } else {
            item.orderUnitPalletQTY = nil;
        }
        if ([serverData valueForKey:@"ogz"]) {
            item.orderUnitExtraChargeQTY = [NSDecimalNumber decimalNumberWithString:
                                            [NSString stringWithFormat:@"%.3f", [[serverData valueForKey:@"ogz"] doubleValue]]
                                            ];
        } else {
            item.orderUnitExtraChargeQTY = nil;
        }
        if ([serverData valueForKey:@"hitlistpositionno"]) {
            item.hitlist = [Hitlist hitlistWithServerData:serverData inCtx:aCtx];
        } else {
            item.hitlist = nil;
        }
        if ([serverData valueForKey:@"productgroup"]) {
            item.productGroup = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"productgroup"]];
        } else {
            item.productGroup = nil;
        }
        if ([serverData objectForKey:@"newcommer"]) {
            item.newcomerBit = [NSNumber numberWithBool:[[serverData objectForKey:@"newcommer"] boolValue]];
        } else {
            item.newcomerBit = [NSNumber numberWithBool:NO];
        }
        if (!item.item) {
            item.item = item;
        }
        /* should be sent as a separate "download" (transport_packaging) 
        if ([serverData objectForKey:@"has_negligible_footprint"]) {
            // item. = [NSNumber numberWithBool:[[serverData objectForKey:@"has_negligible_footprint"] boolValue]];
        } else {
            // item. = [NSNumber numberWithBool:NO];
        }
        */
        if ([serverData valueForKey:@"temp_zone"]) {
            item.temperatureZone = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"temp_zone"]];
        } else {
            item.temperatureZone = nil;
        }
        if ([serverData valueForKey:@"temp_limit"]) {
            item.temperatureLimit = [NSNumber numberWithInt:[[serverData valueForKey:@"temp_limit"] intValue]];
        } else {
            item.temperatureLimit = nil;
        }
        
        item.paymentOnDelivery = [serverData decimalForKey:@"payment_on_delivery"];
        item.paymentOnPickup = [serverData decimalForKey:@"payment_on_pickup"];
        item.grossWeight = [serverData decimalForKey:@"gross_weight"];
        item.netWeight = [serverData decimalForKey:@"net_weight"];
        
        if ([serverData objectForKey:@"is_identifiercode_scannable"]) {
            item.isItemIDScannable = [NSNumber numberWithBool:[[serverData objectForKey:@"is_identifiercode_scannable"] boolValue]];
        } else {
            item.isItemIDScannable = nil;
        }
	}
	
	return item;
}

+ (Item *)itemPriceWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Item    *item   = nil;
	NSError *error  = nil;
	
    // lastObject returns nil, if no data is found.
	item = [[aCtx executeFetchRequest:
             [aCtx.persistentStoreCoordinator.managedObjectModel
              fetchRequestFromTemplateWithName:@"FetchItemForDataImport"
              substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]],
                                     @"FRQitemID", nil]]
                                                 error:&error] lastObject];
	if (!error) {
		if (!item) {
			// INSERT new Object (db_handle returns nil without an error)
			item = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            item.itemID = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
            item.item   = item;
		}
		// UPDATE properties for existing Object
        if ([serverData valueForKey:@"price"]) {
            item.price  = [NSDecimalNumber decimalNumberWithString:
                           [NSString stringWithFormat:@"%.2f",
                            [[serverData valueForKey:@"price"] doubleValue]]
                           ];
        } else {
            item.price  = nil;
        }
        if ([serverData valueForKey:@"buyprice"]) {
            item.buyingPrice = [NSDecimalNumber decimalNumberWithString:
                                [NSString stringWithFormat:@"%.3f",
                                 [[serverData valueForKey:@"buyprice"] doubleValue]]
                                ];
        } else {
            item.buyingPrice = nil;
        }
        if ([serverData valueForKey:@"pricetext"]) {
            item.priceText = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"pricetext"]];
        } else {
            item.priceText = nil;
        }
	}
	
	return item;
}

+ (Item *)itemAssortmentWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Item    *item  = nil;
	NSError *error = nil;
	
    // lastObject returns nil, if no data is found.
	item = [[aCtx executeFetchRequest:
             [aCtx.persistentStoreCoordinator.managedObjectModel
              fetchRequestFromTemplateWithName:@"FetchItemForDataImport"
              substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]],
                                     @"FRQitemID", nil]]
                                                 error:&error] lastObject];
	if (!error) {
		if (!item) {
			// INSERT new Object (db_handle returns nil without an error)
			item = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            item.itemID = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]];
            item.item   = item;
		}
		// UPDATE properties for existing Object
        item.storeAssortmentBit = [NSNumber numberWithBool:YES];
	}
	
	return item;
}

+ (NSArray *)itemsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *items = nil;
	NSError  *error = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	items                  = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return items;
}

+ (Item *)itemWithItemID:(NSString *)itemID inCtx:(NSManagedObjectContext *)aCtx {
    return [[aCtx executeFetchRequest:
             [aCtx.persistentStoreCoordinator.managedObjectModel
              fetchRequestFromTemplateWithName:@"FetchItemForDataImport"
              substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                     itemID, @"FRQitemID", nil]]
                                                 error:nil] lastObject];
}

+ (Item *)managedObjectWithItemID:(NSString *)itemID inCtx:(NSManagedObjectContext *)aCtx {
    // frq.includesPropertyValues = NO; Achtung nicht verwendbar wegen fehlenden itemID's !
    // [frq setPropertiesToFetch:[NSArray arrayWithObject:@"itemID"]];
    return [[aCtx executeFetchRequest:
             [aCtx.persistentStoreCoordinator.managedObjectModel
              fetchRequestFromTemplateWithName:@"FetchItemForDataImport"
              substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                     itemID, @"FRQitemID", nil]]
                                                 error:nil] lastObject];
}

+ (NSString *)localDescriptionTextForItem:(Item *)aItem {
    NSString *bestDescription   = nil;
    NSString *preferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    for (ItemDescription *aDescription in [aItem.itemDescription allObjects]) {
        if (!bestDescription ||
            [[aDescription.localeCode lowercaseString] isEqualToString:@"de"] ||
            [[aDescription.localeCode lowercaseString] isEqualToString:preferredLanguage]) {
            bestDescription = aDescription.text;
            if ([[aDescription.localeCode lowercaseString] isEqualToString:preferredLanguage]) {
                break;
            }
        }
    }
    return bestDescription;
}

+ (NSString *)localProductInformationTextForItem:(Item *)aItem {
    NSString *bestProductInformationText = nil;
    NSString *preferredLanguage          = [[NSLocale preferredLanguages] objectAtIndex:0];
    for (ItemProductInformation *aProductInformation in [aItem.itemProductInformation allObjects]) {
        if (!bestProductInformationText ||
            [[aProductInformation.localeCode lowercaseString] isEqualToString:@"de"] ||
            [[aProductInformation.localeCode lowercaseString] isEqualToString:preferredLanguage]) {
            bestProductInformationText = aProductInformation.text;
            if ([[aProductInformation.localeCode lowercaseString] isEqualToString:preferredLanguage]) {
                break;
            }
        }
    }
    return bestProductInformationText;
}

@dynamic bestBeforeDays;
@dynamic buyingPrice;
@dynamic countryOfOriginCode;
@dynamic itemCategoryCode;
@dynamic itemCertificationCode;
@dynamic itemID;
@dynamic itemPackageCode;
@dynamic newcomerBit;
@dynamic orderUnitBoxQTY;
@dynamic orderUnitCode;
@dynamic orderUnitExtraChargeQTY;
@dynamic orderUnitLayerQTY;
@dynamic orderUnitPalletQTY;
@dynamic price;
@dynamic priceText;
@dynamic productGroup;
@dynamic salesUnitCode;
@dynamic salesUnitsPerOrderUnit;
@dynamic storeAssortmentBit;
@dynamic storeAssortmentCode;
@dynamic trademarkHolder;
@dynamic valueAddedTax;
@dynamic isItemIDScannable;
@dynamic paymentOnPickup;
@dynamic paymentOnDelivery;
@dynamic grossWeight;
@dynamic netWeight;
@dynamic temperatureZone;
@dynamic temperatureLimit;
@dynamic archiveOrderLine;
@dynamic basketAnalysis;
@dynamic basketAnalyzedItem;
@dynamic hitlist;
@dynamic inventoryLine;
@dynamic item;
@dynamic itemCode;
@dynamic itemDescription;
@dynamic itemProductInformation;
@dynamic promotion;
@dynamic templateOrderLine;
@dynamic transport;


@end
