//
//  Transport_Box.m
//  Hermes
//
//  Created by Attila Teglas on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Transport_Box.h"
#import "Transport.h"
#import "Location.h"


@implementation Transport_Box

+ (Transport_Box *)transport_boxWithBarCode:(NSString *)barCode inCtx:(NSManagedObjectContext *)aCtx {
	Transport_Box	 *transportbox  = nil;
	NSError          *error = nil;
    NSString *entityName = NSStringFromClass([Transport_Box class]);
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:entityName inManagedObjectContext:aCtx];
	db_handle.predicate    = [Transport_Box withCode:barCode];

	// lastObject returns nil, if no data in db_handle
	transportbox		   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!transportbox) {
			// INSERT new Object (db_handle returns nil without an error)
			transportbox = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:aCtx];
			transportbox.code = barCode;
		}
	}
	return transportbox;
}

+ (BOOL)hasBoxWithCode:(NSString *)boxCode inCtx:(NSManagedObjectContext *)aCtx {
    if ([[self transport_boxPredicate:[Transport_Box withCode:boxCode] sortDescriptors:nil inCtx:aCtx] lastObject]) {
        return YES;
    } 
    return NO;
}

+ (Transport_Box *)recommendedBoxInCtx:(NSManagedObjectContext *)aCtx {
    NSString *boxCode = [Transport transportCodeFromBarcode:[NSUserDefaults boxBarcode]];
    if ([self hasBoxWithCode:boxCode inCtx:aCtx]) {
        return [self transport_boxWithBarCode:boxCode inCtx:aCtx];
    }
    return nil;
}

+ (NSArray *) withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
    return [Transport_Box transport_boxPredicate:aPredicate sortDescriptors:nil inCtx:aCtx];
}

+ (NSArray  *)transport_boxPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *transportbox = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
	
	// lastObject returns nil, if no data in db_handle
	transportbox				   = [aCtx executeFetchRequest:db_handle error:&error];
    
	return transportbox;
}

- (Location *) finalDestinationLocation {
    Location *finalDestinationLocation = [[self initiallyCreatedTransport] final_destination_id];
    return finalDestinationLocation;
}

- (Transport *) initiallyCreatedTransport {
    return [[Transport withPredicate:[Transport withCodes:@[self.code]] inCtx:[self managedObjectContext]] lastObject];
}

@dynamic code;
@dynamic transport_id;
@dynamic status;

@end


@implementation Transport_Box (Validation)

+ (BOOL) validateTextInput:(NSString *)inputText {
    BOOL inputValid = NO;
    NSInteger minimumBarcodeLength = 6;
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        minimumBarcodeLength = 4;
    }
    if (inputText && inputText.length >= minimumBarcodeLength) {
        inputValid = YES;
        if (PFBrandingSupported(BrandingETA, nil)) {
            NSRange upperCaseLetterRange = [@"ABCDEFGHIJKLMNOPQRSTUVWXYZ" rangeOfString:[inputText substringToIndex:1]];
            if (upperCaseLetterRange.location == NSNotFound) {
                inputValid = NO;
            }
        }
    }
    return inputValid;
}

+ (BOOL) validateTransportBoxBarcode:(NSString *) transportBoxBarcode {
    NSRegularExpression *transportBoxExpr = [Transport_Box transportBoxBarcodeExpression];
    NSRange searchingRange = NSMakeRange(0, transportBoxBarcode.length);
    NSRange shippingBagRange = [transportBoxExpr rangeOfFirstMatchInString:transportBoxBarcode options:0 range:searchingRange];
    
    return NSEqualRanges(shippingBagRange, searchingRange);
}

+ (BOOL) validateTransportBoxCode:(NSString *) transportCode {
    NSRegularExpression *transportBoxExpr = [Transport_Box transportBoxCodeExpression];
    NSRange searchingRange = NSMakeRange(0, transportCode.length);
    NSRange shippingBagRange = [transportBoxExpr rangeOfFirstMatchInString:transportCode options:0 range:searchingRange];
    
    return NSEqualRanges(shippingBagRange, searchingRange);
}

+ (NSRegularExpression *) transportBoxCodeExpression {
    NSError *error = nil;
    NSRegularExpression *transportBoxExpr = [NSRegularExpression regularExpressionWithPattern:@".*" options:0 error:&error];
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        transportBoxExpr = [NSRegularExpression regularExpressionWithPattern:@"T:[A-Z]{1,4}[0-9]{1,5}" options:0 error:&error];
    } else if (PFBrandingSupported(BrandingViollier, nil)) {
        transportBoxExpr = [NSRegularExpression regularExpressionWithPattern:@"V005:.*" options:0 error:&error];
    }
    NSAssert(transportBoxExpr, @"Could not compile regex expression. Reason: %@", error);
    return transportBoxExpr;
}

+ (NSRegularExpression *) transportBoxBarcodeExpression {
    NSError *error = nil;
    NSRegularExpression *transportBoxExpr = [NSRegularExpression regularExpressionWithPattern:@".*" options:0 error:&error];
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        transportBoxExpr = [NSRegularExpression regularExpressionWithPattern:@"T:[A-Z]{1,4}[0-9]{1,5}.*" options:0 error:&error];
    } else if (PFBrandingSupported(BrandingViollier, nil)) {
        transportBoxExpr = [NSRegularExpression regularExpressionWithPattern:@"V005:.*" options:0 error:&error];
    }
    NSAssert(transportBoxExpr, @"Could not compile regex expression. Reason: %@", error);
    return transportBoxExpr;
}

@end

@implementation Transport_Box (Predicate)

+ (NSPredicate *) withCode:(NSString *) code {
    return [NSPredicate predicateWithFormat:@"code = %@", code];
}

+ (NSPredicate *) deletableOnEndOfTour {
    return [NSPredicate predicateWithFormat:@"(0 == SUBQUERY(transport_id, $t, $t.trace_type_id.code = %@).@count)", TraceTypeStringLoad];
}

@end