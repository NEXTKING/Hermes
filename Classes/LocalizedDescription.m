//
//  LocalizedDescription.m
//  StoreOnline
//
//  Created by iLutz on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocalizedDescription.h"


@implementation LocalizedDescription

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"Descriptions", @"Descriptions");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfDescriptions";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (LocalizedDescription *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
    LocalizedDescription *localizedDescription = nil;
    NSError *error = nil;
    NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
    db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([LocalizedDescription class]) inManagedObjectContext:aCtx];
    db_handle.predicate    = [LocalizedDescription withCode:[serverData stringForKey:@"code"] language:[serverData stringForKey:@"lang"] key:[serverData stringForKey:@"key"]];
    
    localizedDescription				= [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
    
    if (!error) {
        if (!localizedDescription) {
            localizedDescription = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([LocalizedDescription class]) inManagedObjectContext:aCtx];
        }

        // UPDATE properties for existing Object
        localizedDescription.localeCode = [serverData stringForKey:@"localeCode"];
        localizedDescription.text = [serverData stringForKey:@"text"];
        localizedDescription.key = [serverData stringForKey:@"key"];
        localizedDescription.code = [serverData stringForKey:@"code"];
    }
    
    return localizedDescription;
}

+ (LocalizedDescription *)localizedDescription:(NSString *)text
                                      withCode:(NSString *)code
                                        forKey:(NSString *)key
                                    localeCode:(NSString *)localeCode 
                        inCtx:(NSManagedObjectContext *)aCtx {
	LocalizedDescription *localizedDescription = nil;
	NSError *error = nil;
    
    if (code.length > 0 && localeCode.length > 0 && text.length > 0) { 
        NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
        // db_handle.entity    = SQL-TABLE-Name
        db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
        // db_handle.predicate = SQL-WHERE-Condition
        db_handle.predicate    = [NSPredicate predicateWithFormat:@"code = %@ && key = %@ && localeCode = %@", 
                                  code,        key,        [localeCode uppercaseString]];
        [db_handle setPropertiesToFetch:[NSArray arrayWithObjects:@"code", @"key", @"localeCode", nil]];
        // lastObject returns nil, if no data in db_handle
        localizedDescription   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];

        if (!error) {
            if (!localizedDescription) {
                // INSERT new Object (db_handle returns nil without an error)
                localizedDescription = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
                localizedDescription.code       = code;
                localizedDescription.key        = key;
                localizedDescription.localeCode = [localeCode uppercaseString];
            }
            // UPDATE properties for existing Object
            localizedDescription.text = text;
        }
    }
	
	return localizedDescription;
}

+ (NSString *)textForKey:(NSString *)aKey withCode:(NSString *)aCode inCtx:(NSManagedObjectContext *)aCtx {
    NSString *bestDescription   = nil;
    NSString *preferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    for (LocalizedDescription *aDescription in [self localizedDescriptionsWithPredicate:[NSPredicate predicateWithFormat:@"code = %@ && key = %@", 
                                                                                                                          aCode,       aKey] 
                                                                        sortDescriptors:nil inCtx:aCtx]) { 
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

+ (NSArray *)localizedDescriptionsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *localizedDescriptions = nil;
	NSError  *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	localizedDescriptions  = [aCtx executeFetchRequest:db_handle error:&error];

	return localizedDescriptions;
}

@dynamic code;
@dynamic key;
@dynamic localeCode;
@dynamic text;

@end


@implementation LocalizedDescription(Predicates)

+ (NSPredicate *) withCode:(NSString *) code language:(NSString *) language key:(NSString *) key {
    return [NSPredicate predicateWithFormat:@"code = %@ && localeCode = %@ && key = %@", code, language, key];
}

@end