//
//  Transport_Packaging.m
//  Hermes
//
//  Created by iLutz on 05.09.13.
//
//

#import "Transport_Packaging.h"
#import "Transport.h"


@implementation Transport_Packaging

+ (Transport_Packaging *)transportPackagingWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Transport_Packaging *transportPackaging = nil;
	NSError         *error = nil;
    NSString        *code  = [serverData valueForKey:@"transportpackagingcode"];
    if (!code)       code  = @"*NONE";
    
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Transport_Packaging" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"code = %@", code];

    // lastObject returns nil, if no data in db_handle
	transportPackaging     = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];

    
	if (!error) {
		if (!transportPackaging) {
			// INSERT new Object (db_handle returns nil without an error)
			transportPackaging = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            transportPackaging.transport_packaging_id = [NSUserDefaults nextTransportPackagingId];
            transportPackaging.code = code;
		}
		// UPDATE properties for existing Object
        if ([serverData valueForKey:@"transportpackagingisrelevantfortransportation"] || PFBrandingSupported(BrandingBiopartner, nil)) {
            transportPackaging.isRelevantForTransportation = [NSNumber numberWithBool:YES];
        } else {
            transportPackaging.isRelevantForTransportation = [NSNumber numberWithBool:NO];
        }
	}
	
	return transportPackaging;
}
+ (NSArray *)transportPackagingsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *transportPackagings = nil;
	NSError  *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	transportPackagings    = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return transportPackagings;

}

@dynamic code;
@dynamic description_text;
@dynamic transport_packaging_id;
@dynamic isRelevantForTransportation;
@dynamic footprint_x;
@dynamic footprint_y;
@dynamic footprint_z;
@dynamic transport_id;

@end
