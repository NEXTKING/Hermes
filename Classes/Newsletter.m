//
//  Newsletter.m
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Newsletter.h"
#import "Keyword.h"


@implementation Newsletter

+ (Newsletter *)newsletterWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Newsletter *newsletter = nil;
	NSError         *error = nil;
    // If-Abfrage, ob die Schnittstelle a) die Spalte überhaupt hat und b) ob die Schnittstelle in der Spalte überhaupt einen Inhalt besitzt
    if ([serverData valueForKey:@"lang"] && [[NSString stringWithString:[serverData valueForKey:@"lang"]] length] > 0 && 
        [serverData valueForKey:@"text"] && [[NSString stringWithString:[serverData valueForKey:@"text"]] length] > 0 ) { 
        NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
        // db_handle.entity    = SQL-TABLE-Name
        db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
        // db_handle.predicate = SQL-WHERE-Condition
        //NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        db_handle.predicate    = [NSPredicate predicateWithFormat:@"newsletterID = %@ && localeCode = %@", 
                                  [serverData valueForKey:@"entryno"], [serverData valueForKey:@"lang"]];         
        // lastObject returns nil, if no data in db_handle
        newsletter             = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
        
        if (!error) {
            if (!newsletter) {
                // INSERT new Object (db_handle returns nil without an error)
                newsletter = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
                newsletter.newsletterID = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"entryno"]];
                newsletter.localeCode   = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]];
            }
            if ([serverData valueForKey:@"activ"] && [[serverData valueForKey:@"activ"] intValue] == 0) {
                // DELETE existing Object
                [aCtx deleteObject:newsletter];
            } else { 
                newsletter.text = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]];
                if ([serverData valueForKey:@"positionno"]) {
                    newsletter.newsletterPositionNumber = [NSNumber numberWithInt:[[serverData valueForKey:@"positionno"] intValue]];
                } else {
                    newsletter.newsletterPositionNumber = nil;
                }
                if ([serverData objectForKey:@"important"]) {
                    newsletter.alertBit = [NSNumber numberWithBool:[[serverData objectForKey:@"important"] boolValue]];
                } else {
                    newsletter.alertBit = nil;
                }
            }
        }        
    } 
    
	return newsletter;
}

+ (NSArray *)newsletterWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *newsletter = nil;
	NSError  *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	newsletter        = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return newsletter;
}

@dynamic localeCode;
@dynamic newsletterID;
@dynamic newsletterPositionNumber;
@dynamic alertBit;
@dynamic text;
@dynamic newsletterKeywords;

@end
