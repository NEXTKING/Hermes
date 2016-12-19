// 
//  User.m
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"

#import "DSPF_Error.h"

NSString * const UserFunctionGoodsIssueEmployee = @"goodissue";
NSString * const UserFunctionDriver = @"driver";

@implementation User

+ (NSString *) synchronizationDisplayName {
    return NSLocalizedString(@"Users", @"Users");
}

+ (NSString *) lastUpdatedNSDefaultsKey {
    return @"lastUpdateOfUsers";
}

+ (void) willProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (void) didProcessDataFromServer:(NSArray *)serverData option:(NSString *) option inCtx:(NSManagedObjectContext *) ctx {
    
}

+ (User *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	User	 *user   = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"user_id = %i", [[serverData valueForKey:@"id"] intValue]];
	
	// lastObject returns nil, if no data in db_handle
	user				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!user) {
			// INSERT new Object (db_handle returns nil without an error)
            
            user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            user.user_id       = [NSNumber numberWithInt:[[serverData valueForKey:@"id"]intValue]];
		}
		// UPDATE properties for existing Object
		user.username     = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"username"]];
		user.password     = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"password"]];
		user.functions    = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"functions"]];
        if ([serverData valueForKey:@"firstname"]) {
            user.firstName = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"firstname"]];
        } else {
            user.firstName = nil;
        }
        if ([serverData valueForKey:@"lastname"]) {
            user.lastName = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"lastname"]];
        } else {
            user.lastName = nil;
        }
	}
	
	return user;
}

+ (User *)userWithTraceData:(NSDictionary *)traceData inCtx:(NSManagedObjectContext *)aCtx {
	User	 *user   = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"user_id = %i", [[traceData valueForKey:@"user_id"]intValue]];
	
	// lastObject returns nil, if no data in db_handle
	user				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!user) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:@"Trace-Informationen speichern"
						 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_029", @"ACHTUNG: Es wurden keine Daten für User-ID %@ gefunden. "
									  "Die T&T-Daten werden unvollständig gespeichert und an die Zentrale übermittelt!"),
									  [traceData valueForKey:@"user_id"]]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return user;
}

+ (User *)groupWithDefaultsFor:(NSNumber *)userID inCtx:(NSManagedObjectContext *)aCtx {
    if ([userID intValue] == -1) {
        return [self fromServerData:[NSDictionary dictionaryWithObjects:
                                         [NSArray arrayWithObjects:userID, @"System", nil]
                                                                    forKeys:
                                         [NSArray arrayWithObjects:@"id", @"username",nil]]
                 inCtx:(NSManagedObjectContext *)aCtx];
    }
    return [self fromServerData:[NSDictionary dictionaryWithObjects:
                                     [NSArray arrayWithObjects:[NSNumber numberWithInt:-999], @"???", nil]
                                                                forKeys:
                                     [NSArray arrayWithObjects:@"id", @"username",nil]]
             inCtx:(NSManagedObjectContext *)aCtx];
}

+ (User *)userID:(NSNumber *)userID forOrderHead:(ArchiveOrderHead *)orderHead inCtx:(NSManagedObjectContext *)aCtx {
	User	 *user   = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"user_id = %lld", [userID longLongValue]];
	
	// lastObject returns nil, if no data in db_handle
	user				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!user) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_051", @"Bestellung speichern")
						 messageText:[[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_007", @"ACHTUNG: Es wurden keine Daten für User-ID %lld gefunden. "),
                                       [userID longLongValue]] stringByAppendingString:
									  NSLocalizedString(@"MESSAGE_029", @"Die Bestellung wird ohne Benutzer-Daten gespeichert!")]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return user;
}

+ (User *)userID:(NSNumber *)userID forOrderLine:(ArchiveOrderLine *)orderLine inCtx:(NSManagedObjectContext *)aCtx {
	User	 *user   = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"user_id = %lld", [userID longLongValue]];
	
	// lastObject returns nil, if no data in db_handle
	user				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!user) {
			// INSERT new Object (db_handle returns nil without an error)
			[DSPF_Error messageTitle:NSLocalizedString(@"TITLE_040", @"Bestellposition speichern")
						 messageText:[[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_007", @"ACHTUNG: Es wurden keine Daten für User-ID %lld gefunden. "),
                                       [userID longLongValue]] stringByAppendingString:
									  NSLocalizedString(@"ERROR_MESSAGE_008", "Die Bestellposition wird ohne Benutzer-Daten gespeichert!")]
							delegate:nil];
		}
		// UPDATE properties for existing Object
	}
	
	return user;
}

