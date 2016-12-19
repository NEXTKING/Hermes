//
//  Location_Alias.m
//  Hermes
//
//  Created by Lutz  Thalmann on 19.04.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Location_Alias.h"
#import "Location.h"


@implementation Location_Alias

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"Location Aliases", @"Location Aliases");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfLocationAliases";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (Location_Alias  *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Location_Alias *location_Alias = nil;
	NSError        *error = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location_Alias" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"alias = %@", [serverData valueForKey:@"alias"]];
	
	// lastObject returns nil, if no data in db_handle
	location_Alias         = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!location_Alias) {
			// INSERT new Object (db_handle returns nil without an error)
			location_Alias = [NSEntityDescription insertNewObjectForEntityForName:@"Location_Alias" inManagedObjectContext:aCtx];
			location_Alias.alias = [serverData valueForKey:@"alias"];
            location_Alias.location_alias_id = [NSUserDefaults nextLocationAliasId];
		}
		// UPDATE properties for existing Object
		location_Alias.code = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]];
	}
	
	return location_Alias;
}

+ (NSString *)locationCodeFromAlias:(NSString *)aAlias inCtx:(NSManagedObjectContext *)aCtx {
    return [[[[self location_AliasesWithPredicate:[NSPredicate predicateWithFormat:@"alias = %@ OR alias != %@ && alias = %@ ", 
                                                    aAlias, @"0", [NSString stringWithFormat:@"%i",[aAlias intValue]]] 
                                                     inCtx:aCtx] valueForKeyPath:@"code"] lastObject] copy];
}

+ (NSArray  *)location_AliasesWithPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
	NSArray *location_Aliases = nil;
	NSError *error            = nil;
    
    //NSLog(@"Location SELECT FOR %@", [aPredicate predicateFormat]);
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Location_Alias" inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
	
	// returns nil, if no data in db_handle
	location_Aliases	   = [aCtx executeFetchRequest:db_handle error:&error];
    
	return location_Aliases;
}

@dynamic code;
@dynamic alias;
@dynamic location_alias_id;
@dynamic location_id;

- (void)addLocation_idObject:(Location *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"location_id" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"location_id"] addObject:value];
    [self didChangeValueForKey:@"location_id" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeLocation_idObject:(Location *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"location_id" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"location_id"] removeObject:value];
    [self didChangeValueForKey:@"location_id" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addLocation_id:(NSSet *)value {    
    [self willChangeValueForKey:@"location_id" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"location_id"] unionSet:value];
    [self didChangeValueForKey:@"location_id" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeLocation_id:(NSSet *)value {
    [self willChangeValueForKey:@"location_id" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"location_id"] minusSet:value];
    [self didChangeValueForKey:@"location_id" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
