// 
//  Term.m
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Term.h"

#import "Transport.h"

@implementation Term 

+ (Term *)termWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	Term	 *term  = nil;
	NSError  *error = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Term" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"term_id = %@", [serverData valueForKey:@"id"]];
	
	// lastObject returns nil, if no data in db_handle
	term				   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!term) {
			// INSERT new Object (db_handle returns nil without an error)
			term = [NSEntityDescription insertNewObjectForEntityForName:@"Term" inManagedObjectContext:aCtx];
			term.term_id = [serverData valueForKey:@"id"];
		}
		// UPDATE properties for existing Object
		term.code			  = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]];
		term.description_text = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"description"]];
	}
	
	return term;
}

+ (NSArray  *)termsWithPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *terms = nil;
	NSError  *error  = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Term" inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
	
	// lastObject returns nil, if no data in db_handle
	terms				   = [aCtx executeFetchRequest:db_handle error:&error];

	return terms;
}

@dynamic code;
@dynamic term_id;
@dynamic description_text;
@dynamic transprot_id;

@end