+ (User *)userID:(NSNumber *)userID forTemplateHead:(TemplateOrderHead *)orderHead inCtx:(NSManagedObjectContext *)aCtx {
	User	 *user   = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"user_id = %lld", [userID longLongValue]];
	
	// lastObject returns nil, if no data in db_handle
	user				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!user) {
            user = [self groupWithDefaultsFor:userID inCtx:aCtx];
            if ([userID intValue] != -1) {
                // INSERT new Object (db_handle returns nil without an error)
                [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_041", @"Vorlage speichern")
                             messageText:[[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_007", @"ACHTUNG: Es wurden keine Daten für User-ID %lld gefunden. "),
                                           [userID longLongValue]] stringByAppendingString:
                                          NSLocalizedString(@"ERROR_MESSAGE_010", "Die Vorlage wird ohne Benutzer-Daten gespeichert!")]
                                delegate:nil];
            }
		}
		// UPDATE properties for existing Object
	}
	
	return user;
}

+ (User *)userID:(NSNumber *)userID forTemplateLine:(TemplateOrderLine *)orderLine inCtx:(NSManagedObjectContext *)aCtx {
	User	 *user   = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"user_id = %lld", [userID longLongValue]];
	
	// lastObject returns nil, if no data in db_handle
	user				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!user) {
            user = [self groupWithDefaultsFor:userID inCtx:aCtx];
            if ([userID intValue] != -1) {
                // INSERT new Object (db_handle returns nil without an error)
                [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_042", @"Vorlagedaten speichern")
                             messageText:[[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_007", @"ACHTUNG: Es wurden keine Daten für User-ID %lld gefunden. "),
                                           [userID longLongValue]] stringByAppendingString:
                                          NSLocalizedString(@"ERROR_MESSAGE_012", "Die Vorlagedaten werden ohne Benutzer-Daten gespeichert!")]
                                delegate:nil];
            }
		}
		// UPDATE properties for existing Object
	}
	
	return user;
}

+ (User *)userID:(NSNumber *)userID forInventoryLine:(InventoryLine *)inventoryLine inCtx:(NSManagedObjectContext *)aCtx {
	User	 *user   = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"user_id = %lld", [userID longLongValue]];
	
	// lastObject returns nil, if no data in db_handle
	user				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!user) {
            user = [self groupWithDefaultsFor:userID inCtx:aCtx];
            if ([userID intValue] != -1) {
                // INSERT new Object (db_handle returns nil without an error)
                [DSPF_Error messageTitle:NSLocalizedString(@"Inventurerfassung speichern",
                                                           @"Inventurerfassung speichern")
                             messageText:[[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_007",
                                                                                       @"ACHTUNG: Es wurden keine Daten für User-ID %lld gefunden. "),
                                           [userID longLongValue]] stringByAppendingString:
                                          NSLocalizedString(@"Die Inventurerfassung wird ohne Benutzer-Daten gespeichert!",
                                                            @"Die Inventurerfassung wird ohne Benutzer-Daten gespeichert!")]
                                delegate:nil];
            }
		}
		// UPDATE properties for existing Object
	}
	
	return user;
}

+ (User *)userWithUserID:(NSNumber *)userID inCtx:(NSManagedObjectContext *)aCtx {
    return [[self usersWithPredicate:[NSPredicate predicateWithFormat:@"user_id = %lld", [userID longLongValue]] inCtx:aCtx] lastObject];
}

+ (NSArray  *)usersWithPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
	NSArray *users	 = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
	
	// lastObject returns nil, if no data in db_handle
	users				   = [aCtx executeFetchRequest:db_handle error:&error];
	
	return users;
}

@dynamic description_text;
@dynamic firstName;
@dynamic functions;
@dynamic isEnabled;
@dynamic lastName;
@dynamic localeCode;
@dynamic password;
@dynamic user_id;
@dynamic username;
@dynamic archiveOrderHead;
@dynamic archiveOrderLine;
@dynamic inventoryLine;
@dynamic inventoryLineCorrection;
@dynamic templateOrderHead;
@dynamic templateOrderLine;
@dynamic trace_log_id;
@dynamic tour_id;


#pragma mark - Convenience methods

- (NSNumber *) menuConfiguredForDriver {
    NSNumber *menuForDriver = nil;
    if ([self hasFunction:UserFunctionDriver]) {
        menuForDriver = @YES;
    } else {
        if ([self hasFunction:UserFunctionGoodsIssueEmployee]) {
            menuForDriver = @NO;
        }
    }
    return menuForDriver;
}

- (NSString *) firstAndLastName {
    NSString *result = @"";
    if (self.firstName.length > 0) {
        result = self.firstName;
    }
    if (self.lastName.length > 0) {
        if (result.length > 0) {
            result = [result stringByAppendingFormat:@" %@", self.lastName];
        } else {
            result = self.lastName;
        }
    }
    return result;
}

- (BOOL) hasFunction:(NSString *) functionName {
    return [[self valueForKey:@"functions"] rangeOfString:functionName].location != NSNotFound;
}

- (BOOL) isInitialUser {
    return [self.user_id intValue] == 0;
}

+ (User *) initialUserFromContext:(NSManagedObjectContext *) context {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    User *initialUser = [[User alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];
    initialUser.user_id = [NSNumber numberWithInt:0];
    initialUser.functions = UserFunctionDriver;
    return initialUser;
}

@end